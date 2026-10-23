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
    * spTitle (ours, not KC's) — a fork overrides even messageHeader (theme#24)
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
<#-- Marketing site for THIS environment (theme#8). The one image runs on every
     environment, so a hardcoded kcLogoLink sent development testers to the
     production legal text. auth.<env>.soccerproject.com -> www.<env>.soccerproject.com,
     read from the host Keycloak put in its own absolute URLs; anything that does
     not look like auth.[<env>.]soccerproject.com (localhost, login.soccerproject.com, any
     other domain: a spoofed Host must not pick a link target) keeps kcLogoLink.
     Several of Keycloak's URLs are tried, first absolute one wins (theme#44): the
     development deployment renders loginRestartFlowUrl as a relative path, which
     left every footer and legal link on production, while its form actions
     (loginAction, registrationAction) stay absolute. -->
<#assign spSite = properties.kcLogoLink!'https://www.soccerproject.com'>
<#list [url.loginRestartFlowUrl!'', url.loginAction!'', url.registrationAction!'', url.loginUrl!''] as spUrl>
  <#assign spAuthHost = spUrl?matches('^https?://auth\\.((?:[a-z0-9-]+\\.)*soccerproject\\.com)(:[0-9]+)?/.*')>
  <#if spAuthHost>
    <#assign spSite = 'https://www.' + spAuthHost?groups[1]>
    <#break>
  </#if>
</#list>
<#-- The way into the game from a page that ends a flow (theme#24, theme#40):
     the client's baseUrl when the realm sets one, else this environment's own
     site, whose / sends a signed-in manager on into the app. The realm config
     sets no baseUrl on soccerproject-frontend, so without the fallback the
     error, email-verified and page-expired pages had nothing to click. -->
<#function spAppUrl>
  <#return (client.baseUrl)?has_content?then(client.baseUrl, spSite)>
</#function>
<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true spTitle="">
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'en'}" data-env="${properties.environment!''}"<#if realm.internationalizationEnabled> dir="${((locale.rtl)!false)?then('rtl','ltr')}"</#if>>
<head>
  <meta charset="utf-8">
  <#-- `interactive-widget=resizes-content` (frontend#737): by default a virtual
       keyboard shrinks only the VISUAL viewport, so the page keeps its full
       layout height behind the keyboard and the browser has to scroll within it
       to keep a focused field in view -- with ~400px left on a phone, the submit
       button ends up 161px below the fold. `resizes-content` shrinks the layout
       viewport instead, which `.sp-shell`'s `100dvh` already tracks, so the page
       reflows into what is actually visible.
       No `viewport-fit=cover`: that is for notched displays, and without
       matching `env(safe-area-inset-*)` padding it would slide the masthead
       under the notch. -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, interactive-widget=resizes-content">
  <meta name="robots" content="noindex, nofollow">
  <#-- Light only, on purpose: see the macro comment above. Declaring "light dark"
       here would let the browser paint form controls and scrollbars dark on a
       page whose every surface is the landing page's white. -->
  <meta name="color-scheme" content="light">
  <#-- The masthead colour, so a mobile browser's own chrome continues the page
       the same way it does on soccerproject.com. -->
  <meta name="theme-color" content="#101822">
  <#-- The register page is not a sign-in page: "Log in to SoccerProject" on its
       tab contradicted the card under it (theme#20, #10 item 5). -->
  <title><#if (pageId!'') == 'register'>${msg("registerTitle")} · ${realm.displayName!''}<#else>${msg("loginTitle",(realm.displayName!''))}</#if></title>
  <#-- The icon set is a straight copy of the front end's `public/` icons
       (soccerproject-frontend, regenerated from the original artwork in #891):
       the sign-in tab sits next to the app's own tab, so it must carry the same
       mark, not an older redraw of it. Keep the two in step -- re-copy the four
       files and bump `?v=` here whenever the front end regenerates its set.

       `?v=` is the cache buster, matching the front end's `src/root.tsx`.
       Keycloak serves theme resources with a 30-day cache header and the URL
       does not change when a file's content does, and Chrome caches a favicon
       per origin harder still, so replacing the bytes alone leaves the old icon
       on screen for a month. (The CSS cannot do this -- `styles=` in
       theme.properties owns that URL -- which is why it is versioned by
       filename instead.)

       The .ico carries 16/32/48 for the browsers that still ask for it first;
       the two PNGs are what modern browsers pick. -->
  <link rel="icon" href="${url.resourcesPath}/img/favicon.ico?v=6" sizes="any">
  <link rel="icon" type="image/png" sizes="32x32" href="${url.resourcesPath}/img/favicon-32x32.png?v=6">
  <link rel="icon" type="image/png" sizes="16x16" href="${url.resourcesPath}/img/favicon-16x16.png?v=6">
  <link rel="apple-touch-icon" href="${url.resourcesPath}/img/apple-touch-icon.png?v=6">

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

          <#-- Header. KC26 pages may supply messageHeader to override the title;
               spTitle, passed by one of our own forks, overrides both (info.ftl
               replaces Keycloak's "Email address verified", theme#24).
               Keycloak 26.7.1 fills messageHeader two ways: most callers format
               it first (getMessage), but the info page after required actions
               gets the bare key "accountUpdatedTitle" (AuthenticationManager)
               and an organisation sign-up "organization.member.register.title"
               (RegistrationPage). Stock info.ftl/register.ftl resolve it with
               msg(). A key-shaped value (no spaces) goes through msg() here too;
               formatted text is printed as is, so a second MessageFormat pass
               cannot eat an apostrophe or trip on a brace. -->
          <div class="sp-card__head">
            <h2 class="sp-card__title"><#if spTitle?has_content>${spTitle}<#elseif messageHeader?has_content && messageHeader?matches("[A-Za-z0-9_.-]+")>${kcSanitize(msg(messageHeader))?no_esc}<#elseif messageHeader??>${kcSanitize(messageHeader)?no_esc}<#else><#nested "header"></#if></h2>
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

          <#-- ===== Password rules on the inherited update-password page =====
               Keycloak's own page lists no rules; it reports the first one the
               password breaks, after a submit. register.ftl places the same
               list next to its own password field. -->
          <#if (pageId!'') == 'login-update-password'>
            <@spPasswordRules/>
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

    // ---- Password rules: live, and checked before the round trip (theme#41) ----
    // Keycloak wipes both fields on any error and checks "do they match" before
    // the policy, so a short password came back, empty, as "Passwords don't
    // match" -- after a 20-30 s request on development. Here each rule ticks as
    // it is met, and a submit that would fail stops in the browser with the
    // first failing rule's own Keycloak message, the fields kept. The checks
    // mirror Keycloak's policies (Character.isLowerCase and friends); the
    // server still decides, and history and blacklist are left to it.
    var rules = document.getElementById('sp-password-rules');
    var pass = document.getElementById('password-new') || document.getElementById('password');
    if (rules && pass && pass.form) {
      var confirm = document.getElementById('password-confirm');
      if (!pass.getAttribute('aria-describedby')) pass.setAttribute('aria-describedby', rules.id);
      var count = function (v, re) { return (v.match(re) || []).length; };
      var other = function (id) { var el = document.getElementById(id); return el ? el.value.trim() : ''; };
      var checks = {
        length: function (v, n) { return Array.from(v).length >= n; },
        maxLength: function (v, n) { return Array.from(v).length <= n; },
        lowerCase: function (v, n) { return count(v, /\p{Ll}/gu) >= n; },
        upperCase: function (v, n) { return count(v, /\p{Lu}/gu) >= n; },
        digits: function (v, n) { return count(v, /\p{Nd}/gu) >= n; },
        specialChars: function (v, n) { return count(v, /[^\p{L}\p{Nd}]/gu) >= n; },
        notUsername: function (v) {
          // The register form's own field first; update-password has only the model's.
          var u = other('username') || rules.getAttribute('data-username');
          return !v || !u || v.toLowerCase() !== u.toLowerCase();
        },
        notEmail: function (v) {
          var e = other('email');
          return !v || !e || v.toLowerCase() !== e.toLowerCase();
        }
      };
      var items = Array.prototype.slice.call(rules.querySelectorAll('li[data-rule]'));
      var failing = function () {
        var v = pass.value, first = null;
        items.forEach(function (li) {
          var check = checks[li.getAttribute('data-rule')];
          var met = !check || check(v, parseInt(li.getAttribute('data-n'), 10));
          li.classList.toggle('is-met', met && v.length > 0);
          if (!met && !first) first = li;
        });
        return first;
      };
      var showError = function (input, text) {
        var id = 'sp-client-error-' + input.id;
        var el = document.getElementById(id);
        if (!text) { if (el) el.remove(); input.removeAttribute('aria-invalid'); return; }
        if (!el) {
          el = document.createElement('span');
          el.id = id;
          el.className = 'kc-field-error';
          el.setAttribute('aria-live', 'polite');
          // Under the input's own wrapper, where Keycloak puts its error.
          var wrap = input.closest('.sp-input-wrap, .kc-input-wrap') || input;
          wrap.parentNode.insertBefore(el, wrap.nextSibling);
        }
        el.textContent = text;
        input.setAttribute('aria-invalid', 'true');
      };
      pass.addEventListener('input', function () {
        failing();
        showError(pass, '');
      });
      if (confirm) confirm.addEventListener('input', function () { showError(confirm, ''); });
      failing();
      pass.form.addEventListener('submit', function (e) {
        // The account console's Cancel posts this form too, and must go through.
        if (e.submitter && e.submitter.name === 'cancel-aia') return;
        var bad = failing();
        if (bad) {
          e.preventDefault();
          e.stopImmediatePropagation();
          showError(pass, bad.getAttribute('data-error'));
          pass.focus();
          return;
        }
        if (confirm && confirm.value !== pass.value) {
          e.preventDefault();
          e.stopImmediatePropagation();
          showError(confirm, rules.getAttribute('data-not-match'));
          confirm.focus();
        }
      }, true);
    }

    // ---- Busy state on submit (theme#41) ----
    // A slow request (20-36 s on development) left the page looking dead and
    // the button clickable. The pressed button shows a spinner and the form
    // takes no second submit. The button is not disabled: a disabled submitter
    // drops its own name/value from the post, and Keycloak reads some of them
    // (cancel-aia). Back/forward cache restores the page as it was left, busy,
    // so pageshow clears it.
    Array.prototype.forEach.call(document.querySelectorAll('.sp-card form'), function (form) {
      form.addEventListener('submit', function (e) {
        if (e.defaultPrevented) return;
        if (form.getAttribute('data-sp-busy')) { e.preventDefault(); return; }
        form.setAttribute('data-sp-busy', '1');
        var btn = e.submitter || form.querySelector('[type="submit"]');
        if (btn) {
          btn.classList.add('is-busy');
          btn.setAttribute('aria-disabled', 'true');
        }
        form.setAttribute('aria-busy', 'true');
      });
    });
    window.addEventListener('pageshow', function (e) {
      if (!e.persisted) return;
      Array.prototype.forEach.call(document.querySelectorAll('[data-sp-busy]'), function (form) {
        form.removeAttribute('data-sp-busy');
        form.removeAttribute('aria-busy');
        Array.prototype.forEach.call(form.querySelectorAll('.is-busy'), function (b) {
          b.classList.remove('is-busy');
          b.removeAttribute('aria-disabled');
        });
      });
    });

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

<#--
  Every rule the realm's password policy sets, before the visitor types
  (theme#20, #10 item 2). Read from `passwordPolicies`, the PasswordPoliciesBean
  Keycloak puts in every login page's model, so the list follows the realm's
  policy rather than a copy of it. Rules the bean does not carry (regex,
  blacklist) are left to Keycloak's error after submit. Renders nothing when
  the realm sets no rule.

  Styled as the register page's "two ways in" panel (.sp-ways, plus .sp-rules
  for spacing): a quiet surface, not an alert, because nothing has gone wrong
  yet.
-->
<#macro spPasswordRules>
  <#-- Each rule carries what the script below checks (theme#41): its kind, its
       number, and Keycloak's own message for it, so a rule the password breaks
       is named before the submit, in the words the server would use. -->
  <#assign spRules = []>
  <#if passwordPolicies??>
    <#if (passwordPolicies.length)??><#assign spRules += [{"text": msg("spPasswordRuleLength", passwordPolicies.length), "kind": "length", "n": passwordPolicies.length, "error": msg("invalidPasswordMinLengthMessage", passwordPolicies.length)}]></#if>
    <#if (passwordPolicies.maxLength)??><#assign spRules += [{"text": msg("spPasswordRuleMaxLength", passwordPolicies.maxLength), "kind": "maxLength", "n": passwordPolicies.maxLength, "error": msg("invalidPasswordMaxLengthMessage", passwordPolicies.maxLength)}]></#if>
    <#if (passwordPolicies.lowerCase)??><#assign spRules += [{"text": msg("spPasswordRuleLowerCase", passwordPolicies.lowerCase), "kind": "lowerCase", "n": passwordPolicies.lowerCase, "error": msg("invalidPasswordMinLowerCaseCharsMessage", passwordPolicies.lowerCase)}]></#if>
    <#if (passwordPolicies.upperCase)??><#assign spRules += [{"text": msg("spPasswordRuleUpperCase", passwordPolicies.upperCase), "kind": "upperCase", "n": passwordPolicies.upperCase, "error": msg("invalidPasswordMinUpperCaseCharsMessage", passwordPolicies.upperCase)}]></#if>
    <#if (passwordPolicies.digits)??><#assign spRules += [{"text": msg("spPasswordRuleDigits", passwordPolicies.digits), "kind": "digits", "n": passwordPolicies.digits, "error": msg("invalidPasswordMinDigitsMessage", passwordPolicies.digits)}]></#if>
    <#if (passwordPolicies.specialChars)??><#assign spRules += [{"text": msg("spPasswordRuleSpecialChars", passwordPolicies.specialChars), "kind": "specialChars", "n": passwordPolicies.specialChars, "error": msg("invalidPasswordMinSpecialCharsMessage", passwordPolicies.specialChars)}]></#if>
    <#if (passwordPolicies.notUsername)!false><#assign spRules += [{"text": msg("spPasswordRuleNotUsername"), "kind": "notUsername", "n": 0, "error": msg("invalidPasswordNotUsernameMessage")}]></#if>
    <#if (passwordPolicies.notEmail)!false><#assign spRules += [{"text": msg("spPasswordRuleNotEmail"), "kind": "notEmail", "n": 0, "error": msg("invalidPasswordNotEmailMessage")}]></#if>
    <#-- History cannot be checked here: listed, left to the server. -->
    <#if (passwordPolicies.passwordHistory)??><#assign spRules += [{"text": msg("spPasswordRuleHistory", passwordPolicies.passwordHistory), "kind": "", "n": 0, "error": ""}]></#if>
  </#if>
  <#if spRules?has_content>
    <div class="sp-ways sp-rules" id="sp-password-rules"
         data-not-match="${msg("notMatchPasswordMessage")}"<#if username?? && username?is_string> data-username="${username}"</#if>>
      <p class="sp-ways__title">${msg("spPasswordRulesTitle")}</p>
      <ul class="sp-ways__list">
        <#list spRules as rule>
          <li<#if rule.kind?has_content> data-rule="${rule.kind}" data-n="${rule.n?c}" data-error="${rule.error}"</#if>>
            <#-- A bullet, not the panel's tick: a tick beside a rule the
                 password does not meet yet would read as "done". The tick
                 replaces it once the password meets the rule. -->
            <svg class="sp-rule__todo" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="3.5" fill="currentColor"/></svg>
            <svg class="sp-rule__done" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
            <span>${rule.text}</span>
          </li>
        </#list>
      </ul>
    </div>
  </#if>
</#macro>
