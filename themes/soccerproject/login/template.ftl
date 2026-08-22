<#--
  SoccerProject.com — custom login template shell.
  TARGET: Keycloak 26.7.1 (Quarkus).
  Replaces the base PatternFly template with the Heritage split layout.
  Used by login.ftl and every inherited *.ftl via <@layout.registrationLayout>.

  KC26 macro contract implemented here:
    • showAnotherWayIfPresent  — required param, pages pass it
    • messageHeader            — pages may override the card title
    • "socialProviders" section — KC25+ renders IdP buttons in their own section
    • try-another-way form     — auth.showTryAnotherWayLink()
    • attempted-username block — auth.showUsername() + loginRestartFlowUrl
-->
<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true>
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'en'}" data-env="${properties.environment!''}"<#if realm.internationalizationEnabled> dir="${((locale.rtl)!false)?then('rtl','ltr')}"</#if>>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow">
  <meta name="color-scheme" content="light dark">
  <title>${msg("loginTitle",(realm.displayName!''))}</title>
  <link rel="icon" href="${url.resourcesPath}/img/favicon.png">

  <#-- Set the theme before paint to avoid a flash of the wrong theme.
       The app (soccerproject.com) persists its scheme with Zustand under
       localStorage['soccerproject-settings'].state.themeMode ('dark'/'light').
       localStorage can't cross to this auth origin, so the SHARED source of
       truth is a parent-domain cookie (.soccerproject.com) that BOTH the app
       and this page's toggle write — so it's read FIRST. A stale on-page toggle
       must not beat a fresher app preference, so the login localStorage is only
       a fallback for when cookies are blocked.
       Precedence: (1) sp-color-scheme cookie (app + login toggle both write it),
       (2) sp-login-theme localStorage (same-origin fallback if cookies blocked),
       (3) app localStorage (same-origin only), (4) OS, (5) light.
       See INTEGRATION.md §6b. -->
  <script>
    (function () {
      function cookie(name) {
        var m = document.cookie.match('(?:^|; )' + name.replace(/([.$?*|{}()\[\]\\\/+^])/g, '\\$1') + '=([^;]*)');
        return m ? decodeURIComponent(m[1]) : null;
      }
      function norm(v) {
        if (!v) return null;
        v = ('' + v).toLowerCase();
        return (v === 'dark' || v === 'light') ? v : null;  // ignore "system"/"auto" → fall to OS
      }
      function fromAppStore() {
        try {
          var raw = localStorage.getItem('soccerproject-settings');
          if (!raw) return null;
          return norm((JSON.parse(raw).state || {}).themeMode);
        } catch (e) { return null; }
      }
      try {
        var t = norm(cookie('sp-color-scheme'))                // shared truth (app + login toggle)
             || norm(localStorage.getItem('sp-login-theme'))   // fallback if cookies are blocked
             || fromAppStore();                                // app localStorage (same-origin only)
        if (t) document.documentElement.setAttribute('data-theme', t);
      } catch (e) {}
    })();
  </script>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@500;600;700&family=Barlow+Semi+Condensed:wght@400;500;600;700&display=swap" rel="stylesheet">

  <#if properties.styles?has_content>
    <#list properties.styles?split(' ') as style>
      <link href="${url.resourcesPath}/${style}" rel="stylesheet">
    </#list>
  </#if>
</head>

