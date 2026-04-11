<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">
</head>
<body>
    <%
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/auth/login.jsp");
            return;
        }

        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/view/auth/change-password.jsp");
            return;
        }

        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/view/dashboard/home.jsp");
            return;
        }

        String currentDate = LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy"));
        int hour = LocalTime.now().getHour();
        String greeting;
        if (hour < 12) {
            greeting = "Good morning";
        } else if (hour < 17) {
            greeting = "Good afternoon";
        } else {
            greeting = "Good evening";
        }

        String userName = user.getName() != null ? user.getName() : "Admin";
        String avatarLetter = userName.trim().isEmpty() ? "A" : userName.substring(0, 1).toUpperCase();
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
        }
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = "SmartCRM";
        }
        String companyInitial = companyName.substring(0, 1).toUpperCase();
    %>

    <div class="saas-shell">
        <header class="saas-topnav">
            <div class="saas-topnav-left">SmartCRM</div>

            <div class="saas-topnav-center">
                <input type="text" class="saas-search" placeholder="Search users, customers, reports...">
            </div>

            <div class="saas-topnav-right">
                <span class="saas-topnav-icon">&#128276;</span>
                <span class="saas-topnav-icon">&#9881;</span>
                <div class="saas-profile-chip saas-profile-topnav">
                    <div class="saas-avatar"><%= avatarLetter %></div>
                    <div class="saas-profile-meta">
                        <strong><%= userName %></strong>
                        <span><%= companyName %></span>
                    </div>
                    <span class="saas-dropdown">&#9662;</span>
                </div>
            </div>
        </header>

        <aside class="saas-sidebar">
            <div class="saas-logo">
                <span class="saas-logo-mark"><%= companyInitial %></span>
                <span class="saas-logo-text"><%= companyName %></span>
            </div>

            <nav class="saas-nav">
                <a href="${pageContext.request.contextPath}/view/dashboard/admin-dashboard.jsp" class="saas-nav-item active">
                    <span class="saas-nav-icon">&#8962;</span>
                    <span class="saas-nav-label">Dashboard</span>
                </a>
                <a href="#" class="saas-nav-item">
                    <span class="saas-nav-icon">&#9782;</span>
                    <span class="saas-nav-label">Customers</span>
                </a>
                <%
                    if ("admin".equalsIgnoreCase(user.getRole())) {
                %>
                <a href="${pageContext.request.contextPath}/manage-users" class="saas-nav-item">
                    <span class="saas-nav-icon">&#128101;</span>
                    <span class="saas-nav-label">Manage Users</span>
                </a>
                <%
                    }
                %>
                <a href="#" class="saas-nav-item">
                    <span class="saas-nav-icon">&#128221;</span>
                    <span class="saas-nav-label">Reports</span>
                </a>
                <a href="#" class="saas-nav-item">
                    <span class="saas-nav-icon">&#9881;</span>
                    <span class="saas-nav-label">Settings</span>
                </a>
            </nav>

            <form action="${pageContext.request.contextPath}/logout" method="POST" class="saas-logout-form">
                <button type="submit" class="saas-nav-item saas-logout-btn">
                    <span class="saas-nav-icon">&#10162;</span>
                    <span class="saas-nav-label">Logout</span>
                </button>
            </form>
        </aside>

        <main class="saas-main">
            <section class="saas-welcome-block">
                <p class="saas-date"><%= currentDate %></p>
                <h1><%= greeting %>, <%= userName %></h1>
            </section>

            <section class="saas-card-grid">
                <article class="saas-card">
                    <p class="saas-card-title">Total Users</p>
                    <h3>32</h3>
                    <span class="saas-card-hint">Registered accounts in system</span>
                </article>
                <article class="saas-card">
                    <p class="saas-card-title">Total Customers</p>
                    <h3>462</h3>
                    <span class="saas-card-hint">Across all teams</span>
                </article>
                <article class="saas-card">
                    <p class="saas-card-title">Activity</p>
                    <h3>76</h3>
                    <span class="saas-card-hint">Actions in last 24 hours</span>
                </article>
            </section>

            <div class="saas-content-grid">
                <section class="saas-panel">
                    <h3>Tasks</h3>
                    <ul class="saas-list">
                        <li>Review pending user account approvals</li>
                        <li>Audit customer import activity logs</li>
                        <li>Verify report access permissions</li>
                    </ul>
                </section>

                <section class="saas-panel">
                    <h3>Recent Activity</h3>
                    <ul class="saas-list">
                        <li>3 users created in the last 24 hours</li>
                        <li>Monthly report exported by operations</li>
                        <li>Customer data sync completed 1 hour ago</li>
                    </ul>
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
</body>
</html>
