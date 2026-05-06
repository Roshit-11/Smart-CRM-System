<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<%@ page import="com.crm.app.model.Deal" %>
<%@ page import="com.crm.app.model.Customer" %>
<%@ page import="com.crm.app.dao.NotificationDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Deals Pipeline - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260507">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (user.isFirstLogin()) { response.sendRedirect(request.getContextPath() + "/change-password"); return; }
    if (request.getAttribute("deals") == null) { response.sendRedirect(request.getContextPath() + "/deals"); return; }

    @SuppressWarnings("unchecked") List<Deal> deals = (List<Deal>) request.getAttribute("deals");
    @SuppressWarnings("unchecked") List<User> assignedUsers = (List<User>) request.getAttribute("assignedUsers");
    @SuppressWarnings("unchecked") List<Customer> customers = (List<Customer>) request.getAttribute("customers");

    String search = (String) request.getAttribute("search");
    String stage = (String) request.getAttribute("stage");
    String assignedUser = (String) request.getAttribute("assignedUser");
    String showAdd = (String) request.getAttribute("showAdd");
    Deal editingDeal = (Deal) request.getAttribute("editingDeal");

    if (search == null) search = "";
    if (stage == null) stage = "";
    if (assignedUser == null) assignedUser = "";
    boolean showAddForm = "1".equals(showAdd) || editingDeal != null;

    String[] stages = new String[] { "Prospect", "Qualified", "Proposal", "Negotiation", "Closed Won", "Closed Lost" };

    int unreadNotifications = 0;
    try { unreadNotifications = new NotificationDao().countUnreadNotifications(user.getId()); } catch (Exception ignored) {}

    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("activeNav", "deals");
    request.setAttribute("topSearchPlaceholder", "Search deals...");

    Integer totalDealsAttr   = (Integer) request.getAttribute("totalDeals");
    Integer activeDealsAttr  = (Integer) request.getAttribute("activeDeals");
    Integer wonDealsAttr     = (Integer) request.getAttribute("wonDeals");
    Integer lostDealsAttr    = (Integer) request.getAttribute("lostDeals");
    int totalDeals  = totalDealsAttr  != null ? totalDealsAttr  : 0;
    int activeDeals = activeDealsAttr != null ? activeDealsAttr : 0;
    int wonDeals    = wonDealsAttr    != null ? wonDealsAttr    : 0;
    int lostDeals   = lostDealsAttr   != null ? lostDealsAttr   : 0;

    boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());

    String persistedQuery = "search=" + URLEncoder.encode(search, StandardCharsets.UTF_8)
            + "&stage=" + URLEncoder.encode(stage, StandardCharsets.UTF_8)
            + "&assignedUser=" + URLEncoder.encode(assignedUser, StandardCharsets.UTF_8);

    List<Deal> prospectDeals    = new ArrayList<>();
    List<Deal> qualifiedDeals   = new ArrayList<>();
    List<Deal> proposalDeals    = new ArrayList<>();
    List<Deal> negotiationDeals = new ArrayList<>();
    List<Deal> closedWonDeals   = new ArrayList<>();
    List<Deal> closedLostDeals  = new ArrayList<>();

    BigDecimal totalValue = BigDecimal.ZERO;

    if (deals != null) {
        for (Deal deal : deals) {
            if (deal.getValue() != null) totalValue = totalValue.add(deal.getValue());
            String ds = deal.getStage() == null ? "" : deal.getStage();
            if      ("Prospect".equalsIgnoreCase(ds))    prospectDeals.add(deal);
            else if ("Qualified".equalsIgnoreCase(ds))   qualifiedDeals.add(deal);
            else if ("Proposal".equalsIgnoreCase(ds))    proposalDeals.add(deal);
            else if ("Negotiation".equalsIgnoreCase(ds)) negotiationDeals.add(deal);
            else if ("Closed Won".equalsIgnoreCase(ds))  closedWonDeals.add(deal);
            else if ("Closed Lost".equalsIgnoreCase(ds)) closedLostDeals.add(deal);
            else prospectDeals.add(deal);
        }
    }

    String totalValueFmt = String.format("$%,.0f", totalValue);
%>