<body class="sp-login-body ${bodyClass!}">
<div class="sp-login">

  <#-- Environment banner is injected here by JS on non-production deployments -->

  <#-- ===== Brand panel (left) ===== -->
  <aside class="sp-brand">
    <div class="sp-brand__top">
      <img class="sp-brand__mark" src="${url.resourcesPath}/img/puppet-white.png" alt="">
      <span class="sp-wordmark">SoccerProject<span class="dot">.com</span></span>
    </div>
    <div class="sp-brand__hero">
      <p class="sp-eyebrow">${msg("spTagline")}</p>
      <h1>${msg("spHeroTitle")}</h1>
      <p>${msg("spHeroLead")}</p>
    </div>
    <div class="sp-brand__foot">
      <div><b>${msg("spFootTitle")}</b>${msg("spFootLead")}</div>
    </div>
  </aside>

  <#-- ===== Form panel (right) ===== -->
  <main class="sp-form-panel">

    <div class="sp-chrome">
      <#-- Language dropdown (only when realm i18n is on) -->
      <#if realm.internationalizationEnabled && locale.supported?size gt 1>
        <#assign spCurLang = locale.currentLanguageTag>
        <#list locale.supported as l>
          <#if l.languageTag == locale.currentLanguageTag><#assign spCurLang = l.label></#if>
        </#list>
        <div class="sp-lang" id="sp-lang">
          <button type="button" class="sp-lang__btn" id="sp-lang-btn"
                  aria-haspopup="listbox" aria-expanded="false" aria-label="${msg("languages")}">
            <svg class="globe" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18M12 3a15 15 0 0 0 0 18"/></svg>
            <span class="sp-lang__cur">${spCurLang}</span>
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
          </button>
          <div class="sp-lang__menu" id="sp-lang-menu" role="listbox" aria-label="${msg("languages")}">
            <#list locale.supported as l>
              <a href="${l.url}" class="sp-lang__item <#if l.languageTag == locale.currentLanguageTag>is-current</#if>"
                 role="option" <#if l.languageTag == locale.currentLanguageTag>aria-selected="true"</#if> hreflang="${l.languageTag}">
                <span>${l.label}</span>
                <svg class="tick" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
              </a>
            </#list>
          </div>
        </div>
      </#if>

      <button type="button" class="sp-toggle" id="sp-theme-toggle"
              aria-label="${msg("spToggleTheme")}" title="${msg("spToggleTheme")}">
        <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
        <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4.2"/><path d="M12 2v2.5M12 19.5V22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M2 12h2.5M19.5 12H22M4.9 19.1l1.8-1.8M17.3 6.7l1.8-1.8"/></svg>
      </button>
    </div>

    <div class="sp-card">
      <div class="sp-card__brand">
        <img src="${url.resourcesPath}/img/puppet-white.png" alt="">
        <span class="sp-wordmark">SoccerProject<span class="dot">.com</span></span>
      </div>

      <#-- Header. KC26 pages may supply messageHeader to override the title. -->
      <div class="sp-card__head">
        <h2><#if messageHeader??>${kcSanitize(messageHeader)?no_esc}<#else><#nested "header"></#if></h2>
        <#if displayRequiredFields>
          <p class="sp-required-hint"><span class="req">*</span> ${msg("requiredFields")}</p>
        </#if>
      </div>

      <#-- ===== Keycloak global message / alert block ===== -->
      <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
        <div class="sp-alert sp-alert--${message.type}">
          <#if message.type = 'success'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></#if>
          <#if message.type = 'warning'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.6 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg></#if>
          <#if message.type = 'error'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.01"/></svg></#if>
          <#if message.type = 'info'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 16v-5M12 8h.01"/></svg></#if>
          <span>${kcSanitize(message.summary)?no_esc}</span>
        </div>
      </#if>

      <#-- ===== Attempted username + restart-login (KC26) ===== -->
      <#if auth?has_content && auth.showUsername() && !auth.showResetCredentials()>
        <div class="sp-attempted">
          <span class="sp-attempted__user" id="kc-attempted-username">${auth.attemptedUsername}</span>
          <a id="reset-login" href="${url.loginRestartFlowUrl}" class="sp-link"
             aria-label="${msg("restartLoginTooltip")}" title="${msg("restartLoginTooltip")}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/></svg>
            ${msg("restartLoginTooltip")}
          </a>
        </div>
      </#if>

      <#-- ===== Page body ===== -->
      <#nested "form">

      <#-- ===== Try another way (KC26 auth selector) ===== -->
      <#if auth?has_content && auth.showTryAnotherWayLink() && showAnotherWayIfPresent>
        <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post" class="sp-try-another">
          <input type="hidden" name="tryAnotherWay" value="on"/>
          <button type="submit" id="try-another-way" class="sp-linkbtn">${msg("doTryAnotherWay")}</button>
        </form>
      </#if>

      <#-- ===== Identity providers (KC25+ renders these in their own section) ===== -->
      <#nested "socialProviders">

      <#-- ===== Footer / registration ("info" section) ===== -->
      <#if displayInfo>
        <div class="sp-card__foot">
          <#nested "info">
        </div>
      </#if>
    </div>
  </main>
</div>

