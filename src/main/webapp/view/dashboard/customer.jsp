
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.Customer" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customers - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">
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
    <header class="saas-topnav">
        <div class="saas-topnav-left">SmartCRM</div>
        <div class="saas-topnav-center">
            <input type="text" class="saas-search" placeholder="Search customers..." value="<%= search %>" readonly>
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
            <a href="${pageContext.request.contextPath}/view/dashboard/home.jsp" class="saas-nav-item">
                <span class="saas-nav-icon">&#8962;</span>
                <span class="saas-nav-label">Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/customers" class="saas-nav-item active">
                <span class="saas-nav-icon">&#9782;</span>
                <span class="saas-nav-label">Customers</span>
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
                <div class="mu-stat-icon-wrap mu-ic-blue">&#128101;</div>
                <div>
                    <p class="mu-stat-label">Total Customers</p>
                    <p class="mu-stat-value"><%= totalCustomers %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-purple">&#128161;</div>
                <div>
                    <p class="mu-stat-label">Leads</p>
                    <p class="mu-stat-value"><%= leadCount %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-green">&#9989;</div>
                <div>
                    <p class="mu-stat-label">Converted</p>
                    <p class="mu-stat-value"><%= convertedCount %></p>
                </div>
            </article>
            <article class="mu-stat-card">
                <div class="mu-stat-icon-wrap mu-ic-slate">&#10060;</div>
                <div>
                    <p class="mu-stat-label">Lost</p>
                    <p class="mu-stat-value"><%= lostCount %></p>
                </div>
            </article>
        </section>

        <div class="cu-layout">
            <section>
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
                                            <button type="button" class="cu-action cu-action-view" onclick="event.stopPropagation(); window.location.href='<%= customerUrl %>';">View</button>
                                            <button type="button" class="cu-action cu-action-edit" onclick="event.stopPropagation(); window.location.href='${pageContext.request.contextPath}/customers?<%= persistedQuery %>&customerId=<%= customer.getId() %>&showAdd=1&editId=<%= customer.getId() %>';">Edit</button>
                                            <form method="POST" action="${pageContext.request.contextPath}/customers" style="display:inline;" onsubmit="event.stopPropagation();">
                                                <input type="hidden" name="action" value="deleteCustomer">
                                                <input type="hidden" name="customerId" value="<%= customer.getId() %>">
                                                <button type="submit" class="cu-action cu-action-delete">Delete</button>
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
                        <div class="cu-timeline-item">Customer selected from list<span class="cu-item-time"><%= selectedCustomer.getLastActivityDate() %></span></div>
                        <div class="cu-timeline-item">Customer profile loaded<span class="cu-item-time"><%= currentDate %></span></div>
                    </div>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Notes</h4>
                    </div>
                    <div class="cu-notes">
                        <div class="cu-note-item">Notes are displayed per selected customer.<span class="cu-item-time">Latest</span></div>
                    </div>
                    <div class="cu-inline-add">
                        <textarea placeholder="Add a note..." disabled></textarea>
                        <button type="button" disabled>Add</button>
                    </div>
                </div>

                <div class="cu-section">
                    <div class="cu-section-header">
                        <h4>Tasks / Follow-ups</h4>
                    </div>
                    <div class="cu-tasks">
                        <div class="cu-task-item">Task tracking follows selected customer.<span class="cu-item-time">Pending</span></div>
                    </div>
                    <div class="cu-task-add-group">
                        <div class="cu-task-add-row">
                            <input type="text" placeholder="Task title" disabled>
                        </div>
                        <div class="cu-task-add-row">
                            <input type="date" disabled>
                            <button type="button" disabled>Create Task</button>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <div class="cu-detail-empty">No customer selected.</div>
                <% } %>
            </aside>
        </div>
    </main>
</div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const bulkApplyBtn = document.getElementById("bulkApplyBtn");
    const bulkDeleteBtn = document.getElementById("bulkDeleteBtn");
    const bulkForm = document.getElementById("bulkActionForm");
    const bulkAction = document.getElementById("bulkAction");
    const bulkStatus = document.getElementById("bulkStatus");
    const bulkStatusHidden = document.getElementById("bulkStatusHidden");
    const bulkSelectedContainer = document.getElementById("bulkSelectedContainer");
    const rowChecks = Array.from(document.querySelectorAll(".row-check"));

    function selectedIds() {
        return rowChecks.filter(function (cb) { return cb.checked; }).map(function (cb) { return cb.value; });
    }

    function submitBulk(actionName) {
        if (!bulkForm || !bulkAction || !bulkSelectedContainer) {
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

        bulkForm.submit();
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
});
</script>
</body>
</html>
