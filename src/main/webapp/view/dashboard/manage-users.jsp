<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users - SmartCRM</title>
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
        List<User> teamMembers = (List<User>) request.getAttribute("teamMembers");
        Integer memberCountAttr = (Integer) request.getAttribute("memberCount");
        int memberCount = memberCountAttr != null ? memberCountAttr : 0;
        String searchQuery = (String) request.getAttribute("searchQuery");
        if (searchQuery == null) {
            searchQuery = "";
        }
        String roleFilter = (String) request.getAttribute("roleFilter");
        if (roleFilter == null || roleFilter.trim().isEmpty()) {
            roleFilter = "all";
        }
        Integer totalUsersCountAttr = (Integer) request.getAttribute("totalUsersCount");
        Integer adminsCountAttr = (Integer) request.getAttribute("adminsCount");
        Integer usersCountAttr = (Integer) request.getAttribute("usersCount");
        int totalUsersCount = totalUsersCountAttr != null ? totalUsersCountAttr : 0;
        int adminsCount = adminsCountAttr != null ? adminsCountAttr : 0;
        int usersCount = usersCountAttr != null ? usersCountAttr : 0;
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
                <a href="${pageContext.request.contextPath}/view/dashboard/admin-dashboard.jsp" class="saas-nav-item">
                    <span class="saas-nav-icon">&#8962;</span>
                    <span class="saas-nav-label">Dashboard</span>
                </a>
                <a href="#" class="saas-nav-item">
                    <span class="saas-nav-icon">&#9782;</span>
                    <span class="saas-nav-label">Customers</span>
                </a>
                <a href="${pageContext.request.contextPath}/manage-users" class="saas-nav-item active">
                    <span class="saas-nav-icon">&#128101;</span>
                    <span class="saas-nav-label">Manage Users</span>
                </a>
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

            <%
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                if (error != null) {
            %>
                <div class="error-message"><%= error %></div>
            <%
                }
                if (success != null) {
            %>
                <div class="success-message"><%= success %></div>
            <%
                }
            %>

            <section class="manage-users-wrapper">
                <section class="container-top">
                    <article class="card create-user-card">
                        <h3>Create User</h3>
                        <p class="saas-form-help">New users are created under <strong><%= companyName %></strong> with role <strong>user</strong>.</p>

                        <form action="${pageContext.request.contextPath}/manage-users" method="POST" class="saas-form-grid">
                            <input type="hidden" name="action" value="create">
                            <input type="hidden" name="search" value="<%= searchQuery %>">
                            <input type="hidden" name="role" value="<%= roleFilter %>">
                            <div class="form-group">
                                <label for="name">Name</label>
                                <input type="text" id="name" name="name" required>
                            </div>

                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" required>
                            </div>

                            <button type="submit" class="login-submit-btn">Create User</button>
                        </form>
                    </article>

                    <section class="stats-container">
                        <article class="card stat-card">
                            <p class="stat-label">Total Users</p>
                            <h3 class="stat-value"><%= totalUsersCount %></h3>
                        </article>
                        <article class="card stat-card">
                            <p class="stat-label">Admins</p>
                            <h3 class="stat-value"><%= adminsCount %></h3>
                        </article>
                        <article class="card stat-card">
                            <p class="stat-label">Users</p>
                            <h3 class="stat-value"><%= usersCount %></h3>
                        </article>
                    </section>
                </section>

                <section class="card users-toolbar">
                    <form action="${pageContext.request.contextPath}/manage-users" method="GET" class="users-search-form">
                        <input type="text" name="search" value="<%= searchQuery %>" placeholder="Search team members..." class="users-search-input">
                        <select name="role" class="users-role-filter">
                            <option value="all" <%= "all".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>All</option>
                            <option value="admin" <%= "admin".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>Admin</option>
                            <option value="user" <%= "user".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>User</option>
                        </select>
                        <button type="submit" class="users-search-btn">Search</button>
                    </form>
                    <span class="member-count">Total Members: <%= memberCount %></span>
                </section>

                <article class="card users-table-card">
                    <div class="table-header">
                        <h3>Team Members</h3>
                        <span class="member-count">Total Members: <%= memberCount %></span>
                    </div>

                    <%
                        if (teamMembers == null || teamMembers.isEmpty()) {
                    %>
                        <div class="team-empty-state"><%= searchQuery.isEmpty() ? "No team members yet" : "No matching team members found" %></div>
                    <%
                        } else {
                    %>
                        <div class="team-table-wrap">
                            <table class="users-table">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Email</th>
                                        <th>Role</th>
                                        <th style="text-align:right;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (User member : teamMembers) {
                                            String role = member.getRole() == null ? "user" : member.getRole();
                                            String roleClass = "admin".equalsIgnoreCase(role) ? "role-badge role-admin" : "role-badge role-user";
                                    %>
                                    <tr id="view-row-<%= member.getId() %>">
                                        <td>
                                            <div class="user-name-cell">
                                                <span class="user-avatar"><%= member.getName() == null || member.getName().trim().isEmpty() ? "U" : member.getName().trim().substring(0, 1).toUpperCase() %></span>
                                                <span><%= member.getName() %></span>
                                            </div>
                                        </td>
                                        <td><%= member.getEmail() %></td>
                                        <td><span class="<%= roleClass %>"><%= role %></span></td>
                                        <td>
                                            <div class="actions">
                                                <button type="button" class="action-btn edit" onclick="showEditRow(<%= member.getId() %>)">Edit</button>
                                                <form action="${pageContext.request.contextPath}/manage-users" method="POST" onsubmit="return confirm('Delete this user?');" class="inline-delete-form">
                                                    <input type="hidden" name="action" value="deleteUser">
                                                    <input type="hidden" name="userId" value="<%= member.getId() %>">
                                                    <input type="hidden" name="search" value="<%= searchQuery %>">
                                                    <input type="hidden" name="role" value="<%= roleFilter %>">
                                                    <button type="submit" class="action-btn delete">Delete</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr id="edit-row-<%= member.getId() %>" class="edit-row" style="display:none;">
                                        <td colspan="4">
                                            <form action="${pageContext.request.contextPath}/manage-users" method="POST" class="inline-edit-form">
                                                <input type="hidden" name="action" value="updateUser">
                                                <input type="hidden" name="userId" value="<%= member.getId() %>">
                                                <input type="hidden" name="search" value="<%= searchQuery %>">
                                                <input type="hidden" name="role" value="<%= roleFilter %>">
                                                <input type="text" name="name" value="<%= member.getName() %>" class="inline-name-input" required>
                                                <div class="actions">
                                                    <button type="submit" class="action-btn edit">Save</button>
                                                    <button type="button" class="action-btn" onclick="hideEditRow(<%= member.getId() %>)">Cancel</button>
                                                </div>
                                            </form>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                                                                <div class="team-empty-state">
                                                                    <p class="empty-title">No team members yet</p>
                                                                    <p class="empty-subtitle"><%= searchQuery.isEmpty() && "all".equalsIgnoreCase(roleFilter) ? "Start by adding your first user" : "Try adjusting search or role filter" %></p>
                                                                </div>
                        </div>
                    <%
                        }
                    %>
                </article>
            </section>
        </main>
    </div>

    <script>
        function showEditRow(userId) {
            const viewRow = document.getElementById('view-row-' + userId);
            const editRow = document.getElementById('edit-row-' + userId);
            if (viewRow && editRow) {
                viewRow.style.display = 'none';
                editRow.style.display = '';
            }
        }

        function hideEditRow(userId) {
            const viewRow = document.getElementById('view-row-' + userId);
            const editRow = document.getElementById('edit-row-' + userId);
            if (viewRow && editRow) {
                editRow.style.display = 'none';
                viewRow.style.display = '';
            }
        }
    </script>
</body>
</html>
