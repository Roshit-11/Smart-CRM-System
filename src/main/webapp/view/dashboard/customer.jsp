<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.Customer" %>
<%@ page import="com.crm.app.model.CustomerNote" %>
<%@ page import="com.crm.app.model.Task" %>
<%@ page import="com.crm.app.model.ActivityLog" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.crm.app.model.CompanySettings" %>
<%@ page import="com.crm.app.model.EmailTemplate" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customers - SmartCRM</title>
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

    if (request.getAttribute("customers") == null) {
        response.sendRedirect(request.getContextPath() + "/customers");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    @SuppressWarnings("unchecked")
    List<User> assignedUsers = (List<User>) request.getAttribute("assignedUsers");
    Customer selectedCustomer = (Customer) request.getAttribute("selectedCustomer");

    String search = (String) request.getAttribute("search");
    String status = (String) request.getAttribute("status");
    String assignedUser = (String) request.getAttribute("assignedUser");
    String sort = (String) request.getAttribute("sort");
    String showAdd = (String) request.getAttribute("showAdd");
    Customer editingCustomer = (Customer) request.getAttribute("editingCustomer");

    @SuppressWarnings("unchecked")
    List<CustomerNote> notes = (List<CustomerNote>) request.getAttribute("notes");
    @SuppressWarnings("unchecked")
    List<Task> tasks = (List<Task>) request.getAttribute("tasks");
    @SuppressWarnings("unchecked")
    List<ActivityLog> activityLogs = (List<ActivityLog>) request.getAttribute("activityLogs");
    @SuppressWarnings("unchecked")
    List<EmailTemplate> emailTemplates = (List<EmailTemplate>) request.getAttribute("emailTemplates");
    CompanySettings companyEmailSettings = (CompanySettings) request.getAttribute("companyEmailSettings");

    if (search == null) search = "";
    if (status == null) status = "";
    if (assignedUser == null) assignedUser = "";
    if (sort == null || sort.trim().isEmpty()) sort = "recent";
    boolean showAddForm = "1".equals(showAdd) || editingCustomer != null;

    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = user.getCompanyName();
    }
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = "SmartCRM";
    }

    String userName = user.getName() != null ? user.getName() : "User";
    String avatarLetter = userName.trim().isEmpty() ? "U" : userName.substring(0, 1).toUpperCase();
    String companyInitial = companyName.substring(0, 1).toUpperCase();
    String currentDate = LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy"));
    boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());

    int unreadNotifications = 0;
    try {
        unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId());
    } catch (Exception ignored) {
    }

    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "customers");
    request.setAttribute("topSearchPlaceholder", "Search customers...");

    int totalCustomers = request.getAttribute("totalCustomers") == null ? 0 : (Integer) request.getAttribute("totalCustomers");
    int leadCount = request.getAttribute("leadCount") == null ? 0 : (Integer) request.getAttribute("leadCount");
    int convertedCount = request.getAttribute("convertedCount") == null ? 0 : (Integer) request.getAttribute("convertedCount");
    int lostCount = request.getAttribute("lostCount") == null ? 0 : (Integer) request.getAttribute("lostCount");

    String persistedQuery = "search=" + URLEncoder.encode(search, StandardCharsets.UTF_8)
            + "&status=" + URLEncoder.encode(status, StandardCharsets.UTF_8)
            + "&assignedUser=" + URLEncoder.encode(assignedUser, StandardCharsets.UTF_8)
            + "&sort=" + URLEncoder.encode(sort, StandardCharsets.UTF_8);
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
        <jsp:include page="/view/components/admin-sidebar.jsp" />
    <% } else { %>
        <jsp:include page="/view/components/user-sidebar.jsp" />
    <% } %>

    <main class="saas-main mu-main">
        <section class="mu-page-header">
            <div>
                <p class="mu-page-sub"><%= currentDate %></p>
                <h1 class="mu-page-title">Customers Control Panel</h1>
                <p class="mu-page-sub">Manage pipeline, follow-ups, and customer ownership from one place.</p>
            </div>
        </section>

        <section class="mu-stats-row" id="statsRow">
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-blue"><i data-lucide="users"></i></div>
                <div>
                    <p class="mu-stat-label">Total Customers</p>
                    <p class="mu-stat-value"><%= totalCustomers %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-purple"><i data-lucide="zap"></i></div>
                <div>
                    <p class="mu-stat-label">Leads</p>
                    <p class="mu-stat-value"><%= leadCount %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-green"><i data-lucide="check-circle"></i></div>
                <div>
                    <p class="mu-stat-label">Converted</p>
                    <p class="mu-stat-value"><%= convertedCount %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-slate"><i data-lucide="x-circle"></i></div>
                <div>
                    <p class="mu-stat-label">Lost</p>
                    <p class="mu-stat-value"><%= lostCount %></p>
                </div>
            </article>
        </section>

        <div class="cu-layout">
            <section>
                <% String bulkEmailError = (String) request.getAttribute("bulkEmailError"); %>
                <% String bulkEmailSuccess = (String) request.getAttribute("bulkEmailSuccess"); %>
                <% if (bulkEmailError != null) { %>
                    <div class="mu-alert mu-alert-error"><i data-lucide="alert-triangle"></i>&nbsp; <%= bulkEmailError %></div>
                <% } %>
                <% if (bulkEmailSuccess != null) { %>
                    <div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i>&nbsp; <%= bulkEmailSuccess %></div>
                <% } %>
                <form class="cu-toolbar-row" method="GET" action="${pageContext.request.contextPath}/customers">
                    <div class="cu-search-bar">
                        <div class="cu-search-wrap">
                            <input id="searchInput" name="search" class="cu-search-input" type="text" placeholder="Search by customer name or email" value="<%= search %>">
                        </div>
                        <select id="statusFilter" name="status" class="cu-filter-select">
                            <option value="">All Statuses</option>
                            <option value="Lead" <%= "Lead".equalsIgnoreCase(status) ? "selected" : "" %>>Lead</option>
                            <option value="Contacted" <%= "Contacted".equalsIgnoreCase(status) ? "selected" : "" %>>Contacted</option>
                            <option value="Negotiation" <%= "Negotiation".equalsIgnoreCase(status) ? "selected" : "" %>>Negotiation</option>
                            <option value="Won" <%= "Won".equalsIgnoreCase(status) ? "selected" : "" %>>Won</option>
                            <option value="Lost" <%= "Lost".equalsIgnoreCase(status) ? "selected" : "" %>>Lost</option>
                        </select>
                        <select id="assignedFilter" name="assignedUser" class="cu-filter-select">
                            <option value="">All Assigned Users</option>
                            <% if (assignedUsers != null) {
                                for (User assignee : assignedUsers) {
                                    String assignedId = String.valueOf(assignee.getId());
                            %>
                                <option value="<%= assignedId %>" <%= assignedId.equals(assignedUser) ? "selected" : "" %>><%= assignee.getName() %></option>
                            <% }} %>
                        </select>
                        <select id="sortFilter" name="sort" class="cu-sort-select">
                            <option value="recent" <%= "recent".equalsIgnoreCase(sort) ? "selected" : "" %>>Sort: Recent Activity</option>
                            <option value="name" <%= "name".equalsIgnoreCase(sort) ? "selected" : "" %>>Sort: Name</option>
                        </select>
                        <button id="searchBtn" class="cu-search-btn" type="submit">Search</button>
                    </div>

                    <button id="toggleAddBtn" class="mu-btn-primary" type="submit" name="showAdd" value="1">+ Add Customer</button>
                </form>

                <section id="addCustomerForm" class="cu-inline-form <%= showAddForm ? "active" : "" %>" aria-label="Add customer form">
                    <form method="POST" action="${pageContext.request.contextPath}/customers">
                        <input type="hidden" name="action" value="<%= editingCustomer != null ? "updateCustomer" : "createCustomer" %>">
                        <% if (editingCustomer != null) { %>
                        <input type="hidden" name="customerId" value="<%= editingCustomer.getId() %>">
                        <% } %>
                        <div class="cu-form-grid">
                            <div class="cu-form-field">
                                <label for="customerName">Name</label>
                                <input type="text" id="customerName" name="name" placeholder="Customer name" value="<%= editingCustomer != null ? editingCustomer.getName() : "" %>" required>
                            </div>
                            <div class="cu-form-field">
                                <label for="customerEmail">Email</label>
                                <input type="email" id="customerEmail" name="email" placeholder="customer@company.com" value="<%= editingCustomer != null ? editingCustomer.getEmail() : "" %>" required>
                            </div>
                            <div class="cu-form-field">
                                <label for="customerPhone">Phone</label>
                                <input type="text" id="customerPhone" name="phone" placeholder="+1 202 555 0000" value="<%= editingCustomer != null ? editingCustomer.getPhone() : "" %>" required>
                            </div>
                            <div class="cu-form-field">
                                <label for="customerCompany">Company (optional)</label>
                                <input type="text" id="customerCompany" name="company" placeholder="Company name" value="<%= editingCustomer != null ? editingCustomer.getCompany() : "" %>">
                            </div>
                            <div class="cu-form-field">
                                <label for="customerStatus">Status</label>
                                <select id="customerStatus" name="status">
                                    <option value="Lead" <%= editingCustomer != null && "Lead".equalsIgnoreCase(editingCustomer.getStatus()) ? "selected" : "" %>>Lead</option>
                                    <option value="Contacted" <%= editingCustomer != null && "Contacted".equalsIgnoreCase(editingCustomer.getStatus()) ? "selected" : "" %>>Contacted</option>
                                    <option value="Negotiation" <%= editingCustomer != null && "Negotiation".equalsIgnoreCase(editingCustomer.getStatus()) ? "selected" : "" %>>Negotiation</option>
                                    <option value="Won" <%= editingCustomer != null && "Won".equalsIgnoreCase(editingCustomer.getStatus()) ? "selected" : "" %>>Won</option>
                                    <option value="Lost" <%= editingCustomer != null && "Lost".equalsIgnoreCase(editingCustomer.getStatus()) ? "selected" : "" %>>Lost</option>
                                </select>
                            </div>
                            <div class="cu-form-field">
                                <label for="customerAssigned">Assigned User</label>
                                <select id="customerAssigned" name="assignedUserId" required>
                                    <% if (assignedUsers != null) {
                                        for (User assignee : assignedUsers) { %>
                                            <option value="<%= assignee.getId() %>" <%= editingCustomer != null && assignee.getId() == editingCustomer.getAssignedUserId() ? "selected" : "" %>><%= assignee.getName() %></option>
                                    <% }} %>
                                </select>
                            </div>
                            <div class="cu-form-field cu-full">
                                <label for="customerNotes">Notes</label>
                                <textarea id="customerNotes" placeholder="Initial notes..."></textarea>
                            </div>
                        </div>
                        <div class="cu-form-actions">
                            <a id="cancelAddBtn" class="cu-btn-secondary" href="${pageContext.request.contextPath}/customers?<%= persistedQuery %>">Cancel</a>
                            <button type="submit" class="mu-btn-primary"><%= editingCustomer != null ? "Update Customer" : "Save Customer" %></button>
                        </div>
                    </form>
                </section>

                <section class="cu-card">
                    <div class="cu-list-header">
                        <div class="cu-list-header-left">
                            <strong style="font-size: 14px; font-weight: 700; color: #0f172a;">Customers List</strong>
                            <span id="resultCount" class="mu-count-badge"><%= customers == null ? 0 : customers.size() %> results</span>
                        </div>
                        <div class="cu-list-header-right">
                            <form id="bulkActionForm" method="POST" action="${pageContext.request.contextPath}/customers" class="cu-bulk-form">
                                <input type="hidden" id="bulkAction" name="action" value="">
                            <select id="bulkStatus" class="cu-bulk-select">
                                <option value="">Bulk status update</option>
                                <option value="Lead">Lead</option>
                                <option value="Contacted">Contacted</option>
                                <option value="Negotiation">Negotiation</option>
                                <option value="Won">Won</option>
                                <option value="Lost">Lost</option>
                            </select>
                            <button id="bulkApplyBtn" type="button" class="cu-btn-light">Apply</button>
                            <button id="bulkDeleteBtn" type="button" class="cu-btn-danger">Delete Selected</button>
                            <input type="hidden" name="bulkStatus" id="bulkStatusHidden" value="">
                            <div id="bulkSelectedContainer"></div>
                            </form>
                        </div>
                    </div>

                    <div class="cu-table-wrap">
                        <table class="cu-table">
                            <thead>
                                <tr>
                                    <th></th>
                                    <th>Customer Name</th>
                                    <th>Email</th>
                                    <th>Phone Number</th>
                                    <th>Status</th>
                                    <th>Assigned User</th>
                                    <th>Last Activity</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="customersTableBody">
                            <% if (customers != null && !customers.isEmpty()) {
                                for (Customer customer : customers) {
                                    boolean isSelected = selectedCustomer != null && customer.getId() == selectedCustomer.getId();
                                    String rowClass = isSelected ? "selected-row" : "";
                                    String customerUrl = request.getContextPath() + "/customers?" + persistedQuery + "&customerId=" + customer.getId();
                            %>
                                <tr class="<%= rowClass %>" onclick="window.location.href='<%= customerUrl %>'" style="cursor: pointer;">
                                    <td><input type="checkbox" class="cu-checkbox row-check" value="<%= customer.getId() %>" onclick="event.stopPropagation();"></td>
                                    <td><span class="cu-name"><%= customer.getName() %></span></td>
                                    <td><%= customer.getEmail() %></td>
                                    <td><%= customer.getPhone() %></td>
                                    <td><span class="cu-status cu-status-<%= customer.getStatus() %>"><%= customer.getStatus() %></span></td>
                                    <td><%= customer.getAssignedUser() %></td>
                                    <td><%= customer.getLastActivityDate() %></td>
                                    <td>
                                        <div class="cu-actions">
                                            <button type="button" class="cu-action cu-action-edit" onclick="event.stopPropagation(); window.location.href='${pageContext.request.contextPath}/customers?<%= persistedQuery %>&customerId=<%= customer.getId() %>&showAdd=1&editId=<%= customer.getId() %>';" aria-label="Edit customer" title="Edit">
                                                <i class="fa-solid fa-pen-to-square action-icon edit"></i>
                                            </button>
                                            <form method="POST" action="${pageContext.request.contextPath}/customers" style="display:inline;" onsubmit="event.stopPropagation();">
                                                <input type="hidden" name="action" value="deleteCustomer">
                                                <input type="hidden" name="customerId" value="<%= customer.getId() %>">
                                                <button type="submit" class="cu-action cu-action-delete" data-confirm-delete aria-label="Delete customer" title="Delete">
                                                    <i class="fa-solid fa-trash action-icon delete"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% }} else { %>
                                <tr>
                                    <td colspan="8" class="cu-empty">No customers match your filters.</td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>

                <section class="cu-card" style="margin-top: 16px;">
                    <div class="cu-list-header">
                        <div class="cu-list-header-left">
                            <strong style="font-size: 14px; font-weight: 700; color: #0f172a;">Bulk Email</strong>
                            <span class="mu-count-badge">Use placeholders to personalize</span>
                        </div>
                    </div>
                    <div style="padding: 16px 20px;">
                        <form id="bulkEmailForm" method="POST" action="${pageContext.request.contextPath}/customers">
                            <div class="cu-form-grid">
                                <div class="cu-form-field cu-full">
                                    <label for="bulkSubject">Subject</label>
                                    <input type="text" id="bulkSubject" name="bulkSubject" placeholder="Email subject" required>
                                </div>
                                <div class="cu-form-field cu-full">
                                    <label for="templateSelect">Template</label>
                                    <select id="templateSelect">
                                        <option value="">Select a template</option>
                                        <% if (emailTemplates != null) {
                                            for (EmailTemplate template : emailTemplates) {
                                                String tSubject = template.getSubject() == null ? "" : template.getSubject().replace("\"", "&quot;");
                                                String tBody = template.getBody() == null ? "" : template.getBody().replace("\"", "&quot;");
                                                String tName = template.getTemplateName() == null ? "" : template.getTemplateName();
                                        %>
                                                <option value="<%= template.getId() %>" data-subject="<%= tSubject %>" data-body="<%= tBody %>" data-name="<%= tName %>"><%= tName %></option>
                                        <% }} %>
                                    </select>
                                </div>
                                <div class="cu-form-field cu-full">
                                    <label>Placeholders</label>
                                    <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                        <button type="button" class="cu-btn-light" data-placeholder="{{name}}">Name</button>
                                        <button type="button" class="cu-btn-light" data-placeholder="{{email}}">Email</button>
                                        <button type="button" class="cu-btn-light" data-placeholder="{{phone}}">Phone</button>
                                        <button type="button" class="cu-btn-light" data-placeholder="{{company}}">Company</button>
                                    </div>
                                </div>
                                <div class="cu-form-field cu-full">
                                    <label for="bulkBody">Message</label>
                                    <textarea id="bulkBody" name="bulkBody" placeholder="Write your email..." required></textarea>
                                </div>
                                <div class="cu-form-field cu-full">
                                    <label for="templateName">Save as Template (optional)</label>
                                    <input type="text" id="templateName" name="templateName" placeholder="Template name">
                                </div>
                            </div>
                            <div class="cu-form-actions">
                                <% boolean emailLinked = companyEmailSettings != null && companyEmailSettings.isVerified(); %>
                                <% if (!emailLinked) { %>
                                    <span class="mu-alert mu-alert-error" style="margin:0; padding:8px 12px;">Company email is not linked.</span>
                                <% } %>
                                <button type="submit" class="mu-btn-primary" name="action" value="saveTemplate">Save Template</button>
                                <button type="submit" class="mu-btn-primary" name="action" value="sendBulkEmail" <%= emailLinked ? "" : "disabled" %>>Send Bulk Email</button>
                            </div>
                        </form>
                    </div>
                </section>
            </section>

            <aside class="cu-card cu-details" id="detailPanel">
                <% if (selectedCustomer != null) { %>
                <div class="cu-details-head">
                    <div>
                        <div class="cu-details-head-avatar"><%= selectedCustomer.getName().substring(0, 1).toUpperCase() %></div>
                        <h3><%= selectedCustomer.getName() %></h3>
                        <p class="cu-meta">Last activity: <%= selectedCustomer.getLastActivityDate() %></p>
                    </div>
                    <span class="cu-status cu-status-<%= selectedCustomer.getStatus() %>"><%= selectedCustomer.getStatus() %></span>
                </div>

                <div class="cu-info-grid">
                    <div class="cu-info-item"><span>Email</span><strong><%= selectedCustomer.getEmail() %></strong></div>
                    <div class="cu-info-item"><span>Phone</span><strong><%= selectedCustomer.getPhone() %></strong></div>
                    <div class="cu-info-item"><span>Company</span><strong><%= selectedCustomer.getCompany() %></strong></div>
                    <div class="cu-info-item"><span>Assigned User</span><strong><%= selectedCustomer.getAssignedUser() %></strong></div>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Status Pipeline</h4>
                    </div>
                    <div class="cu-pipeline-row">
                        <select disabled>
                            <option><%= selectedCustomer.getStatus() %></option>
                        </select>
                        <form method="POST" action="${pageContext.request.contextPath}/customers" style="display:flex; gap:8px; width:100%;">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="customerId" value="<%= selectedCustomer.getId() %>">
                            <select name="status">
                                <option value="Lead" <%= "Lead".equalsIgnoreCase(selectedCustomer.getStatus()) ? "selected" : "" %>>Lead</option>
                                <option value="Contacted" <%= "Contacted".equalsIgnoreCase(selectedCustomer.getStatus()) ? "selected" : "" %>>Contacted</option>
                                <option value="Negotiation" <%= "Negotiation".equalsIgnoreCase(selectedCustomer.getStatus()) ? "selected" : "" %>>Negotiation</option>
                                <option value="Won" <%= "Won".equalsIgnoreCase(selectedCustomer.getStatus()) ? "selected" : "" %>>Won</option>
                                <option value="Lost" <%= "Lost".equalsIgnoreCase(selectedCustomer.getStatus()) ? "selected" : "" %>>Lost</option>
                            </select>
                            <button type="submit">Update</button>
                        </form>
                    </div>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Activity Timeline</h4>
                    </div>
                    <div class="cu-timeline">
                        <% if (activityLogs != null && !activityLogs.isEmpty()) {
                            for (ActivityLog log : activityLogs) {
                                String actor = log.getUserName() != null ? log.getUserName() : "System";
                                String details = log.getDetails() != null ? log.getDetails() : log.getAction();
                        %>
                            <div class="cu-timeline-item"><%= details %><span class="cu-item-time"><%= actor %></span></div>
                        <% }} else { %>
                            <div class="cu-timeline-item">No activity recorded yet.</div>
                        <% } %>
                    </div>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Notes</h4>
                    </div>
                    <div class="cu-notes">
                        <% if (notes != null && !notes.isEmpty()) {
                            for (CustomerNote note : notes) {
                                String author = note.getUserName() != null ? note.getUserName() : "User";
                        %>
                            <div class="cu-note-item"><%= note.getNote() %><span class="cu-item-time"><%= author %></span></div>
                        <% }} else { %>
                            <div class="cu-note-item">No notes yet.</div>
                        <% } %>
                    </div>
                    <form class="cu-inline-add" method="POST" action="${pageContext.request.contextPath}/customers">
                        <input type="hidden" name="action" value="addNote">
                        <input type="hidden" name="customerId" value="<%= selectedCustomer.getId() %>">
                        <textarea name="note" placeholder="Add a note..." required></textarea>
                        <button type="submit">Add</button>
                    </form>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Tasks / Follow-ups</h4>
                    </div>
                    <div class="cu-tasks">
                        <% if (tasks != null && !tasks.isEmpty()) {
                            for (Task task : tasks) {
                                String assignedName = task.getAssignedUserName() != null ? task.getAssignedUserName() : "Unassigned";
                                boolean canEditTask = isAdmin || task.getAssignedUserId() == user.getId();
                                boolean canDeleteTask = isAdmin || task.getCreatedBy() == user.getId();
                        %>
                            <div class="cu-task-item">
                                <strong><%= task.getTitle() %></strong>
                                <span class="cu-item-time">Due: <%= task.getDueDate() %> | <%= assignedName %> | <%= task.getStatus() %></span>
                                <form method="POST" action="${pageContext.request.contextPath}/customers" style="margin-top:8px;">
                                    <input type="hidden" name="action" value="updateTaskStatus">
                                    <input type="hidden" name="taskId" value="<%= task.getId() %>">
                                    <input type="hidden" name="customerId" value="<%= selectedCustomer.getId() %>">
                                    <select name="taskStatus" <%= task.getAssignedUserId() == user.getId() ? "" : "disabled" %>>
                                        <option value="Pending" <%= "Pending".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>Pending</option>
                                        <option value="In Progress" <%= "In Progress".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>In Progress</option>
                                        <option value="Completed" <%= "Completed".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>Completed</option>
                                    </select>
                                    <button type="submit" <%= task.getAssignedUserId() == user.getId() ? "" : "disabled" %>>Update</button>
                                </form>
                                <% if (canEditTask || canDeleteTask) { %>
                                    <details style="margin-top:8px;">
                                        <summary>Manage task</summary>
                                        <% if (canEditTask) { %>
                                            <form method="POST" action="${pageContext.request.contextPath}/customers" style="margin-top:8px;">
                                                <input type="hidden" name="action" value="updateTask">
                                                <input type="hidden" name="taskId" value="<%= task.getId() %>">
                                                <div class="cu-task-add-row">
                                                    <input type="text" name="taskTitle" value="<%= task.getTitle() %>" required>
                                                </div>
                                                <div class="cu-task-add-row">
                                                    <input type="date" name="dueDate" value="<%= task.getDueDate() %>" required>
                                                    <select name="taskStatus" required>
                                                        <option value="Pending" <%= "Pending".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>Pending</option>
                                                        <option value="In Progress" <%= "In Progress".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>In Progress</option>
                                                        <option value="Completed" <%= "Completed".equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>>Completed</option>
                                                    </select>
                                                    <% if (isAdmin) { %>
                                                        <select name="taskAssignedUserId" required>
                                                            <% if (assignedUsers != null) {
                                                                for (User assignee : assignedUsers) { %>
                                                                    <option value="<%= assignee.getId() %>" <%= assignee.getId() == task.getAssignedUserId() ? "selected" : "" %>><%= assignee.getName() %></option>
                                                            <% }} %>
                                                        </select>
                                                    <% } else { %>
                                                        <input type="hidden" name="taskAssignedUserId" value="<%= task.getAssignedUserId() %>">
                                                    <% } %>
                                                    <button type="submit">Save</button>
                                                </div>
                                            </form>
                                        <% } %>
                                        <% if (canDeleteTask) { %>
                                            <form method="POST" action="${pageContext.request.contextPath}/customers" style="margin-top:8px;">
                                                <input type="hidden" name="action" value="deleteTask">
                                                <input type="hidden" name="taskId" value="<%= task.getId() %>">
                                                <button type="submit" data-confirm-delete>Delete Task</button>
                                            </form>
                                        <% } %>
                                    </details>
                                <% } %>
                            </div>
                        <% }} else { %>
                            <div class="cu-task-item">No tasks yet.</div>
                        <% } %>
                    </div>
                    <form class="cu-task-add-group" method="POST" action="${pageContext.request.contextPath}/customers">
                        <input type="hidden" name="action" value="createTask">
                        <input type="hidden" name="customerId" value="<%= selectedCustomer.getId() %>">
                        <div class="cu-task-add-row">
                            <input type="text" name="taskTitle" placeholder="Task title" required>
                        </div>
                        <div class="cu-task-add-row">
                            <input type="date" name="dueDate" required>
                            <select name="taskAssignedUserId" required>
                                <% if (assignedUsers != null) {
                                    for (User assignee : assignedUsers) { %>
                                        <option value="<%= assignee.getId() %>"><%= assignee.getName() %></option>
                                <% }} %>
                            </select>
                            <button type="submit">Create Task</button>
                        </div>
                    </form>
                </div>
                <% } else { %>
                <div class="cu-detail-empty">No customer selected.</div>
                <% } %>
            </aside>
        </div>
    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />
<script>
document.addEventListener("DOMContentLoaded", function () {
    const bulkApplyBtn = document.getElementById("bulkApplyBtn");
    const bulkDeleteBtn = document.getElementById("bulkDeleteBtn");
    const bulkActionForm = document.getElementById("bulkActionForm");
    const bulkAction = document.getElementById("bulkAction");
    const bulkStatus = document.getElementById("bulkStatus");
    const bulkStatusHidden = document.getElementById("bulkStatusHidden");
    const bulkSelectedContainer = document.getElementById("bulkSelectedContainer");
    const rowChecks = Array.from(document.querySelectorAll(".row-check"));

    function selectedIds() {
        return rowChecks.filter(function (cb) { return cb.checked; }).map(function (cb) { return cb.value; });
    }

    function submitBulk(actionName) {
        if (!bulkActionForm || !bulkAction || !bulkSelectedContainer) {
            return;
        }

        const ids = selectedIds();
        if (ids.length === 0) {
            return;
        }

        bulkAction.value = actionName;
        bulkStatusHidden.value = bulkStatus ? bulkStatus.value : "";
        bulkSelectedContainer.innerHTML = "";

        ids.forEach(function (id) {
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = "selectedCustomerIds";
            input.value = id;
            bulkSelectedContainer.appendChild(input);
        });

        bulkActionForm.submit();
    }

    if (bulkApplyBtn) {
        bulkApplyBtn.addEventListener("click", function () {
            if (!bulkStatus || !bulkStatus.value) {
                return;
            }
            submitBulk("bulkUpdateStatus");
        });
    }

    if (bulkDeleteBtn) {
        bulkDeleteBtn.addEventListener("click", function () {
            submitBulk("bulkDelete");
        });
    }

    const bulkEmailForm = document.getElementById("bulkEmailForm");
    const bulkBody = document.getElementById("bulkBody");
    const bulkSubject = document.getElementById("bulkSubject");
    const templateSelect = document.getElementById("templateSelect");
    const templateName = document.getElementById("templateName");

    if (bulkEmailForm) {
        bulkEmailForm.addEventListener("submit", function () {
            const ids = selectedIds();
            const existing = bulkEmailForm.querySelectorAll("input[name='selectedCustomerIds']");
            existing.forEach(function (el) { el.remove(); });
            ids.forEach(function (id) {
                const input = document.createElement("input");
                input.type = "hidden";
                input.name = "selectedCustomerIds";
                input.value = id;
                bulkEmailForm.appendChild(input);
            });
        });
    }

    document.querySelectorAll("[data-placeholder]").forEach(function (btn) {
        btn.addEventListener("click", function () {
            if (!bulkBody) {
                return;
            }
            const placeholder = btn.getAttribute("data-placeholder");
            const start = bulkBody.selectionStart || 0;
            const end = bulkBody.selectionEnd || 0;
            const text = bulkBody.value || "";
            bulkBody.value = text.substring(0, start) + placeholder + text.substring(end);
            bulkBody.focus();
            bulkBody.selectionStart = bulkBody.selectionEnd = start + placeholder.length;
        });
    });

    if (templateSelect) {
        templateSelect.addEventListener("change", function () {
            const selected = templateSelect.options[templateSelect.selectedIndex];
            if (!selected || !selected.value) {
                return;
            }
            if (bulkSubject) {
                bulkSubject.value = selected.getAttribute("data-subject") || "";
            }
            if (bulkBody) {
                bulkBody.value = selected.getAttribute("data-body") || "";
            }
            if (templateName) {
                templateName.value = selected.getAttribute("data-name") || "";
            }
        });
    }
});

</script>

