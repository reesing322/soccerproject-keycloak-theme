<#--
  SoccerProject.com — identity-provider presentation shared by login.ftl and
  register.ftl.

  The realm's IdP configuration carries `iconClasses` (zocial / PatternFly glyph
  class names). No icon font is loaded by this theme, so those class names would
  render an empty box; the brand marks are drawn inline instead, keyed off
  `providerId` — which is the social provider's own id ("google", "facebook",
  ...) rather than the realm-local alias an admin is free to rename.

  Anything we have no mark for falls back to a neutral globe, so an OIDC or
  SAML federation added later still renders a complete, aligned button.
-->

<#macro idpIcon provider>
  <#local id = (provider.providerId!'')?lower_case>
  <#switch id>
    <#case "google">
      <#-- Google's own four-colour G. Per Google's branding rules the mark is
           reproduced unmodified and never re-inked to match our palette. -->
      <svg class="sp-social__icon" viewBox="0 0 48 48" aria-hidden="true" focusable="false">
        <path fill="#4285F4" d="M45.1 24.5c0-1.6-.1-3.2-.4-4.7H24v8.9h11.8a10.1 10.1 0 0 1-4.4 6.6v5.5h7.1c4.2-3.8 6.6-9.5 6.6-16.3z"/>
        <path fill="#34A853" d="M24 46c6 0 11-2 14.6-5.2l-7.1-5.5c-2 1.3-4.5 2.1-7.5 2.1-5.8 0-10.7-3.9-12.4-9.1H4.3v5.7A22 22 0 0 0 24 46z"/>
        <path fill="#FBBC05" d="M11.6 28.3a13.2 13.2 0 0 1 0-8.5v-5.7H4.3a22 22 0 0 0 0 19.9l7.3-5.7z"/>
        <path fill="#EA4335" d="M24 10.7c3.3 0 6.2 1.1 8.5 3.3l6.3-6.3C35 4.1 30 2 24 2A22 22 0 0 0 4.3 14.1l7.3 5.7c1.7-5.2 6.6-9.1 12.4-9.1z"/>
      </svg>
      <#break>
    <#case "facebook">
      <svg class="sp-social__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path fill="#1877F2" d="M24 12.07C24 5.4 18.63 0 12 0S0 5.4 0 12.07C0 18.1 4.39 23.1 10.13 24v-8.44H7.08v-3.49h3.05V9.41c0-3.02 1.79-4.69 4.53-4.69 1.31 0 2.68.24 2.68.24v2.96h-1.51c-1.49 0-1.96.93-1.96 1.89v2.26h3.33l-.53 3.49h-2.8V24C19.61 23.1 24 18.1 24 12.07z"/>
      </svg>
      <#break>
    <#case "apple">
      <svg class="sp-social__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path fill="#000000" d="M16.4 12.7c0-2.6 2.1-3.9 2.2-4-1.2-1.8-3.1-2-3.8-2-1.6-.2-3.1 1-3.9 1-.8 0-2-1-3.3-1-1.7 0-3.3 1-4.2 2.5-1.8 3.1-.5 7.7 1.3 10.2.9 1.2 1.9 2.6 3.2 2.6 1.3-.1 1.8-.8 3.4-.8 1.6 0 2 .8 3.4.8 1.4 0 2.3-1.2 3.1-2.5.6-.9 1-1.8 1.2-2.4-2.7-1-2.6-4.3-2.6-4.4zM14 4.5c.7-.9 1.2-2.1 1.1-3.3-1 0-2.3.7-3.1 1.6-.7.8-1.3 2-1.1 3.2 1.2.1 2.4-.6 3.1-1.5z"/>
      </svg>
      <#break>
    <#case "microsoft">
      <svg class="sp-social__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path fill="#F25022" d="M1 1h10.2v10.2H1z"/>
        <path fill="#7FBA00" d="M12.8 1H23v10.2H12.8z"/>
        <path fill="#00A4EF" d="M1 12.8h10.2V23H1z"/>
        <path fill="#FFB900" d="M12.8 12.8H23V23H12.8z"/>
      </svg>
      <#break>
    <#case "github">
      <svg class="sp-social__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path fill="#181717" d="M12 .5C5.4.5 0 5.9 0 12.6c0 5.3 3.4 9.8 8.2 11.4.6.1.8-.3.8-.6v-2c-3.3.7-4-1.6-4-1.6-.6-1.4-1.4-1.8-1.4-1.8-1.1-.8.1-.8.1-.8 1.2.1 1.8 1.2 1.8 1.2 1.1 1.9 2.9 1.3 3.6 1 .1-.8.4-1.3.8-1.6-2.7-.3-5.5-1.3-5.5-6 0-1.3.5-2.4 1.2-3.2-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2a11.4 11.4 0 0 1 6 0C17.3 4.9 18.3 5.2 18.3 5.2c.6 1.7.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.2 0 4.7-2.8 5.7-5.5 6 .4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6A12.1 12.1 0 0 0 24 12.6C24 5.9 18.6.5 12 .5z"/>
      </svg>
      <#break>
    <#default>
      <svg class="sp-social__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
        <circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18M12 3a15 15 0 0 0 0 18"/>
      </svg>
  </#switch>
</#macro>

<#--
  The provider buttons. `displayName` comes from the realm and is already
  localised there; the button label is built from it so a realm that renames
  "Google" keeps its own wording.
-->
<#macro idpButtons providers>
  <div id="kc-social-providers" class="kc-social-section">
    <div class="sp-or">${msg("identity-provider-login-label")}</div>
    <ul class="sp-social<#if (providers?size gt 2)> sp-social--grid</#if>">
      <#list providers as p>
        <li>
          <a id="social-${p.alias}" href="${p.loginUrl}" rel="nofollow">
            <@idpIcon provider=p/>
            <span class="sp-social__name">${msg("spContinueWith", (p.displayName!p.alias))}</span>
          </a>
        </li>
      </#list>
    </ul>
  </div>
</#macro>

<#--
  "Two ways in" — the orientation panel #725 asks for: a first-time visitor has
  to be able to see, without clicking anything, that a Google or Facebook
  account works AND that any other email address does too.

  Rendered on both auth pages, and only when the realm actually allows
  registration: promising a route that the realm has closed is worse than
  saying nothing. `hasSocial` splits the copy so the panel never advertises a
  social button that is not on the page.
-->
<#macro waysIn hasSocial>
  <div class="sp-ways">
    <p class="sp-ways__title">${msg("spWaysTitle")}</p>
    <ul class="sp-ways__list">
      <#if hasSocial>
        <li>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
          <span>${msg("spWaySocial")}</span>
        </li>
      </#if>
      <li>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
        <span><#if hasSocial>${msg("spWayEmail")}<#else>${msg("spWayEmailOnly")}</#if></span>
      </li>
    </ul>
  </div>
</#macro>
