package com.crm.app.controller;

import com.crm.app.config.PasswordUtil;
import com.crm.app.dao.CustomerDao;
import com.crm.app.dao.CompanySettingsDao;
import com.crm.app.dao.UserDao;
import com.crm.app.model.CompanySettings;
import com.crm.app.model.User;
import com.crm.app.service.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/settings")
public class SettingsController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final UserDao userDao = new UserDao();
    private final CustomerDao customerDao = new CustomerDao();
    private final CompanySettingsDao companySettingsDao = new CompanySettingsDao();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/change-password");
            return;
        }

        if ("admin".equalsIgnoreCase(user.getRole())) {
            String companyName = resolveCompanyName(session, user);
            if (companyName != null && !companyName.trim().isEmpty()) {
                int totalUsers = userDao.countUsersByCompany(companyName);
                int totalCustomers = customerDao.countCustomersByCompany(companyName);
                request.setAttribute("totalUsers", totalUsers);
                request.setAttribute("totalCustomers", totalCustomers);
            }
        }

        String flashError = (String) session.getAttribute("settingsError");
        String flashSuccess = (String) session.getAttribute("settingsSuccess");
        if (flashError != null) {
            request.setAttribute("error", flashError);
            session.removeAttribute("settingsError");
        }
        if (flashSuccess != null) {
            request.setAttribute("success", flashSuccess);
            session.removeAttribute("settingsSuccess");
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName != null && !companyName.trim().isEmpty()) {
            CompanySettings settings = companySettingsDao.getByCompany(companyName);
            request.setAttribute("companyEmailSettings", settings);
        }

        request.getRequestDispatcher("/view/dashboard/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/change-password");
            return;
        }

        String action = request.getParameter("action");
        if ("updateProfile".equals(action)) {
            handleUpdateProfile(request, user, session);
        } else if ("changePassword".equals(action)) {
            handleChangePassword(request, user);
        } else if ("updateNotifications".equals(action)) {
            handleUpdateNotifications(request, user, session);
        } else if ("sendCompanyEmailOtp".equals(action)) {
            handleSendCompanyEmailOtp(request, user, session);
        } else if ("verifyCompanyEmailOtp".equals(action)) {
            handleVerifyCompanyEmailOtp(request, user, session);
        } else if ("unlinkCompanyEmail".equals(action)) {
            handleUnlinkCompanyEmail(request, user, session);
        }

        response.sendRedirect(request.getContextPath() + "/settings");
    }

    private void handleUpdateProfile(HttpServletRequest request, User user, HttpSession session) {
        String name = read(request.getParameter("name"));
        String email = read(request.getParameter("email"));
        if (name.isEmpty() || email.isEmpty()) {
            return;
        }

        if (userDao.updateProfile(user.getId(), name, email)) {
            user.setName(name);
            user.setEmail(email);
            session.setAttribute("user", user);
        }
    }

    private void handleChangePassword(HttpServletRequest request, User user) {
        String newPassword = read(request.getParameter("newPassword"));
        if (newPassword.isEmpty()) {
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        userDao.updatePassword(user.getId(), hashedPassword);
    }

    private void handleUpdateNotifications(HttpServletRequest request, User user, HttpSession session) {
        int customerAssign = request.getParameter("notify_customer_assign") != null ? 1 : 0;
        int taskAssign = request.getParameter("notify_task_assign") != null ? 1 : 0;
        int taskUpdate = request.getParameter("notify_task_update") != null ? 1 : 0;

        if (userDao.updateNotificationSettings(user.getId(), customerAssign, taskAssign, taskUpdate)) {
            user.setNotifyCustomerAssign(customerAssign == 1);
            user.setNotifyTaskAssign(taskAssign == 1);
            user.setNotifyTaskUpdate(taskUpdate == 1);
            session.setAttribute("user", user);
        }
    }

    private void handleSendCompanyEmailOtp(HttpServletRequest request, User user, HttpSession session) {
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("settingsError", "Only admins can link company email.");
            return;
        }

        String smtpEmail = read(request.getParameter("smtpEmail"));
        String smtpPassword = read(request.getParameter("smtpPassword"));
        if (smtpEmail.isEmpty() || smtpPassword.isEmpty()) {
            session.setAttribute("settingsError", "SMTP email and app password are required.");
            return;
        }

        String otp = String.valueOf((int) (Math.random() * 900000) + 100000);
        boolean sent = emailService.sendEmail(
                smtpEmail,
                "SmartCRM verification code",
                "Your SmartCRM verification code is: " + otp,
                smtpEmail,
                smtpPassword
        );

        if (!sent) {
            session.setAttribute("settingsError", "Unable to send verification code. Check SMTP credentials.");
            return;
        }

        session.setAttribute("companyEmailOtp", otp);
        session.setAttribute("companyEmailPending", smtpEmail);
        session.setAttribute("companyEmailPassword", smtpPassword);
        session.setAttribute("settingsSuccess", "Verification code sent. Check the inbox.");
    }

    private void handleVerifyCompanyEmailOtp(HttpServletRequest request, User user, HttpSession session) {
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("settingsError", "Only admins can verify company email.");
            return;
        }

        String enteredOtp = read(request.getParameter("verificationCode"));
        String otp = (String) session.getAttribute("companyEmailOtp");
        String smtpEmail = (String) session.getAttribute("companyEmailPending");
        String smtpPassword = (String) session.getAttribute("companyEmailPassword");

        if (enteredOtp.isEmpty() || otp == null || smtpEmail == null || smtpPassword == null) {
            session.setAttribute("settingsError", "Verification code expired. Please request a new one.");
            return;
        }

        if (!otp.equals(enteredOtp)) {
            session.setAttribute("settingsError", "Invalid verification code.");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            session.setAttribute("settingsError", "Company not found.");
            return;
        }

        if (companySettingsDao.saveOrUpdate(companyName, smtpEmail, smtpPassword, true)) {
            session.removeAttribute("companyEmailOtp");
            session.removeAttribute("companyEmailPending");
            session.removeAttribute("companyEmailPassword");
            session.setAttribute("settingsSuccess", "Company email linked successfully.");
        } else {
            session.setAttribute("settingsError", "Failed to save company email settings.");
        }
    }

    private void handleUnlinkCompanyEmail(HttpServletRequest request, User user, HttpSession session) {
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("settingsError", "Only admins can unlink company email.");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            session.setAttribute("settingsError", "Company not found.");
            return;
        }

        if (companySettingsDao.unlinkByCompany(companyName)) {
            session.setAttribute("settingsSuccess", "Company email unlinked.");
        } else {
            session.setAttribute("settingsError", "Unable to unlink company email.");
        }
    }

    private String read(String value) {
        return value == null ? "" : value.trim();
    }

    private String resolveCompanyName(HttpSession session, User user) {
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
            session.setAttribute("companyName", companyName);
        }
        return companyName;
    }
}
