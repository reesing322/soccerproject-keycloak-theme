<#--
  Fork of Keycloak 26.7.1 base/login/password-commons.ftl (theme#43). Re-diff on
  every Keycloak bump: a bump will not update this copy.

  The macro the base update-password, update-email, OTP, WebAuthn and recovery
  code pages share. "Sign out from other devices" was offered on the page where
  a brand-new account chooses its first password, which has no other devices.
  Keycloak passes no flag for that page, but it does pick the warning by it
  (FreeMarkerLoginFormsProvider): "updatePasswordMessage" when UPDATE_PASSWORD
  sits on the user, as sign-up leaves it; "resetPasswordMessage" for a reset or
  a change from the account console, where the option stays. A redisplay after
  a typo carries the error instead of the warning, so the option shows again
  there: unchecked, as always.
-->
<#macro logoutOtherSessions>
    <#if ((message.summary)!'') != msg("updatePasswordMessage")>
    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
        <div class="${properties.kcFormOptionsWrapperClass!}">
            <div class="checkbox">
                <label>
                    <input type="checkbox" id="logout-sessions" name="logout-sessions" value="on">
                    ${msg("logoutOtherSessions")}
                </label>
            </div>
        </div>
    </div>
    </#if>
</#macro>
