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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260412">
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
        if (hour < 12) greeting = "Good morning";
        else if (hour < 17) greeting = "Good afternoon";
        else greeting = "Good evening";

        String userName = user.getName() != null ? user.getName() : "Admin";
        String avatarLetter = userName.trim().isEmpty() ? "A" : userName.substring(0, 1).toUpperCase();

        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) companyName = user.getCompanyName();
        if (companyName == null || companyName.trim().isEmpty()) companyName = "SmartCRM";
        String companyInitial = companyName.substring(0, 1).toUpperCase();

        List<User> teamMembers = (List<User>) request.getAttribute("teamMembers");
        Integer memberCountAttr = (Integer) request.getAttribute("memberCount");
        int memberCount = memberCountAttr != null ? memberCountAttr : 0;
        String searchQuery = (String) request.getAttribute("searchQuery");
        if (searchQuery == null) searchQuery = "";
        String roleFilter = (String) request.getAttribute("roleFilter");
        if (roleFilter == null || roleFilter.trim().isEmpty()) roleFilter = "all";

        Integer totalUsersCountAttr = (Integer) request.getAttribute("totalUsersCount");
        Integer adminsCountAttr     = (Integer) request.getAttribute("adminsCount");
        Integer usersCountAttr      = (Integer) request.getAttribute("usersCount");
        int totalUsersCount = totalUsersCountAttr != null ? totalUsersCountAttr : 0;
        int adminsCount     = adminsCountAttr     != null ? adminsCountAttr     : 0;
        int usersCount      = usersCountAttr      != null ? usersCountAttr      : 0;
    %>

    <div class="saas-shell">

        <!-- TOP NAV -->
        <header class="saas-topnav">
            <div class="saas-topnav-left">SmartCRM</div>
            <div class="saas-topnav-center">
                <input type="text" class="saas-search" placeholder="Search users, customers, reports…">
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

        <!-- SIDEBAR -->
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

        <!-- MAIN -->
        <main class="saas-main mu-main">

            <!-- Page header -->
            <div class="mu-page-header">
                <div>
                    <p class="saas-date"><%= currentDate %></p>
                    <h1 class="mu-page-title"><%= greeting %>, <%= userName %></h1>
                    <p class="mu-page-sub">Managing team for <strong><%= companyName %></strong></p>
                </div>
                <button type="button" class="mu-btn-primary" onclick="toggleCreatePanel()">
                    &#43;&nbsp; Add User
                </button>
            </div>

            <!-- Flash messages -->
            <%
                String error   = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                if (error != null) {
            %>
                <div class="mu-alert mu-alert-error">&#9888;&nbsp; <%= error %></div>
            <% } if (success != null) { %>
                <div class="mu-alert mu-alert-success">&#10003;&nbsp; <%= success %></div>
            <% } %>

            <!-- STAT CARDS -->
            <div class="mu-stats-row">
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-blue">&#128101;</div>
                    <div>
                        <p class="mu-stat-label">Total Users</p>
                        <p class="mu-stat-value"><%= totalUsersCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-purple">&#128274;</div>
                    <div>
                        <p class="mu-stat-label">Admins</p>
                        <p class="mu-stat-value"><%= adminsCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-green">&#128100;</div>
                    <div>
                        <p class="mu-stat-label">Regular Users</p>
                        <p class="mu-stat-value"><%= usersCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-slate">&#128203;</div>
                    <div>
                        <p class="mu-stat-label">Filtered Results</p>
                        <p class="mu-stat-value"><%= memberCount %></p>
                    </div>
                </div>
            </div>

            <!-- CREATE USER PANEL -->
            <div class="mu-create-panel" id="createUserPanel" style="display:none;">
                <div class="mu-create-header">
                    <div>
                        <h3 class="mu-create-title">Create New User</h3>
                        <p class="mu-create-sub">New users join <strong><%= companyName %></strong> with the <strong>user</strong> role and will be prompted to set a password on first login.</p>
                    </div>
                    <button type="button" class="mu-close-btn" onclick="toggleCreatePanel()">&#10005;</button>
                </div>
                <form action="${pageContext.request.contextPath}/manage-users" method="POST" class="mu-create-form">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="search" value="<%= searchQuery %>">
                    <input type="hidden" name="role"   value="<%= roleFilter %>">
                    <div class="mu-form-row">
                        <div class="mu-field">
                            <label for="create-name">Full Name</label>
                            <input type="text"  id="create-name"  name="name"  placeholder="e.g. Alex Johnson"       required>
                        </div>
                        <div class="mu-field">
                            <label for="create-email">Email Address</label>
                            <input type="email" id="create-email" name="email" placeholder="e.g. alex@company.com"   required>
                        </div>
                        <div class="mu-field mu-field-btn">
                            <label>&nbsp;</label>
                            <button type="submit" class="mu-btn-primary mu-btn-full">&#43;&nbsp; Create User</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- USERS TABLE CARD -->
            <div class="mu-table-card">

                <!-- Toolbar -->
                <div class="mu-toolbar">
                    <div class="mu-toolbar-left">
                        <h2 class="mu-table-heading">Team Members</h2>
                        <span class="mu-count-badge"><%= memberCount %> member<%= memberCount != 1 ? "s" : "" %></span>
                    </div>
                    <form action="${pageContext.request.contextPath}/manage-users" method="GET" class="mu-filter-form">
                        <div class="mu-search-wrap">
                            <span class="mu-search-icon">&#128269;</span>
                            <input type="text" name="search"
                                   value="<%= searchQuery %>"
                                   placeholder="Search name or email…"
                                   class="mu-search-input">
                        </div>
                        <select name="role" class="mu-role-select">
                            <option value="all"   <%= "all".equalsIgnoreCase(roleFilter)   ? "selected" : "" %>>All roles</option>
                            <option value="admin" <%= "admin".equalsIgnoreCase(roleFilter) ? "selected" : "" %>>Admin</option>
                            <option value="user"  <%= "user".equalsIgnoreCase(roleFilter)  ? "selected" : "" %>>User</option>
                        </select>
                        <button type="submit" class="mu-btn-filter">Apply</button>
                    </form>
                </div>

                <!-- Table / empty state -->
                <% if (teamMembers == null || teamMembers.isEmpty()) { %>
                    <div class="mu-empty-state">
                        <div class="mu-empty-icon">&#128101;</div>
                        <p class="mu-empty-title"><%= searchQuery.isEmpty() ? "No team members yet" : "No results found" %></p>
                        <p class="mu-empty-sub"><%= searchQuery.isEmpty() && "all".equalsIgnoreCase(roleFilter)
                            ? "Click \"Add User\" to invite your first team member."
                            : "Try adjusting your search term or role filter." %></p>
                    </div>
                <% } else { %>
                    <div class="mu-table-wrap">
                        <table class="mu-table">
                            <thead>
                                <tr>
                                    <th>Member</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th class="mu-th-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                for (User member : teamMembers) {
                                    String mRole      = member.getRole() == null ? "user" : member.getRole();
                                    String mRoleCls   = "admin".equalsIgnoreCase(mRole) ? "mu-badge mu-badge-admin" : "mu-badge mu-badge-user";
                                    String mInitial   = (member.getName() == null || member.getName().trim().isEmpty())
                                                        ? "U" : member.getName().trim().substring(0,1).toUpperCase();
                            %>
                                <tr id="view-row-<%= member.getId() %>">
                                    <td>
                                        <div class="mu-name-cell">
                                            <span class="mu-avatar-sm"><%= mInitial %></span>
                                            <span class="mu-member-name"><%= member.getName() %></span>
                                        </div>
                                    </td>
                                    <td class="mu-td-muted"><%= member.getEmail() %></td>
                                    <td><span class="<%= mRoleCls %>"><%= mRole %></span></td>
                                    <td>
                                        <div class="mu-row-actions">
                                            <button type="button" class="mu-btn-edit" onclick="showEditRow(<%= member.getId() %>)">&#9998; Edit</button>
                                            <form action="${pageContext.request.contextPath}/manage-users" method="POST"
                                                  onsubmit="return confirm('Delete <%= member.getName() %>? This cannot be undone.');"
                                                  style="display:inline;">
                                                <input type="hidden" name="action"  value="deleteUser">
                                                <input type="hidden" name="userId"  value="<%= member.getId() %>">
                                                <input type="hidden" name="search"  value="<%= searchQuery %>">
                                                <input type="hidden" name="role"    value="<%= roleFilter %>">
                                                <button type="submit" class="mu-btn-delete">&#128465; Delete</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <tr id="edit-row-<%= member.getId() %>" style="display:none;" class="mu-edit-row">
                                    <td colspan="4">
                                        <form action="${pageContext.request.contextPath}/manage-users" method="POST" class="mu-edit-form">
                                            <input type="hidden" name="action"  value="updateUser">
                                            <input type="hidden" name="userId"  value="<%= member.getId() %>">
                                            <input type="hidden" name="search"  value="<%= searchQuery %>">
                                            <input type="hidden" name="role"    value="<%= roleFilter %>">
                                            <div class="mu-edit-inner">
                                                <span class="mu-edit-label">Editing name:</span>
                                                <input type="text" name="name" value="<%= member.getName() %>" class="mu-edit-input" required>
                                                <button type="submit" class="mu-btn-save">&#10003; Save</button>
                                                <button type="button" class="mu-btn-cancel" onclick="hideEditRow(<%= member.getId() %>)">Cancel</button>
                                            </div>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        </main>
    </div>

    <script>
        function toggleCreatePanel() {
            const panel = document.getElementById('createUserPanel');
            const isHidden = panel.style.display === 'none' || panel.style.display === '';
            panel.style.display = isHidden ? 'block' : 'none';
            if (isHidden) panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
        function showEditRow(id) {
            document.getElementById('view-row-' + id).style.display = 'none';
            document.getElementById('edit-row-' + id).style.display = '';
        }
        function hideEditRow(id) {
            document.getElementById('edit-row-' + id).style.display = 'none';
            document.getElementById('view-row-' + id).style.display = '';
        }
    </script>
</body>
</html>