<div class="saas-shell">
    <jsp:include page="/view/components/top-navbar.jsp" />
    <% if (isAdmin) { %>
        <jsp:include page="/view/components/admin-sidebar.jsp" />
    <% } else { %>
        <jsp:include page="/view/components/user-sidebar.jsp" />
    <% } %>

    <main class="saas-main pipeline-main">

        <%-- PAGE HEADER --%>
        <div class="pipeline-header">
            <div class="pipeline-header-left">
                <h1 class="pipeline-title">Deals Pipeline</h1>
                <p class="pipeline-sub">Track opportunities and close revenue across your team.</p>
            </div>
            <div class="pipeline-header-actions">
                <div class="pipeline-view-toggle" id="viewToggle">
                    <button type="button" class="pvt-btn pvt-active" data-view="pipeline">
                        <i data-lucide="kanban-square"></i> Pipeline
                    </button>
                    <button type="button" class="pvt-btn" data-view="table">
                        <i data-lucide="table-2"></i> Table
                    </button>
                </div>
                <button type="button" class="pipeline-add-btn" id="openAddDeal">
                    <i data-lucide="plus"></i> Add Deal
                </button>
            </div>
        </div>

        <%-- FLASH --%>
        <% String flashErr = (String) request.getAttribute("error"); String flashOk = (String) request.getAttribute("success");
           if (flashErr != null) { %><div class="mu-alert mu-alert-error"><i data-lucide="alert-triangle"></i> <%= flashErr %></div>
        <% } if (flashOk != null) { %><div class="mu-alert mu-alert-success"><i data-lucide="check-circle"></i> <%= flashOk %></div>
        <% } %>

        <%-- STAT STRIP --%>
        <div class="pipeline-stats">
            <div class="pstat-card">
                <div class="pstat-icon pstat-blue"><i data-lucide="trending-up"></i></div>
                <div class="pstat-body">
                    <span class="pstat-label">Total Deals</span>
                    <strong class="pstat-value"><%= totalDeals %></strong>
                </div>
            </div>
            <div class="pstat-card">
                <div class="pstat-icon pstat-violet"><i data-lucide="activity"></i></div>
                <div class="pstat-body">
                    <span class="pstat-label">Active Deals</span>
                    <strong class="pstat-value"><%= activeDeals %></strong>
                </div>
            </div>
            <div class="pstat-card">
                <div class="pstat-icon pstat-green"><i data-lucide="circle-check-big"></i></div>
                <div class="pstat-body">
                    <span class="pstat-label">Closed Won</span>
                    <strong class="pstat-value"><%= wonDeals %></strong>
                </div>
            </div>
            <div class="pstat-card">
                <div class="pstat-icon pstat-red"><i data-lucide="circle-x"></i></div>
                <div class="pstat-body">
                    <span class="pstat-label">Closed Lost</span>
                    <strong class="pstat-value"><%= lostDeals %></strong>
                </div>
            </div>
            <div class="pstat-card pstat-card--value">
                <div class="pstat-icon pstat-amber"><i data-lucide="dollar-sign"></i></div>
                <div class="pstat-body">
                    <span class="pstat-label">Pipeline Value</span>
                    <strong class="pstat-value"><%= totalValueFmt %></strong>
                </div>
            </div>
        </div>

        <%-- ADD / EDIT DEAL FORM (SLIDE-DOWN PANEL) --%>
        <div class="pipeline-form-panel <%= showAddForm ? "is-open" : "" %>" id="addDealPanel">
            <div class="pfp-header">
                <h3 class="pfp-title">
                    <i data-lucide="<%= editingDeal != null ? "pencil" : "plus-circle" %>"></i>
                    <%= editingDeal != null ? "Edit Deal" : "New Deal" %>
                </h3>
                <button type="button" class="pfp-close" id="closeDealPanel"><i data-lucide="x"></i></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/deals" class="pfp-form">
                <input type="hidden" name="action" value="<%= editingDeal != null ? "updateDeal" : "createDeal" %>">
                <% if (editingDeal != null) { %><input type="hidden" name="dealId" value="<%= editingDeal.getId() %>"><% } %>
                <div class="pfp-grid">
                    <div class="pfp-field">
                        <label>Deal Title</label>
                        <input type="text" name="title" placeholder="e.g. Enterprise Expansion Q3" value="<%= editingDeal != null ? editingDeal.getTitle() : "" %>" required>
                    </div>
                    <div class="pfp-field">
                        <label>Deal Value ($)</label>
                        <input type="number" step="0.01" min="0" name="value" placeholder="0.00" value="<%= editingDeal != null && editingDeal.getValue() != null ? editingDeal.getValue() : "" %>" required>
                    </div>
                    <div class="pfp-field">
                        <label>Customer</label>
                        <select name="customerId" required>
                            <option value="">Select customer…</option>
                            <% if (customers != null) { for (Customer c : customers) {
                                String sel = editingDeal != null && c.getId() == editingDeal.getCustomerId() ? "selected" : ""; %>
                                <option value="<%= c.getId() %>" <%= sel %>><%= c.getName() %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="pfp-field">
                        <label>Stage</label>
                        <select name="stage">
                            <% for (String s : stages) { %>
                                <option value="<%= s %>" <%= editingDeal != null && s.equalsIgnoreCase(editingDeal.getStage()) ? "selected" : "" %>><%= s %></option>
                            <% } %>
                        </select>
                    </div>
                    <% if (isAdmin) { %>
                    <div class="pfp-field">
                        <label>Assigned To</label>
                        <select name="assignedUserId">
                            <option value="">Unassigned</option>
                            <% if (assignedUsers != null) { for (User au : assignedUsers) {
                                boolean sel2 = editingDeal != null && editingDeal.getAssignedUserId() != null && au.getId() == editingDeal.getAssignedUserId(); %>
                                <option value="<%= au.getId() %>" <%= sel2 ? "selected" : "" %>><%= au.getName() %></option>
                            <% }} %>
                        </select>
                    </div>
                    <% } else { %><input type="hidden" name="assignedUserId" value="<%= user.getId() %>"><% } %>
                </div>
                <div class="pfp-actions">
                    <a href="${pageContext.request.contextPath}/deals?<%= persistedQuery %>" class="pfp-cancel">Cancel</a>
                    <button type="submit" class="pipeline-add-btn"><%= editingDeal != null ? "Update Deal" : "Save Deal" %></button>
                </div>
            </form>
        </div>

        <%-- FILTER BAR --%>
        <form class="pipeline-filter-bar" method="GET" action="${pageContext.request.contextPath}/deals">
            <div class="pfb-search">
                <i data-lucide="search"></i>
                <input type="text" name="search" value="<%= search %>" placeholder="Search deals…">
            </div>
            <select name="stage" class="pfb-select">
                <option value="">All Stages</option>
                <% for (String s : stages) { %>
                    <option value="<%= s %>" <%= s.equalsIgnoreCase(stage) ? "selected" : "" %>><%= s %></option>
                <% } %>
            </select>
            <% if (isAdmin) { %>
            <select name="assignedUser" class="pfb-select">
                <option value="">All Users</option>
                <% if (assignedUsers != null) { for (User au : assignedUsers) {
                    String auid = String.valueOf(au.getId()); %>
                    <option value="<%= auid %>" <%= auid.equals(assignedUser) ? "selected" : "" %>><%= au.getName() %></option>
                <% }} %>
            </select>
            <% } %>
            <button type="submit" class="pfb-apply">Apply</button>
        </form>

        <%-- PIPELINE VIEW (default) --%>
        <div id="pipelineView" class="pipeline-board">
            <%-- Helper macro: render one column --%>
            <%!
                private String stageColClass(String s) {
                    if ("Prospect".equalsIgnoreCase(s))    return "col-prospect";
                    if ("Qualified".equalsIgnoreCase(s))   return "col-qualified";
                    if ("Proposal".equalsIgnoreCase(s))    return "col-proposal";
                    if ("Negotiation".equalsIgnoreCase(s)) return "col-negotiation";
                    if ("Closed Won".equalsIgnoreCase(s))  return "col-won";
                    if ("Closed Lost".equalsIgnoreCase(s)) return "col-lost";
                    return "";
                }
            %>
            <%
                List<?>[] stageLists = new List<?>[] {prospectDeals, qualifiedDeals, proposalDeals, negotiationDeals, closedWonDeals, closedLostDeals};
                String[] stageIcons = {"radar","star","file-text","handshake","trophy","ban"};
                for (int si = 0; si < stages.length; si++) {
                    String colStage = stages[si];
                    @SuppressWarnings("unchecked") List<Deal> colDeals = (List<Deal>) stageLists[si];
            %>
            <div class="pipeline-col <%= stageColClass(colStage) %>">
                <div class="pcol-header">
                    <div class="pcol-header-left">
                        <span class="pcol-dot"></span>
                        <i data-lucide="<%= stageIcons[si] %>" class="pcol-icon"></i>
                        <span class="pcol-title"><%= colStage %></span>
                    </div>
                    <span class="pcol-count"><%= colDeals.size() %></span>
                </div>
                <div class="pcol-body">
                    <% if (colDeals.isEmpty()) { %>
                        <div class="pcol-empty">No deals here</div>
                    <% } else { for (Deal deal : colDeals) {
                        boolean canManage = isAdmin || (deal.getAssignedUserId() != null && deal.getAssignedUserId() == user.getId());
                        String valueText = deal.getValue() != null ? String.format("$%,.0f", deal.getValue()) : "—";
                    %>
                    <div class="deal-card">
                        <div class="deal-card-top">
                            <span class="deal-card-title"><%= deal.getTitle() %></span>
                            <% if (canManage) { %>
                            <div class="deal-card-menu">
                                <a href="${pageContext.request.contextPath}/deals?editId=<%= deal.getId() %>&showAdd=1" class="dcm-btn" title="Edit"><i data-lucide="pencil"></i></a>
                                <form method="POST" action="${pageContext.request.contextPath}/deals" style="margin:0;">
                                    <input type="hidden" name="action" value="deleteDeal">
                                    <input type="hidden" name="dealId" value="<%= deal.getId() %>">
                                    <input type="hidden" name="customerId" value="<%= deal.getCustomerId() %>">
                                    <button type="submit" class="dcm-btn dcm-del" title="Delete"><i data-lucide="trash-2"></i></button>
                                </form>
                            </div>
                            <% } %>
                        </div>
                        <div class="deal-card-value"><%= valueText %></div>
                        <div class="deal-card-meta">
                            <span><i data-lucide="contact-2"></i> <%= deal.getCustomerName() != null ? deal.getCustomerName() : "—" %></span>
                            <span><i data-lucide="user"></i> <%= deal.getAssignedUserName() != null ? deal.getAssignedUserName() : "Unassigned" %></span>
                        </div>
                        <% if (canManage) { %>
                        <form method="POST" action="${pageContext.request.contextPath}/deals" class="deal-stage-form">
                            <input type="hidden" name="action" value="updateStage">
                            <input type="hidden" name="dealId" value="<%= deal.getId() %>">
                            <input type="hidden" name="customerId" value="<%= deal.getCustomerId() %>">
                            <select name="stage" class="deal-stage-select" onchange="this.form.submit()">
                                <% for (String s : stages) { %>
                                    <option value="<%= s %>" <%= s.equalsIgnoreCase(deal.getStage()) ? "selected" : "" %>><%= s %></option>
                                <% } %>
                            </select>
                        </form>
                        <% } %>
                    </div>
                    <% }} %>
                </div>
            </div>
            <% } %>
        </div>

        <%-- TABLE VIEW --%>
        <div id="tableView" class="pipeline-table-wrap is-hidden">
            <div class="pipeline-table-card">
                <div class="ptc-header">
                    <span class="ptc-title">All Deals</span>
                    <span class="mu-count-badge"><%= deals == null ? 0 : deals.size() %> results</span>
                </div>
                <table class="pipeline-table">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Customer</th>
                            <th>Value</th>
                            <th>Stage</th>
                            <th>Assigned</th>
                            <th class="pt-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (deals == null || deals.isEmpty()) { %>
                        <tr><td colspan="6">
                            <div class="mu-empty-state">
                                <div class="mu-empty-icon"><i data-lucide="trending-up"></i></div>
                                <p style="color:var(--crm-text-3);font-size:14px;">No deals found</p>
                            </div>
                        </td></tr>
                    <% } else { for (Deal deal : deals) {
                        boolean canManage = isAdmin || (deal.getAssignedUserId() != null && deal.getAssignedUserId() == user.getId());
                        String valueText = deal.getValue() != null ? String.format("$%,.2f", deal.getValue()) : "$0.00";
                    %>
                        <tr>
                            <td class="pt-name"><%= deal.getTitle() %></td>
                            <td class="pt-muted"><%= deal.getCustomerName() != null ? deal.getCustomerName() : "—" %></td>
                            <td class="pt-value"><%= valueText %></td>
                            <td>
                                <% if (canManage) { %>
                                <form method="POST" action="${pageContext.request.contextPath}/deals" style="margin:0;">
                                    <input type="hidden" name="action" value="updateStage">
                                    <input type="hidden" name="dealId" value="<%= deal.getId() %>">
                                    <input type="hidden" name="customerId" value="<%= deal.getCustomerId() %>">
                                    <select name="stage" class="deal-stage-select" onchange="this.form.submit()">
                                        <% for (String s : stages) { %>
                                            <option value="<%= s %>" <%= s.equalsIgnoreCase(deal.getStage()) ? "selected" : "" %>><%= s %></option>
                                        <% } %>
                                    </select>
                                </form>
                                <% } else { %>
                                    <span class="deal-stage-badge deal-stage-badge--<%= deal.getStage() != null ? deal.getStage().toLowerCase().replace(" ","-") : "other" %>"><%= deal.getStage() %></span>
                                <% } %>
                            </td>
                            <td class="pt-muted"><%= deal.getAssignedUserName() != null ? deal.getAssignedUserName() : "Unassigned" %></td>
                            <td class="pt-right">
                                <div class="deal-table-actions">
                                    <% if (canManage) { %>
                                    <a href="${pageContext.request.contextPath}/deals?editId=<%= deal.getId() %>&showAdd=1" class="dta-edit"><i data-lucide="pencil"></i></a>
                                    <form method="POST" action="${pageContext.request.contextPath}/deals" style="margin:0;">
                                        <input type="hidden" name="action" value="deleteDeal">
                                        <input type="hidden" name="dealId" value="<%= deal.getId() %>">
                                        <input type="hidden" name="customerId" value="<%= deal.getCustomerId() %>">
                                        <button type="submit" class="dta-del"><i data-lucide="trash-2"></i></button>
                                    </form>
                                    <% } else { %>
                                        <span class="mu-td-muted">No access</span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<jsp:include page="/view/components/notifications-panel.jsp" />

<script>
(function () {
    /* View toggle */
    var pipeline = document.getElementById("pipelineView");
    var table    = document.getElementById("tableView");
    var btns     = document.querySelectorAll(".pvt-btn");

    function setView(v) {
        if (!pipeline || !table) return;
        if (v === "table") {
            pipeline.classList.add("is-hidden");
            table.classList.remove("is-hidden");
        } else {
            table.classList.add("is-hidden");
            pipeline.classList.remove("is-hidden");
        }
        btns.forEach(function (b) {
            b.classList.toggle("pvt-active", b.getAttribute("data-view") === v);
        });
        try { localStorage.setItem("crm-deals-view", v); } catch (e) {}
    }
    btns.forEach(function (b) { b.addEventListener("click", function () { setView(b.getAttribute("data-view")); }); });
    var saved = "";
    try { saved = localStorage.getItem("crm-deals-view") || "pipeline"; } catch(e) { saved = "pipeline"; }
    setView(saved);

    /* Add deal panel */
    var panel     = document.getElementById("addDealPanel");
    var openBtn   = document.getElementById("openAddDeal");
    var closeBtn  = document.getElementById("closeDealPanel");
    if (openBtn && panel) openBtn.addEventListener("click", function () { panel.classList.add("is-open"); });
    if (closeBtn && panel) closeBtn.addEventListener("click", function () { panel.classList.remove("is-open"); window.location.href = window.location.pathname; });
})();
</script>
</body>
</html>
