package com.crm.app.controller;

import com.crm.app.dao.NotificationDao;
import com.crm.app.model.Notification;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/notifications")
public class NotificationController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final NotificationDao notificationDao = new NotificationDao();

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

        String action = request.getParameter("action");
        if ("markRead".equals(action)) {
            handleMarkReadAndRedirect(request, response, user.getId());
            return;
        }

        List<Notification> notifications = notificationDao.getNotificationsByUser(user.getId());
        request.setAttribute("notifications", notifications);

        String fragment = request.getParameter("fragment");
        if ("1".equals(fragment)) {
            request.getRequestDispatcher("/view/dashboard/notifications.jsp").forward(request, response);
            return;
        }

        // No standalone notifications page anymore; return user to a safe default.
        response.sendRedirect(request.getContextPath() + "/dashboard");
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
        if ("markRead".equals(action)) {
            String notificationIdParam = request.getParameter("notificationId");
            if (notificationIdParam != null && !notificationIdParam.trim().isEmpty()) {
                try {
                    int notificationId = Integer.parseInt(notificationIdParam.trim());
                    notificationDao.markAsRead(notificationId, user.getId());
                } catch (NumberFormatException ignored) {
                    // ignore invalid id
                }
            }
        } else if ("markAllRead".equals(action)) {
            notificationDao.markAllAsRead(user.getId());
        }

        response.sendRedirect(request.getContextPath() + "/notifications");
    }

    private void handleMarkReadAndRedirect(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {
        String notificationIdParam = request.getParameter("notificationId");
        if (notificationIdParam != null && !notificationIdParam.trim().isEmpty()) {
            try {
                int notificationId = Integer.parseInt(notificationIdParam.trim());
                notificationDao.markAsRead(notificationId, userId);
            } catch (NumberFormatException ignored) {
                // ignore invalid id
            }
        }

        String redirectParam = request.getParameter("redirect");
        if (redirectParam != null && !redirectParam.trim().isEmpty()) {
            String decoded = URLDecoder.decode(redirectParam.trim(), StandardCharsets.UTF_8);
            String contextPath = request.getContextPath();
            boolean safe = decoded.startsWith(contextPath + "/") || (contextPath.isEmpty() && decoded.startsWith("/"));
            if (safe) {
                response.sendRedirect(decoded);
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}