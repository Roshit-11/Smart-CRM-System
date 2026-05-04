<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Reports - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260504b">
    <jsp:include page="/view/components/page-head.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = user.getCompanyName();
    }
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = "SmartCRM";
    }

    Integer totalCustomersAttr = (Integer) request.getAttribute("totalCustomers");
    Integer assignedCustomersAttr = (Integer) request.getAttribute("assignedCustomers");
    Integer leadCountAttr = (Integer) request.getAttribute("leadCount");
    Integer convertedCountAttr = (Integer) request.getAttribute("convertedCount");
    Integer lostCountAttr = (Integer) request.getAttribute("lostCount");
    int totalCustomers = totalCustomersAttr != null ? totalCustomersAttr : 0;
    int assignedCustomers = assignedCustomersAttr != null ? assignedCustomersAttr : 0;
    int leadCount = leadCountAttr != null ? leadCountAttr : 0;
    int convertedCount = convertedCountAttr != null ? convertedCountAttr : 0;
    int lostCount = lostCountAttr != null ? lostCountAttr : 0;

    int unreadNotifications = 0;
    try {
        unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
    } catch (Exception ignored) {
    }

    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "reports");
    request.setAttribute("topSearchPlaceholder", "Search reports...");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> activityTrend = (List<Map<String, Object>>) request.getAttribute("activityTrend");

    StringBuilder activityLabels = new StringBuilder();
    StringBuilder activityData = new StringBuilder();
    if (activityTrend != null) {
        for (int i = 0; i < activityTrend.size(); i++) {
            Map<String, Object> point = activityTrend.get(i);
            String label = point.get("dayLabel") == null ? "" : String.valueOf(point.get("dayLabel")).replace("\"", "\\\"");
            int total = point.get("total") == null ? 0 : ((Number) point.get("total")).intValue();
            if (i > 0) {
                activityLabels.append(",");
                activityData.append(",");
            }
            activityLabels.append("\"").append(label).append("\"");
            activityData.append(total);
        }
    }
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <jsp:include page="/view/components/user-sidebar.jsp" />

    <main class="saas-main">
        <section class="saas-welcome-block">
            <p class="saas-date">Company: <strong><%= companyName %></strong></p>
            <h1>Reports</h1>
        </section>

        <section class="saas-card-grid">
            <article class="saas-card">
                <p class="saas-card-title"><i data-lucide="user"></i> Total Customers</p>
                <h3><%= totalCustomers %></h3>
                <span class="saas-card-hint">Across your company</span>
            </article>
            <article class="saas-card">
                <p class="saas-card-title"><i data-lucide="user-check"></i> Assigned to You</p>
                <h3><%= assignedCustomers %></h3>
                <span class="saas-card-hint">Customers in your queue</span>
            </article>
            <article class="saas-card">
                <p class="saas-card-title"><i data-lucide="zap"></i> Leads</p>
                <h3><%= leadCount %></h3>
                <span class="saas-card-hint">Prospective customers</span>
            </article>
            <article class="saas-card">
                <p class="saas-card-title"><i data-lucide="check-circle"></i> Converted</p>
                <h3><%= convertedCount %></h3>
                <span class="saas-card-hint">Closed wins</span>
            </article>
            <article class="saas-card">
                <p class="saas-card-title"><i data-lucide="x-circle"></i> Lost</p>
                <h3><%= lostCount %></h3>
                <span class="saas-card-hint">Closed losses</span>
            </article>
        </section>

        <div class="saas-content-grid">
            <section class="saas-panel">
                <h3>Customers by Status</h3>
                <div style="height: 280px; margin-top: 12px;">
                    <canvas id="statusChart"></canvas>
                </div>
            </section>

            <section class="saas-panel">
                <h3>Activity in Last 7 Days</h3>
                <div style="height: 280px; margin-top: 12px;">
                    <canvas id="activityChart"></canvas>
                </div>
            </section>
        </div>
    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />

<script>
const statusChart = new Chart(document.getElementById("statusChart"), {
    type: "pie",
    data: {
        labels: ["Lead", "Converted", "Lost"],
        datasets: [{
            data: [<%= leadCount %>, <%= convertedCount %>, <%= lostCount %>],
            backgroundColor: ["#38bdf8", "#34d399", "#f87171"]
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "bottom" } }
    }
});

const activityLabels = [<%= activityLabels %>];
const activityData = [<%= activityData %>];

const activityChart = new Chart(document.getElementById("activityChart"), {
    type: "line",
    data: {
        labels: activityLabels,
        datasets: [{
            label: "Activity",
            data: activityData,
            borderColor: "#22c55e",
            backgroundColor: "rgba(34, 197, 94, 0.2)",
            fill: true,
            tension: 0.3
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            y: { beginAtZero: true }
        }
    }
});

</script>
</body>
</html>
