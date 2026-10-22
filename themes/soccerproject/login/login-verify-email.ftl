<#import "template.ftl" as layout>
<#-- theme#43: the resend link answered a click inside Keycloak's cooldown with a
     red "You must wait 6 seconds". It is now disabled with a countdown instead.
     A cooldown error carries the seconds left only in its formatted text, so
     they are read back out of it against the same key formatted with a marker;
     that alert is then not shown. A fresh page (the mail was just sent) counts
     down spVerifyResendCooldown from theme.properties, which has to match the
     realm's VERIFY_EMAIL "Cooldown Between Email Resend" (Keycloak: 30). -->
<#assign spCoolText = msg("emailVerifySendCooldown", "§")>
<#assign spCoolPre = spCoolText?keep_before("§")>
<#assign spCoolPost = spCoolText?keep_after("§")>
<#assign spSummary = (message.summary)!"">
<#assign spWait = (properties.spVerifyResendCooldown!"0")?number>
<#assign spCooldownError = false>
<#if ((message.type)!"") == "error" && spSummary?starts_with(spCoolPre) && spSummary?ends_with(spCoolPost)
     && spSummary?length gt spCoolPre?length + spCoolPost?length>
  <#attempt>
    <#assign spWait = spSummary[spCoolPre?length..<(spSummary?length - spCoolPost?length)]?trim?number>
    <#assign spCooldownError = true>
  <#recover>
  </#attempt>
</#if>
<@layout.registrationLayout displayInfo=true displayMessage=!spCooldownError; section>
    <#if section = "header">
        ${msg("emailVerifyTitle")}
    <#elseif section = "form">
        <p class="instruction">
            <#if verifyEmail??>
                ${msg("emailVerifyInstruction1",verifyEmail)}
            <#else>
                ${msg("emailVerifyInstruction4",user.email)}
            </#if>
        </p>
        <#if !(isAppInitiatedAction!false)>
            <#-- theme#12: the mail link opens in a NEW tab and strands this one. -->
            <p class="instruction">${msg("spVerifyOtherTab")}</p>
        </#if>
        <#if isAppInitiatedAction!false>
            <form id="kc-verify-email-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                        <#if verifyEmail??>
                            <input class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("emailVerifyResend")}" />
                        <#else>
                            <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("emailVerifySend")}" />
                        </#if>
                        <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true" formnovalidate>${msg("doCancel")}</button>
                    </div>
                </div>
            </form>
        </#if>
    <#elseif section = "info">
        <#if !(isAppInitiatedAction!false)>
            <p class="instruction">
                ${msg("emailVerifyInstruction2")}
                <br/>
                <a id="sp-verify-resend" href="${url.loginAction}">${msg("doClickHere")}</a> ${msg("emailVerifyInstruction3")}
            </p>
            <#if spWait gt 0>
                <p id="sp-verify-resend-wait" class="instruction" role="status"
                   data-wait="${spWait?c}" data-text="${msg("spVerifyResendWait", "§")}"></p>
                <script>
                  (function () {
                    var link = document.getElementById('sp-verify-resend');
                    var note = document.getElementById('sp-verify-resend-wait');
                    if (!link || !note) return;
                    var href = link.getAttribute('href');
                    // A deadline, not a count of ticks: a background tab runs timers late.
                    var end = Date.now() + parseInt(note.getAttribute('data-wait'), 10) * 1000;
                    var text = note.getAttribute('data-text');
                    function tick() {
                      var left = Math.ceil((end - Date.now()) / 1000);
                      if (left <= 0) {
                        link.setAttribute('href', href);
                        link.removeAttribute('aria-disabled');
                        note.textContent = '';
                        return;
                      }
                      note.textContent = text.replace('§', left);
                      setTimeout(tick, 250);
                    }
                    link.removeAttribute('href');
                    link.setAttribute('aria-disabled', 'true');
                    link.setAttribute('role', 'link');
                    tick();
                  })();
                </script>
            </#if>
            <#-- theme#36: a typo in the address left no way out. Keycloak cannot change
                 it here, so restart the flow: login page, then "Create your club". -->
            <p id="sp-verify-wrong-address" class="instruction">
                ${msg("spVerifyWrongAddress")}
                <a id="sp-verify-start-again" href="${url.loginRestartFlowUrl}">${msg("spVerifyStartAgain")}</a> ${msg("spVerifyStartAgainHint")}
            </p>
        </#if>
    </#if>
</@layout.registrationLayout>
