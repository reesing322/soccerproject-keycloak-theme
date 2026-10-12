<#--
  Fork of Keycloak 26.7.1 base/login/login-page-expired.ftl (theme#24).
  Re-diff on every Keycloak bump: a bump will not update this copy.

  Reached by going back or reloading after a verify-email link was opened in a
  second browser. Stock offers only "click here" to restart or continue
  Keycloak's own login, which never leads to the app. With a client.baseUrl
  (the realm sets one on soccerproject-frontend) the way into the app is the
  primary button and the two stock links move to the card foot; without one
  the page is stock.
-->
<#import "template.ftl" as layout>
<#assign spAppUrl = (client.baseUrl)!''>
<@layout.registrationLayout displayInfo=spAppUrl?has_content; section>
    <#if section = "header">
        ${msg("pageExpiredTitle")}
    <#elseif section = "form">
        <#if spAppUrl?has_content>
            <div class="${properties.kcFormButtonsClass!}">
                <a id="sp-go-to-app" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}" href="${spAppUrl}">${msg("spGoToApp")}</a>
            </div>
        <#else>
            <p id="instruction1" class="instruction">
                ${msg("pageExpiredMsg1")} <a id="loginRestartLink" href="${url.loginRestartFlowUrl}">${msg("doClickHere")}</a> .<br/>
                ${msg("pageExpiredMsg2")} <a id="loginContinueLink" href="${url.loginAction}">${msg("doClickHere")}</a> .
            </p>
        </#if>
    <#elseif section = "info">
        <p id="instruction1">
            <a id="loginRestartLink" href="${url.loginRestartFlowUrl}">${msg("spLoginRestart")}</a>
            <span aria-hidden="true">&middot;</span>
            <a id="loginContinueLink" href="${url.loginAction}">${msg("spLoginContinue")}</a>
        </p>
    </#if>
</@layout.registrationLayout>
