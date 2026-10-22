<#--
  Fork of Keycloak 26.7.1 base/login/login-page-expired.ftl (theme#24).
  Re-diff on every Keycloak bump: a bump will not update this copy.

  Reached by going back or reloading after a verify-email link was opened in a
  second browser. Stock offers only "click here" to restart or continue
  Keycloak's own login, which never leads to the app. The way into the app is
  the primary button and the two stock links move, named for what they do, to
  the card foot. The app is client.baseUrl, or this environment's site when
  the client has none (theme#40): the realm config sets no baseUrl, and the
  stock fallback was two bare "Click here" links.
-->
<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "header">
        ${msg("pageExpiredTitle")}
    <#elseif section = "form">
        <div class="${properties.kcFormButtonsClass!}">
            <a id="sp-go-to-app" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}" href="${layout.spAppUrl()}">${msg("spGoToApp")}</a>
        </div>
    <#elseif section = "info">
        <p id="instruction1">
            <a id="loginRestartLink" href="${url.loginRestartFlowUrl}">${msg("spLoginRestart")}</a>
            <span aria-hidden="true">&middot;</span>
            <a id="loginContinueLink" href="${url.loginAction}">${msg("spLoginContinue")}</a>
        </p>
    </#if>
</@layout.registrationLayout>
