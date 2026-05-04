package com.crm.app.controller;

import com.crm.app.dao.ActivityLogDao;
import com.crm.app.dao.CustomerDao;
import com.crm.app.dao.UserDao;
import com.crm.app.dao.TaskDao;
import com.crm.app.model.User;
import com.crm.app.model.ActivityLog;
import com.crm.app.model.Task;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/admin-dashboard")
public class AdminDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final UserDao userDao = new UserDao();
    private final CustomerDao customerDao = new CustomerDao();
    private final ActivityLogDao activityLogDao = new ActivityLogDao();
    private final TaskDao taskDao = new TaskDao();

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

        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = "SmartCRM";
        }

        int totalUsers = userDao.countUsersByCompany(companyName);
        int totalCustomers = customerDao.countCustomersByCompany(companyName);
        Timestamp since = Timestamp.valueOf(LocalDateTime.now().minusDays(7));
        int activityCount = activityLogDao.countActivitySince(companyName, since);
        List<Task> adminTasks = taskDao.getRecentTasksByCompany(companyName);
        List<ActivityLog> recentActivities = activityLogDao.getRecentActivities(companyName);

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("activityCount", activityCount);
        request.setAttribute("adminTasks", adminTasks);
        request.setAttribute("recentActivities", recentActivities);

        request.getRequestDispatcher("/view/dashboard/admin-dashboard.jsp").forward(request, response);
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