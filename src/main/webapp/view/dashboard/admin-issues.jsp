<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.IssueReport" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Issue Reports - SmartCRM Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260511">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"admin".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath() + "/dashboard"); return; }

    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) companyName = user.getCompanyName();
    if (companyName == null || companyName.trim().isEmpty()) companyName = "SmartCRM";

    int unreadNotifications = 0;
    try {
        unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
    } catch (Exception ignored) {}
    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "issues");

    @SuppressWarnings("unchecked")
    List<IssueReport> issues = (List<IssueReport>) request.getAttribute("issues");
    @SuppressWarnings("unchecked")
    Map<String, Integer> statusCounts = (Map<String, Integer>) request.getAttribute("statusCounts");
    Integer totalIssues = (Integer) request.getAttribute("totalIssues");
    String filterType = (String) request.getAttribute("filterType");
    String filterStatus = (String) request.getAttribute("filterStatus");
    if (filterType == null) filterType = "";
    if (filterStatus == null) filterStatus = "";

    int openCount = statusCounts != null && statusCounts.get("Open") != null ? statusCounts.get("Open") : 0;
    int progressCount = statusCounts != null && statusCounts.get("In Progress") != null ? statusCounts.get("In Progress") : 0;
    int resolvedCount = statusCounts != null && statusCounts.get("Resolved") != null ? statusCounts.get("Resolved") : 0;
    int closedCount = statusCounts != null && statusCounts.get("Closed") != null ? statusCounts.get("Closed") : 0;

    String formSuccess = (String) session.getAttribute("issueFormSuccess");
    if (formSuccess != null) session.removeAttribute("issueFormSuccess");
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <jsp:include page="/view/components/admin-sidebar.jsp" />

    <main class="saas-main">
        <section class="saas-welcome-block">
            <p class="saas-date">Company: <strong><%= companyName %></strong></p>
            <h1>Issue Reports</h1>
        </section>

        <% if (formSuccess != null) { %>
            <div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i>&nbsp; <%= formSuccess %></div>
        <% } %>

        <%-- Stat cards --%>
        <section class="saas-card-grid">
            <article class="saas-card card-accent-amber">
                <div class="saas-card-icon"><i data-lucide="alert-circle"></i></div>
                <p class="saas-card-title">Open</p>
                <h3><%= openCount %></h3>
                <span class="saas-card-hint">Awaiting review</span>
            </article>
            <article class="saas-card card-accent-blue">
                <div class="saas-card-icon"><i data-lucide="loader"></i></div>
                <p class="saas-card-title">In Progress</p>
                <h3><%= progressCount %></h3>
                <span class="saas-card-hint">Being handled</span>
            </article>
            <article class="saas-card card-accent-green">
                <div class="saas-card-icon"><i data-lucide="check-circle-2"></i></div>
                <p class="saas-card-title">Resolved</p>
                <h3><%= resolvedCount %></h3>
                <span class="saas-card-hint">Fixed issues</span>
            </article>
            <article class="saas-card card-accent-purple">
                <div class="saas-card-icon"><i data-lucide="archive"></i></div>
                <p class="saas-card-title">Closed</p>
                <h3><%= closedCount %></h3>
                <span class="saas-card-hint">Archived</span>
            </article>
        </section>

        <%-- Filters --%>
        <section class="ai-filters">
            <form method="GET" action="${pageContext.request.contextPath}/contact-admin" class="ai-filter-form">
                <div class="ai-filter-group">
                    <label for="typeFilter"><i data-lucide="filter"></i> Type</label>
                    <select id="typeFilter" name="type">
                        <option value="all" <%= filterType.isEmpty() || "all".equalsIgnoreCase(filterType) ? "selected" : "" %>>All Types</option>
                        <option value="Bug" <%= "Bug".equalsIgnoreCase(filterType) ? "selected" : "" %>>Bug Report</option>
                        <option value="Feature Request" <%= "Feature Request".equalsIgnoreCase(filterType) ? "selected" : "" %>>Feature Request</option>
                        <option value="User Report" <%= "User Report".equalsIgnoreCase(filterType) ? "selected" : "" %>>User Report</option>
                        <option value="Account" <%= "Account".equalsIgnoreCase(filterType) ? "selected" : "" %>>Account Issue</option>
                        <option value="Performance" <%= "Performance".equalsIgnoreCase(filterType) ? "selected" : "" %>>Performance</option>
                        <option value="Other" <%= "Other".equalsIgnoreCase(filterType) ? "selected" : "" %>>Other</option>
                    </select>
                </div>
                <div class="ai-filter-group">
                    <label for="statusFilter"><i data-lucide="check-square"></i> Status</label>
                    <select id="statusFilter" name="status">
                        <option value="all" <%= filterStatus.isEmpty() || "all".equalsIgnoreCase(filterStatus) ? "selected" : "" %>>All Statuses</option>
                        <option value="Open" <%= "Open".equalsIgnoreCase(filterStatus) ? "selected" : "" %>>Open</option>
                        <option value="In Progress" <%= "In Progress".equalsIgnoreCase(filterStatus) ? "selected" : "" %>>In Progress</option>
                        <option value="Resolved" <%= "Resolved".equalsIgnoreCase(filterStatus) ? "selected" : "" %>>Resolved</option>
                        <option value="Closed" <%= "Closed".equalsIgnoreCase(filterStatus) ? "selected" : "" %>>Closed</option>
                    </select>
                </div>
                <button type="submit" class="ai-btn-apply">Apply</button>
                <a href="${pageContext.request.contextPath}/contact-admin" class="ai-btn-clear">Clear</a>
            </form>
        </section>

        <%-- Issue cards grid --%>
        <section class="ai-issues-grid">
            <% if (issues == null || issues.isEmpty()) { %>
                <div class="ai-empty">
                    <i data-lucide="inbox"></i>
                    <h3>No issues found</h3>
                    <p>No issue reports match the current filters.</p>
                </div>
            <% } else {
                for (IssueReport issue : issues) {
                    String typeIcon = "help-circle";
                    String typeColor = "indigo";
                    String issueType = issue.getIssueType() != null ? issue.getIssueType() : "Other";
                    if ("Bug".equalsIgnoreCase(issueType)) { typeIcon = "bug"; typeColor = "red"; }
                    else if ("Feature Request".equalsIgnoreCase(issueType)) { typeIcon = "sparkles"; typeColor = "purple"; }
                    else if ("User Report".equalsIgnoreCase(issueType)) { typeIcon = "user-x"; typeColor = "amber"; }
                    else if ("Account".equalsIgnoreCase(issueType)) { typeIcon = "shield"; typeColor = "blue"; }
                    else if ("Performance".equalsIgnoreCase(issueType)) { typeIcon = "zap"; typeColor = "amber"; }

                    String status = issue.getStatus() != null ? issue.getStatus() : "Open";
                    String statusClass = "ca-status--open";
                    if ("In Progress".equalsIgnoreCase(status)) statusClass = "ca-status--progress";
                    else if ("Resolved".equalsIgnoreCase(status)) statusClass = "ca-status--resolved";
                    else if ("Closed".equalsIgnoreCase(status)) statusClass = "ca-status--closed";

                    String priority = issue.getPriority() != null ? issue.getPriority() : "Medium";
                    String priorityClass = "priority-badge--medium";
                    if ("High".equalsIgnoreCase(priority)) priorityClass = "priority-badge--high";
                    else if ("Low".equalsIgnoreCase(priority)) priorityClass = "priority-badge--low";

                    String senderInitial = issue.getSenderName() != null && !issue.getSenderName().isEmpty()
                            ? issue.getSenderName().substring(0, 1).toUpperCase() : "?";
            %>
                <article class="ai-issue-card ai-issue-card--<%= typeColor %>">
                    <header class="ai-issue-head">
                        <div class="ai-issue-type ai-issue-type--<%= typeColor %>">
                            <i data-lucide="<%= typeIcon %>"></i>
                            <span><%= issueType %></span>
                        </div>
                        <span class="priority-badge <%= priorityClass %>"><%= priority %></span>
                    </header>

                    <h4 class="ai-issue-title"><%= issue.getSubject() %></h4>
                    <p class="ai-issue-desc"><%= issue.getDescription() %></p>

                    <div class="ai-issue-sender">
                        <div class="ai-sender-avatar"><%= senderInitial %></div>
                        <div class="ai-sender-info">
                            <strong><%= issue.getSenderName() %></strong>
                            <span><%= issue.getSenderEmail() %> &middot; <%= issue.getSenderRole() %></span>
                        </div>
                    </div>

                    <% if (issue.getAdminResponse() != null && !issue.getAdminResponse().isEmpty()) { %>
                        <div class="ai-admin-response">
                            <strong><i data-lucide="shield-check"></i> Your Response</strong>
                            <p><%= issue.getAdminResponse() %></p>
                        </div>
                    <% } %>

                    <footer class="ai-issue-foot">
                        <span class="ai-issue-time"><i data-lucide="clock"></i> <%= issue.getCreatedAt() %></span>
                        <span class="ca-status-tag <%= statusClass %>"><%= status %></span>
                    </footer>

                    <details class="ai-issue-manage">
                        <summary><i data-lucide="settings-2"></i> Manage</summary>
                        <form method="POST" action="${pageContext.request.contextPath}/contact-admin" class="ai-manage-form">
                            <input type="hidden" name="action" value="updateIssueStatus">
                            <input type="hidden" name="issueId" value="<%= issue.getId() %>">
                            <div class="ai-manage-row">
                                <label>Status</label>
                                <select name="status" required>
                                    <option value="Open" <%= "Open".equalsIgnoreCase(status) ? "selected" : "" %>>Open</option>
                                    <option value="In Progress" <%= "In Progress".equalsIgnoreCase(status) ? "selected" : "" %>>In Progress</option>
                                    <option value="Resolved" <%= "Resolved".equalsIgnoreCase(status) ? "selected" : "" %>>Resolved</option>
                                    <option value="Closed" <%= "Closed".equalsIgnoreCase(status) ? "selected" : "" %>>Closed</option>
                                </select>
                            </div>
                            <div class="ai-manage-row">
                                <label>Response (optional)</label>
                                <textarea name="adminResponse" rows="3" placeholder="Reply to the user..."><%= issue.getAdminResponse() != null ? issue.getAdminResponse() : "" %></textarea>
                            </div>
                            <button type="submit" class="ca-btn-primary">Save</button>
                        </form>
                    </details>
                </article>
            <% }} %>
        </section>
    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />
</body>
</html>
