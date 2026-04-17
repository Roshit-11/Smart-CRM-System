package com.crm.app.controller;

import com.crm.app.config.PasswordUtil;
import com.crm.app.dao.UserDao;
import com.crm.app.model.User;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.UUID;

@WebServlet("/manage-users")
public class ManageUsersController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DEFAULT_FROM_EMAIL = "noreply.meetingai@gmail.com";
    private static final String ENV_MAIL_FROM = "SMARTCRM_MAIL_FROM";
    private static final String ENV_MAIL_APP_PASSWORD = "SMARTCRM_MAIL_APP_PASSWORD";
    private static final String PROP_MAIL_FROM = "smartcrm.mail.from";
    private static final String PROP_MAIL_APP_PASSWORD = "smartcrm.mail.app.password";

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminSession(request, response)) {
            return;
        }
        loadTeamMembers(request);
        request.getRequestDispatcher("/view/dashboard/manage-users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminSession(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        if ("updateUser".equals(action)) {
            handleUpdateUser(request);
        } else if ("deleteUser".equals(action)) {
            handleDeleteUser(request);
        } else {
            handleCreateUser(request);
        }

        loadTeamMembers(request);
        request.getRequestDispatcher("/view/dashboard/manage-users.jsp").forward(request, response);
    }

    private void handleCreateUser(HttpServletRequest request)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String companyName = resolveCompanyName(request);
        User sessionUser = (User) request.getSession().getAttribute("user");
        if ((companyName == null || companyName.trim().isEmpty()) && sessionUser != null) {
            companyName = sessionUser.getCompanyName();
        }

        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "User name is required.");
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required.");
            return;
        }

        if (companyName == null || companyName.trim().isEmpty()) {
            request.setAttribute("error", "Company not found in session. Please login again.");
            return;
        }

        String generatedPassword = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        String hashedPassword = PasswordUtil.hashPassword(generatedPassword);

        boolean created = userDao.createUserByAdmin(name.trim(), email.trim(), hashedPassword, companyName.trim());
        if (created) {
            try {
                sendEmail(email.trim(), generatedPassword);
                request.setAttribute("success", "User created successfully and credentials emailed to " + email.trim() + ".");
            } catch (MessagingException e) {
                getServletContext().log("Email delivery failed for user: " + email, e);
                request.setAttribute("error", "User created, but email delivery failed. Share this temporary password manually: " + generatedPassword);
            }
        } else {
            request.setAttribute("error", "Unable to create user. Email may already exist.");
        }
    }

    private void handleUpdateUser(HttpServletRequest request) {
        String userIdParam = request.getParameter("userId");
        String name = request.getParameter("name");
        String companyName = resolveCompanyName(request);

        if (companyName == null || companyName.trim().isEmpty()) {
            request.setAttribute("error", "Company not found in session. Please login again.");
            return;
        }

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Invalid user id.");
            return;
        }

        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Name is required.");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid user id.");
            return;
        }

        boolean updated = userDao.updateUserNameByIdAndCompany(userId, name.trim(), companyName.trim());
        if (updated) {
            request.setAttribute("success", "User name updated successfully.");
        } else {
            request.setAttribute("error", "Unable to update user. The user may not belong to your company.");
        }
    }

    private void handleDeleteUser(HttpServletRequest request) {
        String userIdParam = request.getParameter("userId");
        String companyName = resolveCompanyName(request);

        if (companyName == null || companyName.trim().isEmpty()) {
            request.setAttribute("error", "Company not found in session. Please login again.");
            return;
        }

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Invalid user id.");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid user id.");
            return;
        }

        User sessionUser = (User) request.getSession().getAttribute("user");
        if (sessionUser != null && sessionUser.getId() == userId) {
            request.setAttribute("error", "You cannot delete your own admin account.");
            return;
        }

        boolean deleted = userDao.deleteUserByIdAndCompany(userId, companyName.trim());
        if (deleted) {
            request.setAttribute("success", "User deleted successfully.");
        } else {
            request.setAttribute("error", "Unable to delete user. The user may not belong to your company.");
        }
    }

    private void loadTeamMembers(HttpServletRequest request) {
        String companyName = resolveCompanyName(request);
        if (companyName == null || companyName.trim().isEmpty()) {
            request.setAttribute("teamMembers", java.util.Collections.emptyList());
            request.setAttribute("memberCount", 0);
            request.setAttribute("searchQuery", "");
            request.setAttribute("roleFilter", "all");
            request.setAttribute("totalUsersCount", 0);
            request.setAttribute("adminsCount", 0);
            request.setAttribute("usersCount", 0);
            return;
        }

        List<User> allTeamMembers = userDao.getUsersByCompany(companyName.trim());
        int adminsCount = 0;
        int usersCount = 0;
        for (User member : allTeamMembers) {
            if ("admin".equalsIgnoreCase(member.getRole())) {
                adminsCount++;
            } else {
                usersCount++;
            }
        }
        request.setAttribute("totalUsersCount", allTeamMembers.size());
        request.setAttribute("adminsCount", adminsCount);
        request.setAttribute("usersCount", usersCount);
        request.setAttribute("memberCount", allTeamMembers.size());

        String searchQuery = request.getParameter("search");
        if (searchQuery == null) {
            searchQuery = "";
        }
        String normalizedQuery = searchQuery.trim().toLowerCase();
        request.setAttribute("searchQuery", searchQuery.trim());

        String roleFilter = request.getParameter("role");
        if (roleFilter == null || roleFilter.trim().isEmpty()) {
            roleFilter = "all";
        }
        String normalizedRole = roleFilter.trim().toLowerCase();
        request.setAttribute("roleFilter", normalizedRole);

        List<User> filteredTeamMembers = new ArrayList<>();
        for (User member : allTeamMembers) {
            String memberName = member.getName() == null ? "" : member.getName().toLowerCase();
            String memberRole = member.getRole() == null ? "user" : member.getRole().toLowerCase();

            boolean matchesSearch = normalizedQuery.isEmpty() || memberName.contains(normalizedQuery);
            boolean matchesRole = "all".equals(normalizedRole) || memberRole.equals(normalizedRole);

            if (matchesSearch && matchesRole) {
                filteredTeamMembers.add(member);
            }
        }

        request.setAttribute("teamMembers", filteredTeamMembers);
    }

    private String resolveCompanyName(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                companyName = user.getCompanyName();
                session.setAttribute("companyName", companyName);
            }
        }

        return companyName;
    }

    private boolean isAdminSession(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/view/auth/login.jsp");
            return false;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/auth/login.jsp");
            return false;
        }

        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/view/auth/change-password.jsp");
            return false;
        }

        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/view/dashboard/home.jsp");
            return false;
        }

        return true;
    }

    private void sendEmail(String toEmail, String generatedPassword) throws MessagingException {
        String fromEmail = getConfigValue(ENV_MAIL_FROM, PROP_MAIL_FROM, DEFAULT_FROM_EMAIL);
        String appPassword = getConfigValue(ENV_MAIL_APP_PASSWORD, PROP_MAIL_APP_PASSWORD, "");
        if (appPassword.trim().isEmpty()) {
            throw new MessagingException(
                    "Mail app password is not configured. Set env " + ENV_MAIL_APP_PASSWORD
                            + " or JVM property " + PROP_MAIL_APP_PASSWORD + "."
            );
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, appPassword);
            }
        });

        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(fromEmail));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("SmartCRM Account Created");
        message.setText(
                "Hello,\n\n"
                        + "Your SmartCRM account has been created.\n\n"
                        + "Email: " + toEmail + "\n"
                        + "Password: " + generatedPassword + "\n\n"
                        + "Please login and change your password.\n\n"
                        + "- SmartCRM Team"
        );

        Transport.send(message);
    }

    private String getConfigValue(String envKey, String propertyKey, String defaultValue) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue.trim();
        }

        String propertyValue = System.getProperty(propertyKey);
        if (propertyValue != null && !propertyValue.trim().isEmpty()) {
            return propertyValue.trim();
        }

        return defaultValue;
    }
}
