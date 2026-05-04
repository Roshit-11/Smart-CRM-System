package com.crm.app.controller;

import com.crm.app.dao.ActivityLogDao;
import com.crm.app.dao.CustomerDao;
import com.crm.app.dao.TaskDao;
import com.crm.app.model.User;
import com.crm.app.model.Task;
import com.crm.app.model.ActivityLog;
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
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        if ("admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = "SmartCRM";
        }

        int totalCustomers = customerDao.countCustomersByCompany(companyName);
        Map<String, Integer> statusCounts = customerDao.countByStatus(companyName);
        Timestamp since = Timestamp.valueOf(LocalDateTime.now().minusDays(7));
        int activityCount = activityLogDao.countActivitySince(companyName, since);
        int myTasksCount = taskDao.countTasksByUser(user.getId());
        List<Task> myTasks = taskDao.getTasksByUser(user.getId());
        List<ActivityLog> recentActivities = activityLogDao.getRecentActivities(user.getCompanyName());

        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("activityCount", activityCount);
        request.setAttribute("leadCount", statusCounts.getOrDefault("Lead", 0));
        request.setAttribute("convertedCount", statusCounts.getOrDefault("Won", 0));
        request.setAttribute("lostCount", statusCounts.getOrDefault("Lost", 0));
        request.setAttribute("myTasksCount", myTasksCount);
        request.setAttribute("myTasks", myTasks);
        request.setAttribute("recentActivities", recentActivities);

        request.getRequestDispatcher("/view/dashboard/home.jsp").forward(request, response);
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