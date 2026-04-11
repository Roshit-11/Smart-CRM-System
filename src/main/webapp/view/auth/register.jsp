<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - SmartCRM</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260411">
</head>
<body class="auth-modal-page">
<header class="brand-fixed">
    
    <span>SmartCRM</span>
</header>
    <main class="auth-modal-wrapper">
        <section class="login-modal">

            <button type="button" class="modal-close" aria-label="Close">&times;</button>

            <!-- LEFT SIDE -->
            <div class="login-modal-left">
                <div class="login-modal-left-content">
                    <h2 class="hero-line line1">Manage customers.</h2>
                    <h2 class="hero-line line2">Close deals. Grow faster.</h2>
                </div>
            </div>

            <!-- RIGHT SIDE -->
            <div class="login-modal-right">

                <h2 class="login-title">REGISTER</h2>

                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                %>
                    <div class="error-message"><%= error %></div>
                <%
                    }
                %>

                <form action="${pageContext.request.contextPath}/auth?action=register" method="POST">

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
                        <input type="password" name="password" required>
                    </div>

                    <button type="submit" class="login-submit-btn">Register</button>
                </form>

                <div class="link-container">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/view/auth/login.jsp">Login here</a>
                </div>

            </div>

        </section>
    </main>

</body>
</html>