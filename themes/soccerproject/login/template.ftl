<#--
  SoccerProject.com — login-theme page shell.
  TARGET: Keycloak 26.7.1 (Quarkus).

  Rewritten for reesing322/soccerproject-frontend#725. Replaces the base
  PatternFly template with the public landing page's own composition:

      masthead (AppShell `.masthead`)
      hero gradient  ->  hero copy | white card   (landing `.lp-hero`)
      footer     (AppShell `.lp-shell-footer`)

  Used by login.ftl, register.ftl and every inherited *.ftl through
  <@layout.registrationLayout>. The KC26 macro contract implemented here:

    * showAnotherWayIfPresent  — required param, pages pass it
    * messageHeader            — pages may override the card title
    * "socialProviders" section — KC25+ renders IdP buttons in their own section
    * try-another-way form     — auth.showTryAnotherWayLink()
    * attempted-username block — auth.showUsername() + loginRestartFlowUrl

  NO THEME TOGGLE, and no dark palette. The landing page pins its colours
  (`src/pages/landing/tokens.ts`) and deliberately renders no theme control,
  because it is shown to people who have never chosen one. These pages are the
  next click of that same pre-auth journey, so they pin the same palette: a
  visitor who pressed a gold button on a navy gradient must not land on a
  differently-coloured page. See the CSS header for the token source.
-->
<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true>
<#assign spSite = properties.kcLogoLink!'https://www.soccerproject.com'>
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'en'}" data-env="${properties.environment!''}"<#if realm.internationalizationEnabled> dir="${((locale.rtl)!false)?then('rtl','ltr')}"</#if>>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow">
  <#-- Light only, on purpose: see the macro comment above. Declaring "light dark"
       here would let the browser paint form controls and scrollbars dark on a
       page whose every surface is the landing page's white. -->
  <meta name="color-scheme" content="light">
  <#-- The masthead colour, so a mobile browser's own chrome continues the page
       the same way it does on soccerproject.com. -->
  <meta name="theme-color" content="#101822">
  <title>${msg("loginTitle",(realm.displayName!''))}</title>
  <link rel="icon" href="${url.resourcesPath}/img/favicon.png">
  <link rel="apple-touch-icon" href="${url.resourcesPath}/img/apple-touch-icon.png">

  <#-- No webfont link. The landing page renders in the system UI stack
       (`.lp-page` in landing.css); loading Oswald/Barlow from Google here would
       change the typography mid-funnel AND block first paint on a third-party
       round trip. See --sp-font in the stylesheet. -->

  <#if properties.styles?has_content>
    <#list properties.styles?split(' ') as style>
      <link href="${url.resourcesPath}/${style}" rel="stylesheet">
    </#list>
  </#if>

  <#-- Pages that ship their own head resources (theme-resources.ftl in the base
       theme handles scripts= / styles= contributed by SPI providers). -->
  <#if scripts??>
    <#list scripts as script>
      <script src="${script}" type="text/javascript"></script>
    </#list>
  </#if>
</head>

