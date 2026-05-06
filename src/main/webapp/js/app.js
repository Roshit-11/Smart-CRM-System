/* SmartCRM — global frontend behaviors
 * Loaded on every dashboard page. Self-contained, no dependencies
 * other than Lucide (loaded separately).
 */
(function () {
    "use strict";

    function ready(fn) {
        if (document.readyState !== "loading") fn();
        else document.addEventListener("DOMContentLoaded", fn);
    }

    /* ── 1. Lucide icon initialization (call after DOM ready) ── */
    function initLucide() {
        if (window.lucide && typeof window.lucide.createIcons === "function") {
            window.lucide.createIcons();
        }
    }

    /* ── 2. Mobile sidebar drawer ────────────────────────────── */
    function initSidebarToggle() {
        var toggle = document.querySelector(".saas-sidebar-toggle");
        var sidebar = document.querySelector(".saas-sidebar");
        if (!toggle || !sidebar) return;

        var backdrop = document.querySelector(".saas-sidebar-backdrop");
        if (!backdrop) {
            backdrop = document.createElement("div");
            backdrop.className = "saas-sidebar-backdrop";
            document.body.appendChild(backdrop);
        }

        function open() { sidebar.classList.add("open"); backdrop.classList.add("open"); }
        function close() { sidebar.classList.remove("open"); backdrop.classList.remove("open"); }

        toggle.addEventListener("click", function (e) {
            e.preventDefault();
            if (sidebar.classList.contains("open")) close(); else open();
        });
        backdrop.addEventListener("click", close);
    }

    /* ── 3. Notification dropdown panel ──────────────────────── */
    function initNotificationPanel() {
        var bell = document.getElementById("ntfBell");
        var panel = document.getElementById("ntfPanel");
        var body = document.getElementById("ntfPanelBody");
        var closeBtn = document.getElementById("ntfClose");
        if (!bell || !panel || !body) return;

        var ctx = (window.__APP_CTX_PATH__ || "");

        function loadingHtml() {
            return '<div class="ntf-loading">' +
                '<div class="skeleton skeleton-line"></div>' +
                '<div class="skeleton skeleton-line"></div>' +
                '<div class="skeleton skeleton-line"></div></div>';
        }

        function closePanel() { panel.classList.remove("open"); }

        function openPanel() {
            panel.classList.add("open");
            body.innerHTML = loadingHtml();
            fetch(ctx + "/notifications?fragment=1", {
                headers: { "X-Requested-With": "fetch" }
            })
            .then(function (res) { return res.text(); })
            .then(function (html) {
                body.innerHTML = html;
                initLucide();
            })
            .catch(function () {
                body.innerHTML = '<div class="ntf-error">Failed to load notifications.</div>';
            });
        }

        bell.addEventListener("click", function (e) {
            e.preventDefault();
            if (panel.classList.contains("open")) closePanel(); else openPanel();
        });

        if (closeBtn) closeBtn.addEventListener("click", closePanel);

        document.addEventListener("click", function (e) {
            if (!panel.classList.contains("open")) return;
            if (e.target === bell || bell.contains(e.target)) return;
            if (panel.contains(e.target)) return;
            closePanel();
        });
    }

    /* ── 4. Toast notifications ──────────────────────────────── */
    function ensureToastContainer() {
        var c = document.querySelector(".toast-container");
        if (!c) {
            c = document.createElement("div");
            c.className = "toast-container";
            document.body.appendChild(c);
        }
        return c;
    }
    window.showToast = function (message, type) {
        type = type || "info";
        var c = ensureToastContainer();
        var t = document.createElement("div");
        t.className = "toast toast--" + type;
        var iconName = type === "success" ? "check-circle" :
                       type === "error"   ? "alert-circle" :
                       type === "warning" ? "alert-triangle" : "info";
        t.innerHTML = '<span class="toast-icon"><i data-lucide="' + iconName + '"></i></span>' +
                      '<div class="toast-body">' + message + '</div>';
        c.appendChild(t);
        initLucide();
        setTimeout(function () {
            t.style.transition = "opacity .3s ease, transform .3s ease";
            t.style.opacity = "0";
            t.style.transform = "translateY(8px)";
            setTimeout(function () { t.remove(); }, 300);
        }, 4000);
    };

    /* ── 5. Delete confirmation pattern (double-click safety) ── */
    function initDeleteConfirm() {
        document.querySelectorAll("[data-confirm-delete]").forEach(function (btn) {
            var original = btn.innerHTML;
            var armed = false;
            btn.addEventListener("click", function (e) {
                if (!armed) {
                    e.preventDefault();
                    armed = true;
                    btn.innerHTML = "Confirm?";
                    btn.classList.add("cu-action-confirm");
                    setTimeout(function () {
                        armed = false;
                        btn.innerHTML = original;
                        btn.classList.remove("cu-action-confirm");
                        initLucide();
                    }, 3000);
                }
            });
        });
    }

    /* ── 6. Password toggle (eye icon in auth forms) ─────────── */
    function initPasswordToggle() {
        document.querySelectorAll(".auth-password-toggle").forEach(function (btn) {
            btn.addEventListener("click", function (e) {
                e.preventDefault();
                var wrap = btn.closest(".auth-input-wrap");
                if (!wrap) return;
                var input = wrap.querySelector("input");
                if (!input) return;
                var icon = btn.querySelector("[data-lucide]");
                if (input.type === "password") {
                    input.type = "text";
                    if (icon) icon.setAttribute("data-lucide", "eye-off");
                } else {
                    input.type = "password";
                    if (icon) icon.setAttribute("data-lucide", "eye");
                }
                initLucide();
            });
        });
    }

    /* ── 7. Password strength meter ──────────────────────────── */
    function initPasswordStrength() {
        var pw = document.querySelector("[data-password-strength]");
        if (!pw) return;
        var bar = document.querySelector(".password-strength-bar");
        if (!bar) return;
        pw.addEventListener("input", function () {
            var v = pw.value || "";
            var s = 0;
            if (v.length >= 8) s++;
            if (/[A-Z]/.test(v) && /[a-z]/.test(v)) s++;
            if (/\d/.test(v)) s++;
            if (/[^A-Za-z0-9]/.test(v)) s++;
            bar.setAttribute("data-strength", String(s));
        });
    }

    /* ── 8. Theme toggle (dark/light mode) ───────────────────── */
    function initThemeToggle() {
        var storageKey = "smartcrm-theme";
        var root = document.documentElement;
        var toggle = document.getElementById("darkModeToggle");

        function applyTheme(theme) {
            if (theme === "dark") root.setAttribute("data-theme", "dark");
            else root.removeAttribute("data-theme");
        }

        var stored = null;
        try { stored = localStorage.getItem(storageKey); } catch (e) { stored = null; }
        var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
        var theme = stored || (prefersDark ? "dark" : "light");
        applyTheme(theme);

        if (!toggle) return;
        toggle.checked = theme === "dark";
        toggle.addEventListener("change", function () {
            var next = toggle.checked ? "dark" : "light";
            try { localStorage.setItem(storageKey, next); } catch (e) {}
            applyTheme(next);
        });
    }

    /* ── 9. Date input: scroll into view so the native picker fits ─ */
    function initDateInputScroll() {
        document.querySelectorAll('input[type="date"]').forEach(function (input) {
            input.addEventListener("focus", function () {
                // Defer so the browser opens the picker first, then we scroll
                setTimeout(function () {
                    try {
                        input.scrollIntoView({ block: "center", behavior: "smooth" });
                    } catch (e) {
                        input.scrollIntoView();
                    }
                }, 50);
            });
        });
    }

    /* ── 10. Form submit loading state ────────────────────────── */
    function initFormLoading() {
        document.querySelectorAll("form[data-loading]").forEach(function (form) {
            form.addEventListener("submit", function () {
                var btn = form.querySelector("button[type=submit]");
                if (!btn || btn.disabled) return;
                var orig = btn.innerHTML;
                btn.disabled = true;
                btn.innerHTML = '<span class="spinner-inline"></span>' + (btn.getAttribute("data-loading-text") || "Working...");
                setTimeout(function () {
                    if (btn.disabled) {
                        btn.disabled = false;
                        btn.innerHTML = orig;
                    }
                }, 8000);
            });
        });
    }

    ready(function () {
        initLucide();
        initSidebarToggle();
        initNotificationPanel();
        initDeleteConfirm();
        initPasswordToggle();
        initPasswordStrength();
        initThemeToggle();
        initDateInputScroll();
        initFormLoading();
    });
})();