<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260504b">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body class="auth-modal-page">
<header class="brand-fixed">
    <span>SmartCRM</span>
</header>
    <main class="auth-modal-wrapper">
        <section class="login-modal">
            <button type="button" class="modal-close" aria-label="Close">&times;</button>

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
                <h2 class="login-title">LOGIN</h2>
                <p class="login-subtitle">Welcome back. Please login to continue.</p>

                <%
                    String error = (String) request.getAttribute("error");
                    String success = (String) request.getAttribute("success");
                    if (error != null) {
                %>
                    <div class="error-message"><i data-lucide="alert-circle"></i><span><%= error %></span></div>
                <%
                    }
                    if (success != null) {
                %>
                    <div class="success-message"><i data-lucide="check-circle"></i><span><%= success %></span></div>
                <%
                    }
                %>

                <form action="${pageContext.request.contextPath}/login" method="POST" data-loading data-loading-text="Signing in...">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="auth-input-wrap">
                            <input type="password" id="password" name="password" required>
                            <button type="button" class="auth-password-toggle" aria-label="Toggle password visibility">
                                <i data-lucide="eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="login-submit-btn">Login</button>
                </form>

                <div class="link-container">
                    Don't have an account? <a href="${pageContext.request.contextPath}/register">Register here</a>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
