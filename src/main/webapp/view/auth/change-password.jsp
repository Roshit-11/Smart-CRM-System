<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.crm.app.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260509">
    <jsp:include page="/view/components/page-head.jsp" />
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
                <p class="left-panel-intro">SmartCRM Platform</p>
                <h2 class="hero-line line1">Manage customers smarter.</h2>
                <h2 class="hero-line line2">Close deals faster.</h2>
                <ul class="left-panel-bullets">
                    <li><span class="left-panel-bullet-check"><i data-lucide="check-circle-2"></i></span> Lead Tracking</li>
                    <li><span class="left-panel-bullet-check"><i data-lucide="check-circle-2"></i></span> Deal Pipeline</li>
                    <li><span class="left-panel-bullet-check"><i data-lucide="check-circle-2"></i></span> Team Collaboration</li>
                </ul>
            </div>
        </div>
        <div class="login-modal-right">
            <h2 class="login-title">CHANGE PASSWORD</h2>
            <p class="login-subtitle">Set a strong new password to secure your account.</p>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="error-message"><i data-lucide="alert-circle"></i><span><%= error %></span></div>
            <%
                }
            %>

            <form action="${pageContext.request.contextPath}/change-password" method="POST" data-loading data-loading-text="Updating...">
                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <div class="auth-input-wrap">
                        <input type="password" id="newPassword" name="newPassword" minlength="8" required data-password-strength>
                        <button type="button" class="auth-password-toggle" aria-label="Toggle password visibility">
                            <i data-lucide="eye"></i>
                        </button>
                    </div>
                    <div class="password-strength"><div class="password-strength-bar" data-strength="0"></div></div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <div class="auth-input-wrap">
                        <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" required>
                        <button type="button" class="auth-password-toggle" aria-label="Toggle password visibility">
                            <i data-lucide="eye"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="login-submit-btn">Update Password</button>
            </form>
        </div>
    </section>
</main>
</body>
</html>
