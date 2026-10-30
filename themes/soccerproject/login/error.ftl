<#--
  Fork of Keycloak 26.7.1 base/login/error.ftl (theme#40). Re-diff on every
  Keycloak bump: a bump will not update this copy.

  A verify link opened a second time (used already, or in another tab) ends
  here with "Action expired" and an HTTP 400. Stock offers "« Back to
  Application" only when the client has a baseUrl, and the realm config sets
  none, so the page had nothing to click. Changes against stock: the way back
  is one primary button into the app (layout.spAppUrl: client.baseUrl, else
  this environment's site), still hidden when Keycloak sets skipLink.

  theme#60: the sign-up tab reloaded after the link was followed in another
  browser ends here with "cookieNotFoundMessage" (HTTP 400). Keycloak has
  dropped that tab's login, and nothing here tells why. That one error gets
  its own title, a text that names the likely cause and says to log in
  (STALE_TAB in tools/gen_messages.py), and "Go to SoccerProject", the words
  the text uses. Matched on the formatted text, as info.ftl does.

  theme#63: under the three "Action expired" errors, "Link no longer valid?
  Get a new link" to Keycloak's reset-credentials URL, for the app's client
  (spAppClientId) when the page's client is one of Keycloak's own
  (layout.spSystemClient) or missing.
-->
<#import "template.ftl" as layout>
<#assign spSummaryText = (message.summary)!"">
<#assign spStaleTab = spSummaryText == msg("cookieNotFoundMessage")>
<#-- theme#63: an expired link (reset or verify) left no way to a new one. The
     reset-credentials URL works without a session ("applications may link to
     reset credentials"). Keycloak puts the page's client_id and tab_id on it,
     but only when there is an auth session. A URL without client_id, or with
     one of Keycloak's own, would run the reset on the account client and end
     it logged in on the account console. Such a URL gets the page's client,
     or the app's (spAppClientId in theme.properties) when the page's client is
     one of Keycloak's own or missing. For the app's client and no
     redirect_uri, Keycloak ends on info.ftl's "Your account is ready"
     (theme#62). -->
<#assign spExpiredLink = spSummaryText == msg("expiredActionMessage") || spSummaryText == msg("expiredActionTokenNoSessionMessage")
  || spSummaryText == msg("expiredActionTokenSessionExistsMessage")>
<#assign spResetUrl = url.loginResetCredentialsUrl>
<#-- The client the reset runs for: the page's, unless that is one of
     Keycloak's own or missing; then the app's (spAppClientId). -->
<#assign spResetClient = (!(client.clientId)?has_content || layout.spSystemClient())?then(properties.spAppClientId!"", client.clientId)>
<#if spResetClient?has_content && (layout.spSystemClient() || !spResetUrl?contains("client_id="))>
  <#assign spResetUrl = spResetUrl?keep_before("?") + "?client_id=" + spResetClient?url("UTF-8")>
</#if>
<@layout.registrationLayout displayMessage=false spTitle=spStaleTab?then(msg("spStaleTabTitle"), ""); section>
    <#if section = "header">
        ${kcSanitize(msg("errorTitle"))?no_esc}
    <#elseif section = "form">
        <div id="kc-error-message">
            <p class="instruction">${kcSanitize(message.summary)?no_esc}</p>
            <#if traceId??>
                <p class="instruction" id="traceId">${msg("traceIdSupportMessage", traceId)}</p>
            </#if>
            <#if skipLink??>
            <#else>
                <div class="${properties.kcFormButtonsClass!}">
                    <a id="backToApplication" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}" href="${layout.spAppUrl()}"><#if spStaleTab>${msg("spGoToApp")}<#else>${msg("spContinueToApp")}</#if></a>
                </div>
            </#if>
            <#if spExpiredLink && realm.resetPasswordAllowed>
                <p id="sp-expired-new-link" class="kc-helper-after">
                    ${msg("spExpiredLinkHint")} <a class="sp-link" href="${spResetUrl}" data-sp-reset="new-link" data-sp-reset-from="">${msg("spGetNewLink")}</a>
                </p>
            </#if>
        </div>
    </#if>
</@layout.registrationLayout>