<body class="sp-login-body ${bodyClass!}">
<div class="sp-shell">

  <#-- Environment banner is injected here by the script at the end of <body>
       on any non-production deployment. -->

  <#-- ===================== Masthead (AppShell `.masthead`) ===================== -->
  <header class="sp-masthead">
    <a class="sp-brand" href="${spSite}" aria-label="SoccerProject.com">
      <span class="sp-brand__mark"><img src="${url.resourcesPath}/img/puppet-white.png" alt="" aria-hidden="true"></span>
      <span class="sp-wordmark">SoccerProject<span class="tld">.com</span></span>
    </a>
    <div class="sp-masthead__spacer"></div>
    <div class="sp-masthead__right">
      <#-- Language picker. Renders only when realm internationalisation is on
           AND more than one locale is enabled — a dropdown with one item is a
           control that does nothing. The realm's `supportedLocales` and this
           theme's `locales=` have to agree; see theme.properties. -->
      <#if realm.internationalizationEnabled && locale?? && locale.supported?? && locale.supported?size gt 1>
        <#assign spCurLang = locale.currentLanguageTag>
        <#list locale.supported as l>
          <#if l.languageTag == locale.currentLanguageTag><#assign spCurLang = l.label></#if>
        </#list>
        <div class="sp-lang" id="sp-lang">
          <button type="button" class="sp-lang__btn" id="sp-lang-btn"
                  aria-haspopup="listbox" aria-expanded="false"
                  aria-controls="sp-lang-menu" aria-label="${msg("languages")}">
            <svg class="globe" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18M12 3a15 15 0 0 0 0 18"/></svg>
            <span class="sp-lang__cur">${spCurLang}</span>
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>
          </button>
          <div class="sp-lang__menu" id="sp-lang-menu" role="listbox" aria-label="${msg("languages")}" tabindex="-1">
            <#list locale.supported as l>
              <a href="${l.url}" class="sp-lang__item <#if l.languageTag == locale.currentLanguageTag>is-current</#if>"
                 role="option" <#if l.languageTag == locale.currentLanguageTag>aria-selected="true"<#else>aria-selected="false"</#if>
                 hreflang="${l.languageTag}" lang="${l.languageTag}">
                <span>${l.label}</span>
                <svg class="tick" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
              </a>
            </#list>
          </div>
        </div>
      </#if>
    </div>
  </header>

  <#-- ============ Hero + card (landing `.lp-hero`'s two-column grid) ============ -->
  <main class="sp-main">
    <div class="sp-layout">

      <#-- Left column: the landing page's own hero decks, verbatim. The brand
           line is the hook the visitor just clicked under; repeating it here is
           what makes this read as the same page rather than a redirect. Hidden
           below 980px except for the two headline decks (see the CSS). -->
      <section class="sp-hero">
        <h1 class="sp-hero__title">${msg("spHeroTitle")}</h1>
        <p class="sp-hero__deck">${msg("spHeroDeck")}</p>
        <p class="sp-hero__lead">${msg("spHeroLead")}</p>
        <ul class="sp-trust">
          <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
            <span>${msg("spTrustFree")}</span>
          </li>
          <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
            <span>${msg("spTrustYears")}</span>
          </li>
          <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
            <span>${msg("spTrustFair")}</span>
          </li>
        </ul>
      </section>

      <#-- Right column: the form card. -->
      <div class="sp-card-col">
        <div class="sp-card">

          <#-- Header. KC26 pages may supply messageHeader to override the title. -->
          <div class="sp-card__head">
            <h2 class="sp-card__title"><#if messageHeader??>${kcSanitize(messageHeader)?no_esc}<#else><#nested "header"></#if></h2>
            <#if displayRequiredFields>
              <p class="sp-required-hint"><span class="req">*</span> ${msg("requiredFields")}</p>
            </#if>
          </div>

          <#-- ===== Keycloak global message / alert block ===== -->
          <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
            <div class="sp-alert sp-alert--${message.type}" role="<#if message.type = 'error'>alert<#else>status</#if>">
              <#if message.type = 'success'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg></#if>
              <#if message.type = 'warning'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.3 3.6 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg></#if>
              <#if message.type = 'error'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.01"/></svg></#if>
              <#if message.type = 'info'><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 16v-5M12 8h.01"/></svg></#if>
              <span>${kcSanitize(message.summary)?no_esc}</span>
            </div>
          </#if>

          <#-- ===== Attempted username + restart-login (KC26) ===== -->
          <#if auth?has_content && auth.showUsername() && !auth.showResetCredentials()>
            <div class="sp-attempted">
              <span class="sp-attempted__user" id="kc-attempted-username">${auth.attemptedUsername}</span>
              <a id="reset-login" href="${url.loginRestartFlowUrl}" class="sp-link"
                 aria-label="${msg("restartLoginTooltip")}" title="${msg("restartLoginTooltip")}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/></svg>
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
      </div>

    </div>
  </main>

  <#-- ===================== Footer (AppShell `.lp-shell-footer`) ===================== -->
  <footer class="sp-footer">
    <span>${msg("spFootLead")}</span>
    <span class="sp-footer__links">
      <a href="${spSite}/docs/faq">${msg("spFaq")}</a>
      <a href="${spSite}/legal/terms">${msg("spTerms")}</a>
      <a href="${spSite}/legal/privacy-notice">${msg("spPrivacy")}</a>
    </span>
  </footer>
