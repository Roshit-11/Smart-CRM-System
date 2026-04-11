<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - CRM System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">
</head>
<body>
    <%
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/view/auth/login.jsp");
            return;
        }
    %>
    
    <div class="dashboard-container">
        <div class="header">
            <h1>CRM Management System</h1>
            <div class="header-actions">
                <a href="${pageContext.request.contextPath}/auth?action=logout" class="logout-link">Logout</a>
            </div>
        </div>
        
        <div class="container">
            <div class="welcome-message">
                Welcome, <strong><%= user.getName() %></strong>!
            </div>
            
            <div class="user-info">
                <h3>Your Profile</h3>
                <div class="info-row">
                    <span class="label">Email:</span>
                    <span><%= user.getEmail() %></span>
                </div>
                <div class="info-row">
                    <span class="label">Role:</span>
                    <span><%= user.getRole() %></span>
                </div>
                <div class="info-row">
                    <span class="label">User ID:</span>
                    <span><%= user.getId() %></span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>