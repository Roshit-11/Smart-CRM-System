<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">   
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
                    <h2 class="hero-line line1">Manage customers.</h2>
                    <h2 class="hero-line line2">Close deals. Grow faster.</h2>
                </div>
            </div>

            <div class="login-modal-right">
                <h2 class="login-title">LOGIN</h2>

                <%
                    String error = (String) request.getAttribute("error");
                    String success = (String) request.getAttribute("success");
                    if (error != null) {
                %>
                    <div class="error-message"><%= error %></div>
                <%
                    }
                    if (success != null) {
                %>
                    <div class="success-message"><%= success %></div>
                <%
                    }
                %>

                <form action="${pageContext.request.contextPath}/auth?action=login" method="POST">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" required>
                    </div>

                    <button type="submit" class="login-submit-btn">Login</button>
                </form>

                <div class="link-container">
                    Don't have an account? <a href="${pageContext.request.contextPath}/view/auth/register.jsp">Register here</a>
                </div>
            </div>
        </section>
    </main>
</body>
</html>