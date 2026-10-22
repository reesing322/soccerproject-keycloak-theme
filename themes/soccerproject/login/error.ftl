<#--
  Fork of Keycloak 26.7.1 base/login/error.ftl (theme#40). Re-diff on every
  Keycloak bump: a bump will not update this copy.

  A verify link opened a second time (used already, or in another tab) ends
  here with "Action expired" and an HTTP 400. Stock offers "« Back to
  Application" only when the client has a baseUrl, and the realm config sets
  none, so the page had nothing to click. Changes against stock: the way back
  is one primary button into the app (layout.spAppUrl: client.baseUrl, else
  this environment's site), still hidden when Keycloak sets skipLink.
-->
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
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
                    <a id="backToApplication" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}" href="${layout.spAppUrl()}">${msg("spContinueToApp")}</a>
                </div>
            </#if>
        </div>
    </#if>
</@layout.registrationLayout>
