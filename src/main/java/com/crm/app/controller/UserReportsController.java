package com.crm.app.controller;

import com.crm.app.dao.ActivityLogDao;
import com.crm.app.dao.CustomerDao;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/user-reports")
public class UserReportsController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CustomerDao customerDao = new CustomerDao();
    private final ActivityLogDao activityLogDao = new ActivityLogDao();

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

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = "SmartCRM";
        }

        Map<String, Integer> statusCounts = customerDao.countByStatus(companyName);
        int leadCount = statusCounts.getOrDefault("Lead", 0);
        int convertedCount = statusCounts.getOrDefault("Won", 0);
        int lostCount = statusCounts.getOrDefault("Lost", 0);

        request.setAttribute("totalCustomers", customerDao.countCustomersByCompany(companyName));
        request.setAttribute("assignedCustomers", customerDao.countCustomersByAssignedUser(user.getId(), companyName));
        request.setAttribute("leadCount", leadCount);
        request.setAttribute("convertedCount", convertedCount);
        request.setAttribute("lostCount", lostCount);
        request.setAttribute("activityTrend", buildActivityTrend(companyName));

        request.getRequestDispatcher("/view/dashboard/user-reports.jsp").forward(request, response);
    }

    private String resolveCompanyName(HttpSession session, User user) {
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
            session.setAttribute("companyName", companyName);
        }
        return companyName;
    }

    private List<Map<String, Object>> buildActivityTrend(String companyName) {
        List<Map<String, Object>> trend = new ArrayList<>();
        List<Map<String, Object>> raw = activityLogDao.getActivityTrend(companyName, 7);
        Map<LocalDate, Integer> counts = new HashMap<>();

        for (Map<String, Object> row : raw) {
            Object dayObj = row.get("day");
            if (dayObj instanceof Date) {
                counts.put(((Date) dayObj).toLocalDate(), (Integer) row.get("total"));
            }
        }

        DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("EEE");
        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            Map<String, Object> point = new HashMap<>();
            point.put("dayLabel", day.format(labelFmt));
            point.put("total", counts.getOrDefault(day, 0));
            trend.add(point);
        }

        return trend;
    }
}
