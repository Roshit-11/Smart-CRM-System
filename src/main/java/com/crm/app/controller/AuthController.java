package com.crm.app.controller;

import com.crm.app.config.PasswordUtil;
import com.crm.app.dao.UserDao;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet({"/login", "/register", "/logout", "/change-password"})
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String LOGIN_VIEW = "/view/auth/login.jsp";
    private static final String REGISTER_VIEW = "/view/auth/register.jsp";
    private static final String CHANGE_PASSWORD_VIEW = "/view/auth/change-password.jsp";

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/login".equals(path)) {
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        } else if ("/register".equals(path)) {
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
        } else if ("/logout".equals(path)) {
            handleLogout(request, response);
        } else if ("/change-password".equals(path)) {
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/login".equals(path)) {
            handleLogin(request, response);
        } else if ("/register".equals(path)) {
            handleRegister(request, response);
        } else if ("/change-password".equals(path)) {
            handleChangePassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    /**
     * Handle user login
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Validate input - check if email or password is empty
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Password is required");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
            return;
        }
        
        // Validate user credentials from database
        User user = userDao.validateUser(email, password);
        
        if (user != null) {
            // User found and password matches - Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("companyName", user.getCompanyName());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            
            // Enforce password reset for first login before allowing dashboard access.
            if (user.isFirstLogin()) {
                response.sendRedirect(request.getContextPath() + "/change-password");
                return;
            }

            if ("admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/view/dashboard/admin-dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/view/dashboard/home.jsp");
            }
        } else {
            // Invalid credentials - email not found or password incorrect
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        }
    }

    /**
     * Handle user registration
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String companyName = request.getParameter("company_name");
        
        // Validate input - check each field
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Full name is required");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Password is required");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }

        if (companyName == null || companyName.trim().isEmpty()) {
            request.setAttribute("error", "Company name is required");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
            return;
        }
        
        // Registering from public form always creates company admin.
        User user = new User(name, email, password, "admin", companyName.trim(), false);
        
        // Register user in database
        boolean isRegistered = userDao.registerUser(user);
        
        if (isRegistered) {
            // Registration successful - redirect to login page
            request.setAttribute("success", "Registration successful! Please login with your credentials.");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        } else {
            // Registration failed - likely email already exists
            request.setAttribute("error", "Registration failed. Email may already exist or invalid format.");
            request.getRequestDispatcher(REGISTER_VIEW).forward(request, response);
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "New password is required");
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
            return;
        }

        if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "Confirm password is required");
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
            return;
        }

        if (newPassword.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters long");
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        boolean updated = userDao.updatePasswordAndClearFirstLogin(sessionUser.getId(), hashedPassword);

        if (!updated) {
            request.setAttribute("error", "Failed to update password. Please try again.");
            request.getRequestDispatcher(CHANGE_PASSWORD_VIEW).forward(request, response);
            return;
        }

        sessionUser.setFirstLogin(false);
        session.setAttribute("user", sessionUser);

        if ("admin".equalsIgnoreCase(sessionUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/view/dashboard/admin-dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/view/dashboard/home.jsp");
        }
    }

    /**
     * Handle logout from GET requests by destroying session and removing auth cookie.
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        Cookie userCookie = new Cookie("user_id", "");
        userCookie.setMaxAge(0);
        userCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(userCookie);

        response.sendRedirect(request.getContextPath() + "/login");
    }
}
