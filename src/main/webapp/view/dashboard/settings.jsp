<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="com.crm.app.model.CompanySettings" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Settings - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260508">
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

    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) companyName = user.getCompanyName();
    if (companyName == null || companyName.trim().isEmpty()) companyName = "SmartCRM";

    int unreadNotifications = 0;
    try {
        unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
    } catch (Exception ignored) {}

    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "settings");
    request.setAttribute("topSearchPlaceholder", "Search settings...");

    Integer totalUsersAttr = (Integer) request.getAttribute("totalUsers");
    Integer totalCustomersAttr = (Integer) request.getAttribute("totalCustomers");
    int totalUsers = totalUsersAttr != null ? totalUsersAttr : 0;
    int totalCustomers = totalCustomersAttr != null ? totalCustomersAttr : 0;

    boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
    CompanySettings companyEmailSettings = (CompanySettings) request.getAttribute("companyEmailSettings");
    boolean hasPendingOtp = session.getAttribute("companyEmailOtp") != null;
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <% if (isAdmin) { %>
        <jsp:include page="/view/components/admin-sidebar.jsp" />
    <% } else { %>
        <jsp:include page="/view/components/user-sidebar.jsp" />
    <% } %>

    <main class="saas-main">
        <section class="saas-welcome-block">
            <p class="saas-date">Company: <strong><%= companyName %></strong></p>
            <h1>Settings</h1>
        </section>

        <%
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            if (error != null) {
        %>
            <div class="mu-alert mu-alert-error"><i data-lucide="alert-triangle"></i>&nbsp; <%= error %></div>
        <% } if (success != null) { %>
            <div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i>&nbsp; <%= success %></div>
        <% } %>

        <div class="settings-tabs" role="tablist">
            <button type="button" class="settings-tab active" data-tab="profile" role="tab"><i data-lucide="user"></i> Profile</button>
            <button type="button" class="settings-tab" data-tab="password" role="tab"><i data-lucide="lock"></i> Password</button>
            <button type="button" class="settings-tab" data-tab="notifications" role="tab"><i data-lucide="bell"></i> Notifications</button>
            <button type="button" class="settings-tab" data-tab="appearance" role="tab"><i data-lucide="palette"></i> Appearance</button>
            <button type="button" class="settings-tab" data-tab="email" role="tab"><i data-lucide="mail"></i> Email</button>
            <% if (isAdmin) { %>
            <button type="button" class="settings-tab" data-tab="company" role="tab"><i data-lucide="building-2"></i> Company</button>
            <% } %>
        </div>

        <div class="settings-pane active" data-pane="profile">
            <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form">
                <input type="hidden" name="action" value="updateProfile">
                <div class="form-row">
                    <label for="profileName">Name</label>
                    <input type="text" id="profileName" name="name" value="<%= user.getName() == null ? "" : user.getName() %>" required>
                </div>
                <div class="form-row">
                    <label for="profileEmail">Email</label>
                    <input type="email" id="profileEmail" name="email" value="<%= user.getEmail() == null ? "" : user.getEmail() %>" required>
                </div>
                <div class="settings-actions">
                    <button type="submit" class="mu-btn-primary">Save Profile</button>
                </div>
            </form>
        </div>

        <div class="settings-pane" data-pane="password">
            <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form">
                <input type="hidden" name="action" value="changePassword">
                <div class="form-row">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" minlength="8" required data-password-strength>
                    <div class="password-strength" style="background:#e2e8f0;"><div class="password-strength-bar" data-strength="0"></div></div>
                </div>
                <div class="settings-actions">
                    <button type="submit" class="mu-btn-primary">Update Password</button>
                </div>
            </form>
        </div>

        <div class="settings-pane" data-pane="notifications">
            <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form">
                <input type="hidden" name="action" value="updateNotifications">

                <div class="settings-toggle-row">
                    <div>
                        <strong>Customer Assignment</strong>
                        <span>Get notified when a customer is assigned to you</span>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" name="notify_customer_assign" <%= user.isNotifyCustomerAssign() ? "checked" : "" %>>
                        <span class="toggle-switch-slider"></span>
                    </label>
                </div>

                <div class="settings-toggle-row">
                    <div>
                        <strong>Task Assignment</strong>
                        <span>Get notified when a task is assigned to you</span>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" name="notify_task_assign" <%= user.isNotifyTaskAssign() ? "checked" : "" %>>
                        <span class="toggle-switch-slider"></span>
                    </label>
                </div>

                <div class="settings-toggle-row">
                    <div>
                        <strong>Task Updates</strong>
                        <span>Get notified when a task status changes</span>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" name="notify_task_update" <%= user.isNotifyTaskUpdate() ? "checked" : "" %>>
                        <span class="toggle-switch-slider"></span>
                    </label>
                </div>

                <div class="settings-actions">
                    <button type="submit" class="mu-btn-primary">Save Preferences</button>
                </div>
            </form>
        </div>

        <div class="settings-pane" data-pane="appearance">
            <div class="settings-form">
                <div class="settings-toggle-row">
                    <div>
                        <strong>Dark Mode</strong>
                        <span>Switch the interface to a darker color palette. Saved on this device.</span>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" id="darkModeToggle">
                        <span class="toggle-switch-slider"></span>
                    </label>
                </div>
            </div>
        </div>

        <div class="settings-pane" data-pane="email">
            <div class="settings-form">
                <div class="form-row">
                    <label>Linked Email</label>
                    <input type="text" value="<%= companyEmailSettings != null && companyEmailSettings.getSmtpEmail() != null ? companyEmailSettings.getSmtpEmail() : "Not linked" %>" readonly>
                </div>
                <div class="form-row">
                    <label>Status</label>
                    <input type="text" value="<%= companyEmailSettings != null && companyEmailSettings.isVerified() ? "Verified" : "Not verified" %>" readonly>
                </div>
            </div>

            <% if (isAdmin) { %>
                <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form" style="margin-top: 16px;">
                    <input type="hidden" name="action" value="sendCompanyEmailOtp">
                    <div class="form-row">
                        <label for="smtpEmail">SMTP Email</label>
                        <input type="email" id="smtpEmail" name="smtpEmail" placeholder="company@gmail.com" required>
                    </div>
                    <div class="form-row">
                        <label for="smtpPassword">App Password</label>
                        <input type="password" id="smtpPassword" name="smtpPassword" placeholder="App password" required>
                    </div>
                    <div class="settings-actions">
                        <button type="submit" class="mu-btn-primary">Send Verification Code</button>
                    </div>
                </form>

                <% if (hasPendingOtp) { %>
                    <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form" style="margin-top: 16px;">
                        <input type="hidden" name="action" value="verifyCompanyEmailOtp">
                        <div class="form-row">
                            <label for="verificationCode">Enter Verification Code</label>
                            <input type="text" id="verificationCode" name="verificationCode" placeholder="6-digit code" required>
                        </div>
                        <div class="settings-actions">
                            <button type="submit" class="mu-btn-primary">Verify Email</button>
                        </div>
                    </form>
                <% } %>

                <% if (companyEmailSettings != null && companyEmailSettings.isVerified()) { %>
                    <form action="${pageContext.request.contextPath}/settings" method="POST" class="settings-form" style="margin-top: 16px;">
                        <input type="hidden" name="action" value="unlinkCompanyEmail">
                        <div class="settings-actions">
                            <button type="submit" class="mu-btn-primary">Unlink Email</button>
                        </div>
                    </form>
                <% } %>
            <% } %>
        </div>

        <% if (isAdmin) { %>
        <div class="settings-pane" data-pane="company">
            <section class="saas-card-grid">
                <article class="saas-card">
                    <div class="saas-card-icon"><i data-lucide="users"></i></div>
                    <p class="saas-card-title">Total Users</p>
                    <h3><%= totalUsers %></h3>
                    <span class="saas-card-hint">Members of <%= companyName %></span>
                </article>
                <article class="saas-card card-accent-green">
                    <div class="saas-card-icon"><i data-lucide="briefcase"></i></div>
                    <p class="saas-card-title">Total Customers</p>
                    <h3><%= totalCustomers %></h3>
                    <span class="saas-card-hint">Across all teams</span>
                </article>
            </section>

            <div class="settings-form" style="margin-top: 20px;">
                <div class="form-row">
                    <label>Company Name</label>
                    <input type="text" value="<%= companyName %>" readonly>
                </div>
                <div class="form-row">
                    <label>Your Role</label>
                    <input type="text" value="<%= user.getRole() %>" readonly>
                </div>
            </div>
        </div>
        <% } %>

        <section class="saas-panel profile-details" style="margin-top: 24px;">
            <h3>Account Info</h3>
            <div class="saas-info-row"><span>Company</span><strong><%= companyName %></strong></div>
            <div class="saas-info-row"><span>Role</span><strong><%= user.getRole() %></strong></div>
            <div class="saas-info-row"><span>User ID</span><strong><%= user.getId() %></strong></div>
        </section>
    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />

<script>
(function () {
    var tabs = document.querySelectorAll(".settings-tab");
    var panes = document.querySelectorAll(".settings-pane");
    tabs.forEach(function (tab) {
        tab.addEventListener("click", function () {
            var name = tab.getAttribute("data-tab");
            tabs.forEach(function (t) { t.classList.remove("active"); });
            panes.forEach(function (p) { p.classList.remove("active"); });
            tab.classList.add("active");
            var pane = document.querySelector('[data-pane="' + name + '"]');
            if (pane) pane.classList.add("active");
        });
    });
})();
</script>
</body>
</html>
