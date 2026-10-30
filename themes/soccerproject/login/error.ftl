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
-->
<#import "template.ftl" as layout>
<#assign spStaleTab = ((message.summary)!"") == msg("cookieNotFoundMessage")>
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
        </div>
    </#if>
</@layout.registrationLayout>
