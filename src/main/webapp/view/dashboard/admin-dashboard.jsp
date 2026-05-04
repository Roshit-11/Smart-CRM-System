<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.Task" %>
<%@ page import="com.crm.app.model.ActivityLog" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260504b">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body>
    <%
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

        String currentDate = LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy"));
        int hour = LocalTime.now().getHour();
        String greeting;
        if (hour < 12) greeting = "Good morning";
        else if (hour < 17) greeting = "Good afternoon";
        else greeting = "Good evening";

        String userName = user.getName() != null ? user.getName() : "Admin";

        Integer totalUsersAttr = (Integer) request.getAttribute("totalUsers");
        Integer totalCustomersAttr = (Integer) request.getAttribute("totalCustomers");
        Integer activityCountAttr = (Integer) request.getAttribute("activityCount");
        int totalUsers = totalUsersAttr != null ? totalUsersAttr : 0;
        int totalCustomers = totalCustomersAttr != null ? totalCustomersAttr : 0;
        int activityCount = activityCountAttr != null ? activityCountAttr : 0;

        @SuppressWarnings("unchecked")
        List<Task> adminTasks = (List<Task>) request.getAttribute("adminTasks");
        @SuppressWarnings("unchecked")
        List<ActivityLog> recentActivities = (List<ActivityLog>) request.getAttribute("recentActivities");

        int unreadNotifications = 0;
        try {
            unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
        } catch (Exception ignored) {
        }

        request.setAttribute("unreadNotifications", unreadNotifications);
        request.setAttribute("activeNav", "dashboard");
        request.setAttribute("topSearchPlaceholder", "Search users, customers, reports...");

        LocalDate today = LocalDate.now();
        java.sql.Date todaySql = java.sql.Date.valueOf(today);
    %>

    <div class="saas-shell">
        <jsp:include page="/view/components/top-navbar.jsp" />
        <jsp:include page="/view/components/admin-sidebar.jsp" />

        <main class="saas-main">
            <section class="saas-welcome-block">
                <p class="saas-date"><%= currentDate %></p>
                <h1><%= greeting %>, <%= userName %></h1>
            </section>

            <section class="saas-card-grid">
                <article class="saas-card">
                    <div class="saas-card-icon"><i data-lucide="user-cog"></i></div>
                    <p class="saas-card-title">Total Users</p>
                    <h3><%= totalUsers %></h3>
                    <span class="saas-card-hint">Registered accounts in system</span>
                </article>
                <article class="saas-card card-accent-green">
                    <div class="saas-card-icon"><i data-lucide="users"></i></div>
                    <p class="saas-card-title">Total Customers</p>
                    <h3><%= totalCustomers %></h3>
                    <span class="saas-card-hint">Across all teams</span>
                </article>
                <article class="saas-card card-accent-purple">
                    <div class="saas-card-icon"><i data-lucide="activity"></i></div>
                    <p class="saas-card-title">Activity</p>
                    <h3><%= activityCount %></h3>
                    <span class="saas-card-hint">Actions in last 7 days</span>
                </article>
            </section>

            <div class="saas-content-grid">
                <section class="saas-panel">
                    <h3>Tasks</h3>
                    <% if (adminTasks == null || adminTasks.isEmpty()) { %>
                        <div class="empty-state">
                            <i data-lucide="clipboard-check"></i>
                            <p class="empty-state-title">No tasks assigned</p>
                            <p class="empty-state-sub">Team tasks will show up here.</p>
                        </div>
                    <% } else {
                        for (Task task : adminTasks) {
                            String status = task.getStatus() == null ? "Pending" : task.getStatus();
                            boolean isCompleted = "Completed".equalsIgnoreCase(status);
                            boolean isOverdue = !isCompleted && task.getDueDate() != null && task.getDueDate().before(todaySql);
                            String dotClass = isOverdue ? "task-dot--overdue"
                                    : "Completed".equalsIgnoreCase(status) ? "task-dot--completed"
                                    : "In Progress".equalsIgnoreCase(status) ? "task-dot--in-progress"
                                    : "task-dot--pending";
                            String badgeClass = isOverdue ? "task-badge--overdue"
                                    : "Completed".equalsIgnoreCase(status) ? "task-badge--completed"
                                    : "In Progress".equalsIgnoreCase(status) ? "task-badge--in-progress"
                                    : "task-badge--pending";
                            String badgeText = isOverdue ? "Overdue" : status;
                            String rowClass = isOverdue ? "task-row task-row--overdue" : "task-row";
                    %>
                        <div class="<%= rowClass %>">
                            <span class="task-dot <%= dotClass %>"></span>
                            <div class="task-body">
                                <p class="task-title"><%= task.getTitle() %></p>
                                <span class="task-meta"><i data-lucide="calendar"></i> Due <%= task.getDueDate() %></span>
                            </div>
                            <span class="task-badge <%= badgeClass %>"><%= badgeText %></span>
                        </div>
                    <% }} %>
                </section>

                <section class="saas-panel">
                    <h3>Recent Activity</h3>
                    <% if (recentActivities == null || recentActivities.isEmpty()) { %>
                        <div class="empty-state">
                            <i data-lucide="activity"></i>
                            <p class="empty-state-title">No recent activity</p>
                            <p class="empty-state-sub">Your team's actions will appear here.</p>
                        </div>
                    <% } else {
                        for (ActivityLog log : recentActivities) {
                            String actor = log.getUserName() != null ? log.getUserName() : "Unknown";
                            String details = log.getDetails() != null ? log.getDetails() : log.getAction();
                            String initial = actor.substring(0, 1).toUpperCase();
                    %>
                        <div class="activity-row">
                            <div class="activity-avatar"><%= initial %></div>
                            <div class="activity-body">
                                <p class="activity-text"><strong><%= actor %></strong> &middot; <%= details %></p>
                                <span class="activity-time"><%= log.getCreatedAt() %></span>
                            </div>
                        </div>
                    <% }} %>
                </section>
            </div>

            <section class="saas-panel profile-details">
                <h3>Admin Snapshot</h3>
                <div class="saas-info-row"><span>Email</span><strong><%= user.getEmail() %></strong></div>
                <div class="saas-info-row"><span>Role</span><strong>Admin</strong></div>
                <div class="saas-info-row"><span>User ID</span><strong><%= user.getId() %></strong></div>
            </section>
        </main>
    </div>

    <jsp:include page="/view/components/notifications-panel.jsp" />
</body>
</html>