</div>

<script>
  (function () {
    'use strict';
    var root = document.documentElement;

    // ---- Environment banner (shown on any non-production deployment) ----
    // Source of truth: theme.properties `environment=` (rendered into data-env).
    // When blank, fall back to hostname detection. Set environment=production
    // (or serve from a known prod host) to hide it.
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
      bar.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.3 3.6 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/></svg>'
        + '<span><b></b> <span></span></span>';
      // textContent, not string concatenation into innerHTML: `label` can come
      // from the hostname, which is attacker-influencable on a misconfigured
      // vhost.
      bar.querySelector('b').textContent = env.label;
      bar.querySelector('span span').textContent = 'environment';
      var stage = document.querySelector('.sp-shell');
      stage.insertBefore(bar, stage.firstChild);
    }

    // ---- Language dropdown ----
    var lang = document.getElementById('sp-lang');
    if (lang) {
      var lbtn = document.getElementById('sp-lang-btn');
      var items = function () { return Array.prototype.slice.call(lang.querySelectorAll('.sp-lang__item')); };
      var close = function (focusButton) {
        lang.classList.remove('is-open');
        lbtn.setAttribute('aria-expanded', 'false');
        if (focusButton) lbtn.focus();
      };
      var open = function () {
        lang.classList.add('is-open');
        lbtn.setAttribute('aria-expanded', 'true');
        var cur = lang.querySelector('.sp-lang__item.is-current') || items()[0];
        if (cur) { cur.focus(); cur.scrollIntoView({ block: 'nearest' }); }
      };
      lbtn.addEventListener('click', function (e) {
        e.stopPropagation();
        if (lang.classList.contains('is-open')) close(false); else open();
      });
      // Roving arrow keys over 30 locales — tabbing through the whole list to
      // reach the bottom of it is not a picker anyone finishes.
      lang.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { close(true); return; }
        if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
        var all = items();
        if (!all.length) return;
        e.preventDefault();
        if (!lang.classList.contains('is-open')) { open(); return; }
        var at = all.indexOf(document.activeElement);
        var next = e.key === 'ArrowDown' ? at + 1 : at - 1;
        if (next < 0) next = all.length - 1;
        if (next >= all.length) next = 0;
        all[next].focus();
        all[next].scrollIntoView({ block: 'nearest' });
      });
      document.addEventListener('click', function (e) { if (!lang.contains(e.target)) close(false); });
    }

    // ---- Password reveal (progressive enhancement) ----
    // Our own forms use [data-sp-eye]; inherited base pages use Keycloak's
    // [data-password-toggle] and its own passwordVisibility.js, which this must
    // not fight over.
    Array.prototype.forEach.call(document.querySelectorAll('[data-sp-eye]'), function (b) {
      b.addEventListener('click', function () {
        var inp = document.getElementById(b.getAttribute('data-sp-eye'));
        if (!inp) return;
        var show = inp.type === 'password';
        inp.type = show ? 'text' : 'password';
        b.setAttribute('aria-label', show ? b.getAttribute('data-label-hide') : b.getAttribute('data-label-show'));
        b.classList.toggle('is-revealed', show);
      });
    });
  })();
</script>
</body>
</html>
</#macro>
