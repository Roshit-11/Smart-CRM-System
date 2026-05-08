<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.IssueReport" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contact Admin - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260511">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (user.isFirstLogin()) { response.sendRedirect(request.getContextPath() + "/change-password"); return; }

    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) companyName = user.getCompanyName();
    if (companyName == null || companyName.trim().isEmpty()) companyName = "SmartCRM";

    int unreadNotifications = 0;
    try {
        unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
    } catch (Exception ignored) {}

    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "contact-admin");

    @SuppressWarnings("unchecked")
    List<IssueReport> myIssues = (List<IssueReport>) request.getAttribute("myIssues");

    String formError = (String) session.getAttribute("issueFormError");
    String formSuccess = (String) session.getAttribute("issueFormSuccess");
    if (formError != null) session.removeAttribute("issueFormError");
    if (formSuccess != null) session.removeAttribute("issueFormSuccess");
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <jsp:include page="/view/components/user-sidebar.jsp" />

    <main class="saas-main">
        <section class="saas-welcome-block">
            <p class="saas-date">Need help? Report an issue or contact your admin.</p>
            <h1>Contact Admin</h1>
        </section>

        <% if (formError != null) { %>
            <div class="mu-alert mu-alert-error"><i data-lucide="alert-triangle"></i>&nbsp; <%= formError %></div>
        <% } %>
        <% if (formSuccess != null) { %>
            <div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i>&nbsp; <%= formSuccess %></div>
        <% } %>

        <div class="ca-grid">
            <%-- Submit Issue Form --%>
            <section class="ca-form-card">
                <div class="ca-form-header">
                    <div class="ca-form-icon"><i data-lucide="message-square-warning"></i></div>
                    <div>
                        <h3>Submit a New Issue</h3>
                        <p>Report a bug, request a feature, or report a user.</p>
                    </div>
                </div>

                <form method="POST" action="${pageContext.request.contextPath}/contact-admin" class="ca-form">
                    <input type="hidden" name="action" value="createIssue">

                    <div class="ca-field">
                        <label>From</label>
                        <div class="ca-readonly">
                            <i data-lucide="user"></i>
                            <span><%= user.getName() %> &middot; <%= user.getEmail() %></span>
                        </div>
                    </div>

                    <div class="ca-field-row">
                        <div class="ca-field">
                            <label for="issueType">Issue Type *</label>
                            <select id="issueType" name="issueType" required>
                                <option value="">Select a type</option>
                                <option value="Bug">🐛 Bug Report</option>
                                <option value="Feature Request">✨ Feature Request</option>
                                <option value="User Report">👤 Report a User</option>
                                <option value="Account">🔐 Account Issue</option>
                                <option value="Performance">⚡ Performance</option>
                                <option value="Other">📝 Other</option>
                            </select>
                        </div>
                        <div class="ca-field">
                            <label for="priority">Priority</label>
                            <select id="priority" name="priority">
                                <option value="Low">Low</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="High">High</option>
                            </select>
                        </div>
                    </div>

                    <div class="ca-field">
                        <label for="subject">Subject *</label>
                        <input type="text" id="subject" name="subject" placeholder="Brief title for your issue" maxlength="200" required>
                    </div>

                    <div class="ca-field">
                        <label for="description">Description *</label>
                        <textarea id="description" name="description" rows="6" placeholder="Describe the issue in detail. Include steps to reproduce if it's a bug, or the user's name if reporting a user." required></textarea>
                        <p class="ca-hint">Be as specific as possible. Include screenshots if helpful.</p>
                    </div>

                    <div class="ca-form-actions">
                        <button type="submit" class="ca-btn-primary"><i data-lucide="send"></i> Submit Issue</button>
                    </div>
                </form>
            </section>

            <%-- My Issues History --%>
            <section class="ca-history-card">
                <div class="ca-form-header">
                    <div class="ca-form-icon ca-form-icon--secondary"><i data-lucide="inbox"></i></div>
                    <div>
                        <h3>My Reported Issues</h3>
                        <p><%= myIssues == null ? 0 : myIssues.size() %> issue<%= (myIssues != null && myIssues.size() == 1) ? "" : "s" %> submitted</p>
                    </div>
                </div>

                <div class="ca-history-list">
                    <% if (myIssues == null || myIssues.isEmpty()) { %>
                        <div class="ca-empty">
                            <i data-lucide="inbox"></i>
                            <p>You haven't submitted any issues yet.</p>
                        </div>
                    <% } else {
                        for (IssueReport issue : myIssues) {
                            String statusClass = "ca-status--open";
                            if ("In Progress".equalsIgnoreCase(issue.getStatus())) statusClass = "ca-status--progress";
                            else if ("Resolved".equalsIgnoreCase(issue.getStatus())) statusClass = "ca-status--resolved";
                            else if ("Closed".equalsIgnoreCase(issue.getStatus())) statusClass = "ca-status--closed";
                            String priorityClass = "priority-badge--medium";
                            if ("High".equalsIgnoreCase(issue.getPriority())) priorityClass = "priority-badge--high";
                            else if ("Low".equalsIgnoreCase(issue.getPriority())) priorityClass = "priority-badge--low";
                    %>
                        <article class="ca-history-item">
                            <div class="ca-history-item-head">
                                <span class="ca-type-tag"><%= issue.getIssueType() %></span>
                                <span class="ca-status-tag <%= statusClass %>"><%= issue.getStatus() %></span>
                                <span class="priority-badge <%= priorityClass %>"><%= issue.getPriority() %></span>
                            </div>
                            <h4><%= issue.getSubject() %></h4>
                            <p class="ca-history-desc"><%= issue.getDescription() %></p>
                            <% if (issue.getAdminResponse() != null && !issue.getAdminResponse().isEmpty()) { %>
                                <div class="ca-admin-response">
                                    <strong><i data-lucide="shield-check"></i> Admin Response:</strong>
                                    <p><%= issue.getAdminResponse() %></p>
                                </div>
                            <% } %>
                            <div class="ca-history-foot">
                                <span class="ca-history-time"><i data-lucide="clock"></i> <%= issue.getCreatedAt() %></span>
                                <% if (!"Resolved".equalsIgnoreCase(issue.getStatus()) && !"Closed".equalsIgnoreCase(issue.getStatus())) { %>
                                <form method="POST" action="${pageContext.request.contextPath}/contact-admin" class="ca-inline-form">
                                    <input type="hidden" name="action" value="deleteIssue">
                                    <input type="hidden" name="issueId" value="<%= issue.getId() %>">
                                    <button type="submit" class="ca-btn-icon" data-confirm-delete title="Delete"><i data-lucide="trash-2"></i></button>
                                </form>
                                <% } %>
                            </div>
                        </article>
                    <% }} %>
                </div>
            </section>
        </div>
    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />
</body>
</html>
