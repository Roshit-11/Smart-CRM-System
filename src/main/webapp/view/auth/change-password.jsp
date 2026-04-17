<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">
</head>
<body class="auth-modal-page">
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<header class="brand-fixed">
    <span>SmartCRM</span>
</header>
<main class="auth-modal-wrapper">
    <section class="login-modal">
        <div class="login-modal-left">
            <div class="login-modal-left-content">
                <img src="${pageContext.request.contextPath}/images/laptop.png" alt="Security" class="login-laptop-image">
            </div>
        </div>

        <div class="login-modal-right">
            <h2 class="login-title">CHANGE PASSWORD</h2>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="error-message"><%= error %></div>
            <%
                }
            %>

            <form action="${pageContext.request.contextPath}/change-password" method="POST">
                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" minlength="8" required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" required>
                </div>

                <button type="submit" class="login-submit-btn">Update Password</button>
            </form>
        </div>
    </section>
</main>
</body>
</html>