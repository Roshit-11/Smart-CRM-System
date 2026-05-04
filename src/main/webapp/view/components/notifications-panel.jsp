<%-- Floating notifications dropdown panel.
     Include once per dashboard page, AFTER the top-navbar include.
     Behavior is wired up in /js/app.js (no inline JS needed). --%>
<div id="ntfPanel" class="ntf-dropdown" role="dialog" aria-label="Notifications">
    <div class="ntf-dropdown-head">
        <strong>Notifications</strong>
        <button type="button" id="ntfClose" class="ntf-close" aria-label="Close notifications">
            <i data-lucide="x"></i>
        </button>
    </div>
    <div id="ntfPanelBody">
        <div class="ntf-loading">
            <div class="skeleton skeleton-line"></div>
            <div class="skeleton skeleton-line"></div>
            <div class="skeleton skeleton-line"></div>
        </div>
    </div>
</div>
<script>window.__APP_CTX_PATH__ = "${pageContext.request.contextPath}";</script>
