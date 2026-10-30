<#--
  Fork of Keycloak 26.7.1 base/login/info.ftl (theme#24). Re-diff on every
  Keycloak bump: a bump will not update this copy.

  A verify-email link opened in a browser without the sign-up session (iOS Mail
  -> Safari) cannot resume the login there. Keycloak verifies the address and
  ends on this page with the bare "emailVerifiedMessage" and, at best, a
  "« Back to Application" text link. Changes against stock:

    * email verified (or verified already), no pageRedirectUri, no actionUri:
      our own title and ONE primary button into the app, tagged with
      verified=1 so the app's landing page can tell this visitor from a cold
      one (theme#29, frontend#3384). The already-verified page is tagged too:
      the player is verified either way.
    * otherwise the stock order -- pageRedirectUri, then actionUri, then
      client.baseUrl -- with the link drawn as a primary button. The actionUri
      step is Keycloak's "confirm validity of e-mail address" page, which
      config cannot remove (it stops mail link scanners from spending the
      token), so it gets a button that says what it does.

    * "Account updated" with no actionUri (theme#62): the end of a sign-up
      finished in another browser, where Keycloak leaves the user logged out.
      Our own title, "log in to continue" and ONE Log in button into the app
      with verified=1. This branch ignores pageRedirectUri and skipLink: the
      redirect is the app logged out with no hint, and the page must not end
      with nothing to click.

  "The app" is client.baseUrl, or this environment's site when the client has
  none or is one of Keycloak's own (theme#40, #62, layout.spAppUrl):
  reopening a used link must not end on a title with nothing to click.

  The message bean carries only the formatted text, not its key, so the
  verified case is recognised by comparing against the same keys formatted in
  the same locale through msg(). Theme and realm overrides of those keys apply
  to both sides alike. messageHeader is matched as well: Keycloak 26.7.1 puts
  the formatted "emailVerified[Already]MessageHeader" there.
-->
<#import "template.ftl" as layout>
<#assign spSummary = (message.summary)!''>
<#assign spHeader = messageHeader!''>
<#assign spEmailVerified = !(pageRedirectUri?has_content) && !(actionUri?has_content)
  && (spSummary == msg("emailVerifiedMessage") || spSummary == msg("emailVerifiedAlreadyMessage")
      || spHeader == msg("emailVerifiedMessageHeader") || spHeader == msg("emailVerifiedAlreadyMessageHeader")
      || spHeader == "emailVerifiedMessageHeader" || spHeader == "emailVerifiedAlreadyMessageHeader")>
<#-- theme#62: a sign-up finished in another browser (the verify link, then
     "Choose a password") ends on Keycloak's "Account updated", logged OUT:
     Keycloak ends the flow there on purpose (END_AFTER_REQUIRED_ACTIONS) and
     the theme cannot log anyone in. Say the account is ready and that a login
     is left, with one button to the app's "email confirmed, log in" banner
     (verified=1), also when Keycloak sets skipLink. -->
<#assign spAccountReady = !spEmailVerified && !(actionUri?has_content)
  && (spSummary == msg("accountUpdatedMessage") || spHeader == msg("accountUpdatedTitle") || spHeader == "accountUpdatedTitle")>
<#assign spConfirmEmail = actionUri?has_content
  && (spHeader == msg("confirmEmailAddressVerificationHeader") || spHeader == "confirmEmailAddressVerificationHeader")>
<#-- client.baseUrl, else this environment's site (theme#40). -->
<#assign spAppUrl = layout.spAppUrl()>
<#-- verified=1 goes into the query, before any #fragment, replacing a verified=
     the baseUrl already carries (theme#29). -->
<#if (spEmailVerified || spAccountReady) && spAppUrl?has_content>
  <#assign spHash = spAppUrl?index_of("#")>
  <#if spHash gte 0>
    <#assign spFrag = spAppUrl[spHash..]>
    <#assign spAppUrl = spAppUrl[0..<spHash]>
  <#else>
    <#assign spFrag = "">
  </#if>
  <#assign spAppUrl = spAppUrl?replace("([?&])verified=[^&]*&?", "$1", "r")?replace("[?&]$", "", "r")>
  <#assign spAppUrl = spAppUrl + spAppUrl?contains("?")?then("&", "?") + "verified=1" + spFrag>
</#if>
<#assign spBtnClass = "${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}">
<@layout.registrationLayout displayMessage=false spTitle=spEmailVerified?then(msg("spEmailConfirmedTitle"), spAccountReady?then(msg("spAccountReadyTitle"), "")); section>
    <#if section = "header">
        <#if messageHeader??>
            ${kcSanitize(msg("${messageHeader}"))?no_esc}
        <#else>
            ${message.summary}
        </#if>
    <#elseif section = "form">
    <div id="kc-info-message">
        <#if spAccountReady>
        <p class="instruction">${msg("spAccountReadyText")}</p>
        <div class="${properties.kcFormButtonsClass!}"><a id="sp-info-login" class="${spBtnClass}" href="${spAppUrl}">${msg("doLogIn")}</a></div>
        <#elseif !spEmailVerified>
        <p class="instruction">${message.summary}<#if requiredActions??><#list requiredActions>: <b><#items as reqActionItem>${kcSanitize(msg("requiredAction.${reqActionItem}"))?no_esc}<#sep>, </#items></b></#list><#else></#if></p>
        </#if>
        <#if spAccountReady || skipLink??>
        <#else>
            <#if pageRedirectUri?has_content>
                <div class="${properties.kcFormButtonsClass!}"><a id="sp-info-continue" class="${spBtnClass}" href="${pageRedirectUri}">${msg("spContinueToApp")}</a></div>
            <#elseif actionUri?has_content>
                <div class="${properties.kcFormButtonsClass!}"><a id="sp-info-action" class="${spBtnClass}" href="${actionUri}"><#if spConfirmEmail>${msg("spConfirmEmail")}<#else>${msg("doContinue")}</#if></a></div>
            <#elseif spAppUrl?has_content>
                <div class="${properties.kcFormButtonsClass!}"><a id="sp-info-continue" class="${spBtnClass}" href="${spAppUrl}">${msg("spContinueToApp")}</a></div>
            </#if>
        </#if>
    </div>
    </#if>
</@layout.registrationLayout>
