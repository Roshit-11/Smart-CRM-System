<%@ page import="com.crm.app.model.User" %>
<%
    User u_usrSide = (User) session.getAttribute("user");
    String companyName_usrSide = (String) session.getAttribute("companyName");
    if (companyName_usrSide == null || companyName_usrSide.trim().isEmpty()) {
        companyName_usrSide = u_usrSide != null ? u_usrSide.getCompanyName() : "SmartCRM";
    }
    if (companyName_usrSide == null || companyName_usrSide.trim().isEmpty()) {
        companyName_usrSide = "SmartCRM";
    }
    String companyInitial_usrSide = companyName_usrSide.substring(0, 1).toUpperCase();
    String activeNav_usrSide = (String) request.getAttribute("activeNav");
    if (activeNav_usrSide == null) activeNav_usrSide = "";
%>
<aside class="saas-sidebar">
    <div class="saas-logo">
        <span class="saas-logo-mark"><%= companyInitial_usrSide %></span>
        <span class="saas-logo-text"><%= companyName_usrSide %></span>
    </div>

    <nav class="saas-nav">
        <a href="${pageContext.request.contextPath}/dashboard" class="saas-nav-item<%= "dashboard".equals(activeNav_usrSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="layout-dashboard"></i></span>
            <span class="saas-nav-label">Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/customers" class="saas-nav-item<%= "customers".equals(activeNav_usrSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="users"></i></span>
            <span class="saas-nav-label">Customers</span>
        </a>
        <a href="${pageContext.request.contextPath}/reports" class="saas-nav-item<%= "reports".equals(activeNav_usrSide) ? " active" : "" %>">
            <span class="saas-nav-icon"><i data-lucide="bar-chart-3"></i></span>
            <span class="saas-nav-label">Reports</span>
        </a>
        <a href="${pageContext.request.contextPath}/settings" class="saas-nav-item<%= "settings".equals(activeNav_usrSide) ? " active" : "" %>">
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
