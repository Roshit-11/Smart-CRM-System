<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260504b">
    <jsp:include page="/view/components/page-head.jsp" />
</head>
<body class="auth-modal-page register-page">
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
                <h2 class="login-title">REGISTER</h2>
                <p class="login-subtitle">Create your account to get started.</p>

                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                %>
                    <div class="error-message"><i data-lucide="alert-circle"></i><span><%= error %></span></div>
                <%
                    }
                %>

                <form action="${pageContext.request.contextPath}/register" method="POST" data-loading data-loading-text="Creating account...">
                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" name="name" required>
                    </div>

                    <div class="form-group">
                        <label>Company Name</label>
                        <input type="text" name="company_name" required>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <div class="auth-input-wrap">
                            <input type="password" name="password" required data-password-strength minlength="8">
                            <button type="button" class="auth-password-toggle" aria-label="Toggle password visibility">
                                <i data-lucide="eye"></i>
                            </button>
                        </div>
                        <div class="password-strength"><div class="password-strength-bar" data-strength="0"></div></div>
                    </div>

                    <button type="submit" class="login-submit-btn">Register</button>
                </form>

                <div class="link-container">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/login">Login here</a>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
