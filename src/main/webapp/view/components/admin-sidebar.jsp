<%@ page import="com.crm.app.model.User" %>
<%
    User u_admSide = (User) session.getAttribute("user");
    String companyName_admSide = (String) session.getAttribute("companyName");
    if (companyName_admSide == null || companyName_admSide.trim().isEmpty()) {
        companyName_admSide = u_admSide != null ? u_admSide.getCompanyName() : "SmartCRM";
    }
    if (companyName_admSide == null || companyName_admSide.trim().isEmpty()) {
        companyName_admSide = "SmartCRM";
    }
    String companyInitial_admSide = companyName_admSide.substring(0, 1).toUpperCase();
    String activeNav_admSide = (String) request.getAttribute("activeNav");
    if (activeNav_admSide == null) activeNav_admSide = "";
%>
<aside class="saas-sidebar">
    <div class="saas-logo">
        <span class="saas-logo-mark"><%= companyInitial_admSide %></span>
        <span class="saas-logo-text"><%= companyName_admSide %></span>
    </div>

    <nav class="saas-nav">
        <a href="${pageContext.request.contextPath}/admin-dashboard" class="saas-nav-item<%= "dashboard".equals(activeNav_admSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="layout-dashboard"></i></span>
            <span class="saas-nav-label">Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/customers" class="saas-nav-item<%= "customers".equals(activeNav_admSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="users"></i></span>
            <span class="saas-nav-label">Customers</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports" class="saas-nav-item<%= "reports".equals(activeNav_admSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="bar-chart-3"></i></span>
            <span class="saas-nav-label">Reports</span>
        </a>
        <a href="${pageContext.request.contextPath}/manage-users" class="saas-nav-item<%= "users".equals(activeNav_admSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="user-cog"></i></span>
            <span class="saas-nav-label">Manage Users</span>
        </a>
        <a href="${pageContext.request.contextPath}/settings" class="saas-nav-item<%= "settings".equals(activeNav_admSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="settings"></i></span>
            <span class="saas-nav-label">Settings</span>
        </a>
    </nav>

    <form action="${pageContext.request.contextPath}/logout" method="POST" class="saas-logout-form">
        <button type="submit" class="saas-nav-item saas-logout-btn">
            <span class="saas-nav-icon"><i data-lucide="log-out"></i></span>
            <span class="saas-nav-label">Logout</span>
        </button>
    </form>
</aside>
