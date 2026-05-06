<%-- Shared <head> assets — fonts, Lucide icons, and the global app.js loader.
     Include after the <link> to style.css in any page <head>. --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css?v=20260509">
<script src="https://unpkg.com/lucide@0.378.0/dist/umd/lucide.min.js" defer></script>
<script src="<%= request.getContextPath() %>/js/app.js?v=20260504" defer></script>
