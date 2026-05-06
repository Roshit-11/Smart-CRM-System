<%@ page import="com.crm.app.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String userName = user != null && user.getName() != null ? user.getName() : "User";
    String avatarLetter = userName.trim().isEmpty() ? "U" : userName.substring(0, 1).toUpperCase();
    String companyName = (String) session.getAttribute("companyName");
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = user != null ? user.getCompanyName() : "SmartCRM";
    }
    if (companyName == null || companyName.trim().isEmpty()) {
        companyName = "SmartCRM";
    }
    Integer unread = (Integer) request.getAttribute("unreadNotifications");
    int unreadCount = unread != null ? unread : 0;
%>
<header class="saas-topnav">
    <div class="saas-topnav-left">
        <button type="button" class="saas-sidebar-toggle" aria-label="Open menu">
            <i data-lucide="menu"></i>
        </button>
        SmartCRM
    </div>

    <div class="saas-topnav-right">
        <a href="#" id="ntfBell" class="saas-topnav-icon" aria-label="Notifications">
            <i data-lucide="bell-ring"></i>
            <% if (unreadCount > 0) { %>
                <span class="ntf-badge"><%= unreadCount %></span>
            <% } %>
        </a>

        <div class="saas-profile-chip saas-profile-topnav">
            <div class="saas-avatar"><%= avatarLetter %></div>
            <div class="saas-profile-meta">
                <strong><%= userName %></strong>
                <span><%= companyName %></span>
            </div>
            <span class="saas-dropdown"><i data-lucide="chevron-down"></i></span>
        </div>
    </div>
</header>
