<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Notification fragment included via fetch() into the floating panel.
    // Parent JSP has already validated session/user.
    @SuppressWarnings("unchecked")
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM d, yyyy h:mm a");
%>

<div class="ntf-panel">
    <%
        if (notifications != null && !notifications.isEmpty()) {
    %>
        <div class="ntf-panel-actions">
            <form method="POST" action="${pageContext.request.contextPath}/notifications" style="margin:0;">
                <input type="hidden" name="action" value="markAllRead">
                <button type="submit" class="btn-ghost">Mark all as read</button>
            </form>
        </div>
    <%
            for (Notification n : notifications) {
                boolean unread = !n.isRead();
                String itemClass = unread ? "ntf-item ntf-item--unread" : "ntf-item ntf-item--read";
                String time = "";
                if (n.getCreatedAt() != null) {
                    time = n.getCreatedAt().toInstant().atZone(ZoneId.systemDefault()).format(fmt);
                }
                String targetUrl = "";
                if ("customer".equalsIgnoreCase(n.getEntityType()) && n.getEntityId() > 0) {
                    targetUrl = request.getContextPath() + "/customers?customerId=" + n.getEntityId();
                } else if ("task".equalsIgnoreCase(n.getEntityType()) && n.getRelatedCustomerId() > 0) {
                    targetUrl = request.getContextPath() + "/customers?customerId=" + n.getRelatedCustomerId() + "#tasks";
                }
                String linkUrl = "";
                if (!targetUrl.isEmpty()) {
                    linkUrl = request.getContextPath() + "/notifications?action=markRead&notificationId=" + n.getId()
                            + "&redirect=" + URLEncoder.encode(targetUrl, "UTF-8");
                }
    %>
        <div class="<%= itemClass %>">
            <div class="ntf-item-head">
                <div>
                    <% if (!linkUrl.isEmpty()) { %>
                        <a class="ntf-item-body" href="<%= linkUrl %>">
                            <p class="ntf-item-title"><%= n.getMessage() %></p>
                            <div class="ntf-item-meta">
                                <span><%= n.getType() == null ? "" : n.getType() %></span>
                                <span class="ntf-item-meta-dot">&bull;</span>
                                <span><%= time %></span>
                            </div>
                        </a>
                    <% } else { %>
                        <div class="ntf-item-body">
                            <p class="ntf-item-title"><%= n.getMessage() %></p>
                            <div class="ntf-item-meta">
                                <span><%= n.getType() == null ? "" : n.getType() %></span>
                                <span class="ntf-item-meta-dot">&bull;</span>
                                <span><%= time %></span>
                            </div>
                        </div>
                    <% } %>
                </div>
                <div>
                    <% if (unread) { %>
                        <form method="POST" action="${pageContext.request.contextPath}/notifications" style="margin:0;">
                            <input type="hidden" name="action" value="markRead">
                            <input type="hidden" name="notificationId" value="<%= n.getId() %>">
                            <button type="submit" class="btn-ghost">Mark read</button>
                        </form>
                    <% } else { %>
                        <span class="ntf-item-read-tag"><i data-lucide="check"></i> Read</span>
                    <% } %>
                </div>
            </div>
        </div>
    <%
            }
        } else {
    %>
        <div class="ntf-empty">
            <i data-lucide="bell-off"></i>
            No notifications yet.
        </div>
    <%
        }
    %>
</div>
