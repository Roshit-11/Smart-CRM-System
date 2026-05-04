<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260504b">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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

        int unreadNotifications = 0;
        try {
            unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
        } catch (Exception ignored) {
        }

        request.setAttribute("unreadNotifications", unreadNotifications);
        request.setAttribute("activeNav", "users");
        request.setAttribute("topSearchPlaceholder", "Search users, customers, reports...");
    %>

    <div class="saas-shell">

        <!-- TOP NAV -->
        <jsp:include page="/view/components/top-navbar.jsp" />

        <!-- SIDEBAR -->
        <jsp:include page="/view/components/admin-sidebar.jsp" />

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
                    <i data-lucide="user-plus"></i>&nbsp; Add User
                </button>
            </div>

            <!-- Flash messages -->
            <%
                String error   = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                if (error != null) {
            %>
                <div class="mu-alert mu-alert-error"><i data-lucide="alert-triangle"></i>&nbsp; <%= error %></div>
            <% } if (success != null) { %>
                <div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i>&nbsp; <%= success %></div>
            <% } %>

            <!-- STAT CARDS -->
            <div class="mu-stats-row">
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-blue"><i data-lucide="users"></i></div>
                    <div>
                        <p class="mu-stat-label">Total Users</p>
                        <p class="mu-stat-value"><%= totalUsersCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-purple"><i data-lucide="shield"></i></div>
                    <div>
                        <p class="mu-stat-label">Admins</p>
                        <p class="mu-stat-value"><%= adminsCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-green"><i data-lucide="user"></i></div>
                    <div>
                        <p class="mu-stat-label">Regular Users</p>
                        <p class="mu-stat-value"><%= usersCount %></p>
                    </div>
                </div>
                <div class="mu-stat-card">
                    <div class="mu-stat-icon-wrap mu-ic-slate"><i data-lucide="filter"></i></div>
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
                    <button type="button" class="mu-close-btn" onclick="toggleCreatePanel()"><i data-lucide="x"></i></button>
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
                            <button type="submit" class="mu-btn-primary mu-btn-full"><i data-lucide="user-plus"></i>&nbsp; Create User</button>
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
                            <span class="mu-search-icon"><i data-lucide="search"></i></span>
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
                        <div class="mu-empty-icon"><i data-lucide="users"></i></div>
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
                                            <button type="button" class="mu-btn-edit" onclick="showEditRow(<%= member.getId() %>)" aria-label="Edit user" title="Edit">
                                                <i class="fa-solid fa-pen-to-square action-icon edit"></i>
                                            </button>
                                            <form action="${pageContext.request.contextPath}/manage-users" method="POST"
                                                  onsubmit="return confirm('Delete <%= member.getName() %>? This cannot be undone.');"
                                                  style="display:inline;">
                                                <input type="hidden" name="action"  value="deleteUser">
                                                <input type="hidden" name="userId"  value="<%= member.getId() %>">
                                                <input type="hidden" name="search"  value="<%= searchQuery %>">
                                                <input type="hidden" name="role"    value="<%= roleFilter %>">
                                                <button type="submit" class="mu-btn-delete" aria-label="Delete user" title="Delete">
                                                    <i class="fa-solid fa-trash action-icon delete"></i>
                                                </button>
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
                                                <button type="submit" class="mu-btn-save"><i data-lucide="check"></i> Save</button>
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

    <jsp:include page="/view/components/notifications-panel.jsp" />

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
