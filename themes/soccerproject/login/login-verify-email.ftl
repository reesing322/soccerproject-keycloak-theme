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
            <#-- theme#38: the password step after the link was a surprise. -->
            <p class="instruction">${msg("spVerifyPasswordNext")}</p>
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
            <#-- theme#54: after a resend the page looked the same as before, and
                 Keycloak sets no message for it. The click leaves a marker in
                 sessionStorage (per tab), read once by the page it renders. Not
                 in the URL: Keycloak's own history script (BrowserHistoryHelper)
                 rewrites the address bar before this script runs, and a marker
                 there was gone. Shown only when no error is; a click on the link
                 while its cooldown disables it (no href) sets nothing. -->
            <script>
              (function () {
                var link = document.getElementById('sp-verify-resend');
                var resent = false;
                try {
                  resent = sessionStorage.getItem('sp-resent') === '1';
                  sessionStorage.removeItem('sp-resent');
                } catch (e) { /* storage off: no notice */ }
                if (link) link.addEventListener('click', function () {
                  if (!link.hasAttribute('href')) return;
                  try { sessionStorage.setItem('sp-resent', '1'); } catch (e) {}
                });
                <#if ((message.type)!"") == "error">resent = false; // an error is shown</#if>
                if (!resent) return;
                var form = document.querySelector('.sp-card .instruction');
                if (!form) return;
                // The markup of template.ftl's success alert. The live region
                // goes in empty and gets its text after, or a screen reader
                // may not announce it.
                var note = document.createElement('div');
                note.id = 'sp-verify-resent';
                note.className = 'sp-alert sp-alert--success';
                note.setAttribute('role', 'status');
                form.parentNode.insertBefore(note, form);
                setTimeout(function () {
                  note.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg><span></span>';
                  note.lastChild.textContent = '${msg("spVerifyResent")?js_string?no_esc}';
                }, 100);
              })();
            </script>
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