<script>
  (function () {
    var root = document.documentElement;
    var KEY = 'sp-login-theme';

    // ---- Environment banner (shown on any non-production deployment) ----
    // Source of truth: theme.properties `environment=` (rendered into data-env).
    // When blank, fall back to hostname detection. Set environment=production
    // (or leave a known prod host) to hide it.
    function detectEnv() {
      var o = (root.getAttribute('data-env') || '').trim().toLowerCase();
      var h = location.hostname.toLowerCase();
      var prodHosts = ['soccerproject.com', 'www.soccerproject.com', 'auth.soccerproject.com', 'login.soccerproject.com'];
      if (o === 'production' || o === 'prod') return null;
      if (o) {
        if (/stag|stg/.test(o)) return { kind: 'staging', label: o };
        if (/test|qa|acc/.test(o)) return { kind: 'test', label: o };
        if (/dev/.test(o)) return { kind: 'dev', label: o };
        if (/local/.test(o)) return { kind: 'local', label: o };
        return { kind: 'nonprod', label: o };
      }
      if (prodHosts.indexOf(h) !== -1) return null;
      if (h === 'localhost' || h === '127.0.0.1' || h === '::1' || /\.local$/.test(h)) return { kind: 'local', label: 'Local' };
      if (/stag|stg/.test(h)) return { kind: 'staging', label: 'Staging' };
      if (/test|qa|acc/.test(h)) return { kind: 'test', label: 'Test / QA' };
      if (/dev/.test(h)) return { kind: 'dev', label: 'Development' };
      return { kind: 'nonprod', label: 'Non-production' };
    }
    var env = detectEnv();
    if (env) {
      var bar = document.createElement('div');
      bar.className = 'sp-env';
      bar.setAttribute('data-kind', env.kind);
      bar.setAttribute('role', 'status');
      bar.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.6 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg>'
        + '<span><b>' + env.label + '</b> environment</span>';
      var stage = document.querySelector('.sp-login');
      stage.insertBefore(bar, stage.firstChild);
      requestAnimationFrame(function () { stage.style.setProperty('--env-h', bar.offsetHeight + 'px'); });
    }

    var btn = document.getElementById('sp-theme-toggle');
    if (btn) {
      var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)');
      // Effective theme = explicit attribute, else OS, else light (matches CSS).
      var effective = function () {
        var a = root.getAttribute('data-theme');
        if (a === 'dark' || a === 'light') return a;
        return (prefersDark && prefersDark.matches) ? 'dark' : 'light';
      };
      btn.addEventListener('click', function () {
        var next = effective() === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        // Persist on this origin AND mirror to the app via the parent-domain
        // cookie, so the choice propagates both ways. See INTEGRATION.md §6b.
        try { localStorage.setItem(KEY, next); } catch (e) {}
        try {
          document.cookie = 'sp-color-scheme=' + next +
            '; Domain=.soccerproject.com; Path=/; Max-Age=31536000; SameSite=Lax; Secure';
        } catch (e) {}
      });
    }

    // language dropdown
    var lang = document.getElementById('sp-lang');
    if (lang) {
      var lbtn = document.getElementById('sp-lang-btn');
      var close = function () { lang.classList.remove('is-open'); lbtn.setAttribute('aria-expanded', 'false'); };
      lbtn.addEventListener('click', function (e) {
        e.stopPropagation();
        var open = !lang.classList.contains('is-open');
        lang.classList.toggle('is-open', open);
        lbtn.setAttribute('aria-expanded', String(open));
        if (open) {
          var cur = lang.querySelector('.sp-lang__item.is-current') || lang.querySelector('.sp-lang__item');
          if (cur) cur.focus();
        }
      });
      document.addEventListener('click', function (e) { if (!lang.contains(e.target)) close(); });
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
    }
    // progressive enhancement: password reveal toggles
    document.querySelectorAll('[data-sp-eye]').forEach(function (b) {
      b.addEventListener('click', function () {
        var inp = document.getElementById(b.getAttribute('data-sp-eye'));
        if (!inp) return;
        var show = inp.type === 'password';
        inp.type = show ? 'text' : 'password';
        b.setAttribute('aria-label', show ? '${msg("spHidePassword")}' : '${msg("spShowPassword")}');
      });
    });
  })();
</script>
</body>
</html>
</#macro>
