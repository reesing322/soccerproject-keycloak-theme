<#--
  SoccerProject.com — create-an-account page.  TARGET: Keycloak 26.7.1

  Forked from base/login/register.ftl for composition, not for behaviour. The
  field set is still Keycloak's declarative user profile
  (<@userProfileCommons.userProfileFormFields>), the password pair is still
  the base page’s markup behind the same `passwordRequired` guard, terms
  acceptance and both reCAPTCHA modes are unchanged, and the form still posts to
  `url.registrationAction` with the same field names. What changes:

    * the social buttons are ON this page, and above the form. #725's ask is
      that a new player can see that a Google or Facebook account works — on
      the base page they are only ever shown one door, the email one.
    * a lead paragraph states both routes in words, so the choice does not
      depend on recognising two logos.
    * password fields get the theme's own reveal control, the same one login.ftl
      uses, instead of the PatternFly glyph button.
    * the password pair is rendered after the profile's fields instead of being
      spliced into the middle of them (frontend#735) — see the comment on it.
-->
<#import "template.ftl" as layout>
<#import "user-profile-commons.ftl" as userProfileCommons>
<#import "register-commons.ftl" as registerCommons>
<#import "idp-commons.ftl" as idp>
<#assign spHasSocial = social?? && social.providers?? && social.providers?has_content>
<#--
  Is this the form's first render, or a redisplay after the visitor posted it?

  Keycloak gives no flag for that, but it follows from the errors: the register
  page only comes back when something failed validation. No error on any field
  and no global message therefore means nothing has been posted yet, so every
  value in the form was put there by the server -- which is what the login_hint
  fix below relies on. Any error at all and the values are the visitor's own.
-->
<#assign spFirstRender = !(messagesPerField.exists('global')
    || messagesPerField.existsError('username','email','password','password-confirm','termsAccepted')
    || (message?? && message?has_content))>
<#-- displayInfo=true: the "back to sign in" link lives in the card footer
     here, not inside the form's options row as on the base page. -->
<#-- displayRequiredFields=false: the hint is rendered by this page, directly
     above the first field, rather than by the template under the title -- there
     it sat between the title and the lead, above the social buttons, describing
     neither of them. -->
<@layout.registrationLayout displayMessage=messagesPerField.exists('global') displayInfo=true; section>

    <#-- ===== Card heading ===== -->
    <#if section = "header">
        <#if messageHeader??>
            ${kcSanitize(msg("${messageHeader}"))?no_esc}
        <#else>
            ${msg("registerTitle")}
        </#if>

    <#-- ===== Body ===== -->
    <#elseif section = "form">

        <#-- Says in one sentence what the two blocks below are. Sits directly
             under the title, where the required-fields hint would otherwise be
             the first thing a new visitor reads. -->
        <p class="sp-card__subtitle">
            <#if spHasSocial>${msg("spRegisterLead")}<#else>${msg("spRegisterLeadEmailOnly")}</#if>
        </p>

        <#-- Fast path first: one click, no password to invent. -->
        <#if spHasSocial>
            <ul class="sp-social sp-social--lead<#if (social.providers?size gt 2)> sp-social--grid</#if>">
                    <#list social.providers as p>
                        <li>
                            <a id="social-${p.alias}" href="${p.loginUrl}" rel="nofollow">
                                <@idp.idpIcon provider=p/>
                                <span class="sp-social__name">${msg("spContinueWith", (p.displayName!p.alias))}</span>
                            </a>
                        </li>
                    </#list>
            </ul>
            <#-- Not "or" here but the full sentence: this divider is the moment
                 the visitor decides which of the two routes to take, and #725
                 asks for the email route to be stated, not implied. -->
            <div class="sp-or">${msg("spOrUseEmail")}</div>
        </#if>

        <p class="sp-required-hint"><span class="req">*</span> ${msg("requiredFields")}</p>

        <form id="kc-register-form" class="sp-form" action="${url.registrationAction}" method="post">

            <#-- The profile's own fields first, in the realm's declared order. -->
            <@userProfileCommons.userProfileFormFields/>

            <#-- Then the password pair.

                 Keycloak's base register.ftl injects these through the
                 `afterField` callback so they land directly under `username`
                 (or under `email` when the email IS the username). That
                 produced Username -> Password -> Confirm -> Email, which asks
                 someone to choose a password in the middle of saying who they
                 are (frontend#735). Rendered after the loop instead, the form
                 reads Username -> Email -> Password -> Confirm, and it stays
                 right if `registrationEmailAsUsername` is flipped: there is
                 then no username field and the order is Email -> Password ->
                 Confirm.

                 Position only. The field names, the autocomplete tokens and the
                 `messagesPerField` keys are the base page's, so
                 RegistrationPassword validates exactly as before. -->
            <#if passwordRequired??>
                    <#-- Every rule up front (theme#20), not one per failed submit. -->
                    <@layout.spPasswordRules/>
                    <div class="sp-field">
                        <div class="kc-label-wrap">
                            <label for="password" class="sp-label">${msg("password")}</label>
                            <span class="required">*</span>
                        </div>
                        <div class="sp-input-wrap" dir="ltr">
                            <input type="password" id="password" class="sp-input" name="password"
                                   autocomplete="new-password"
                                   <#if (layout.spRules![])?has_content>aria-describedby="sp-password-rules"</#if>
                                   <#if messagesPerField.existsError('password','password-confirm')>aria-invalid="true"</#if>/>
                            <button type="button" class="sp-eye" data-sp-eye="password"
                                    aria-label="${msg('showPassword')}" aria-controls="password"
                                    data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
                                <svg class="icon-show" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></svg>
                                <svg class="icon-hide" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 3l18 18"/><path d="M10.6 5.2A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7a17.6 17.6 0 0 1-3.4 4.3"/><path d="M6.2 6.6A17.6 17.6 0 0 0 2 12s3.5 7 10 7a9.7 9.7 0 0 0 4.2-.9"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/></svg>
                            </button>
                        </div>
                        <#if messagesPerField.existsError('password')>
                            <span id="input-error-password" class="sp-field-error" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <div class="sp-field">
                        <div class="kc-label-wrap">
                            <label for="password-confirm" class="sp-label">${msg("passwordConfirm")}</label>
                            <span class="required">*</span>
                        </div>
                        <div class="sp-input-wrap" dir="ltr">
                            <input type="password" id="password-confirm" class="sp-input" name="password-confirm"
                                   autocomplete="new-password"
                                   <#if messagesPerField.existsError('password-confirm')>aria-invalid="true"</#if>/>
                            <button type="button" class="sp-eye" data-sp-eye="password-confirm"
                                    aria-label="${msg('showPassword')}" aria-controls="password-confirm"
                                    data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
                                <svg class="icon-show" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></svg>
                                <svg class="icon-hide" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 3l18 18"/><path d="M10.6 5.2A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7a17.6 17.6 0 0 1-3.4 4.3"/><path d="M6.2 6.6A17.6 17.6 0 0 0 2 12s3.5 7 10 7a9.7 9.7 0 0 0 4.2-.9"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/></svg>
                            </button>
                        </div>
                        <#if messagesPerField.existsError('password-confirm')>
                            <span id="input-error-password-confirm" class="sp-field-error" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                            </span>
                        </#if>
                    </div>
            </#if>

            <@registerCommons.termsAcceptance/>

            <#if recaptchaRequired?? && (recaptchaVisible!false)>
                <div class="sp-field">
                    <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}" data-action="${recaptchaAction}"></div>
                </div>
            </#if>

            <div class="kc-form-buttons">
                <#if recaptchaRequired?? && !(recaptchaVisible!false)>
                    <script>
                        function onSubmitRecaptcha(token) {
                            document.getElementById("kc-register-form").requestSubmit();
                        }
                    </script>
                    <button class="sp-btn sp-btn--primary sp-btn--block g-recaptcha" type="submit"
                            data-sitekey="${recaptchaSiteKey}" data-callback="onSubmitRecaptcha" data-action="${recaptchaAction}">
                        ${msg("doRegister")}
                    </button>
                <#else>
                    <button class="sp-btn sp-btn--primary sp-btn--block" type="submit">${msg("doRegister")}</button>
                </#if>
            </div>
        </form>

        <#-- ===== login_hint lands in the wrong field (frontend#735) =====

             A visitor types their address on the landing page and presses
             "Start my club"; `registerWithKeycloak` sends it as `login_hint`.
             Keycloak then decides where to put it in
             FreeMarkerLoginFormsProvider.createRegistration(), and that
             decision is hardcoded:

                 if (realm.isRegistrationEmailAsUsername())  -> prefill "email"
                 else                                        -> prefill "username"

             With usernames enabled the address lands in Username and Email is
             left blank, so the visitor types it a second time and starts out
             with an email address as their handle. There is no theme hook, no
             realm setting and no authorization parameter that redirects it --
             the only server-side cure is registrationEmailAsUsername=true,
             which is a decision about account identity, not about this form.

             So it is moved here instead: cut from Username, pasted into Email,
             and the visitor is left on an empty Username to choose a handle.

             Three guards, because the one thing this must never do is eat
             something the visitor typed:
               * `spFirstRender` -- only on a form that has not been posted yet
                 (see the assign at the top). On a redisplay the values are the
                 visitor's own and are left alone.
               * Email must be empty. If it already holds anything, nothing to do.
               * Username must parse as an address. A real handle stays put, so
                 a `login_hint` that was never an email is untouched.

             Progressive enhancement: with JS off the page behaves exactly as
             Keycloak renders it -- the address sits in Username and the visitor
             corrects it, which is today's behaviour, not a regression. -->
        <#if spFirstRender>
        <script>
          (function () {
            var username = document.getElementById('username');
            var email = document.getElementById('email');
            // No username field means the realm already uses the email as the
            // username, and Keycloak has prefilled Email itself.
            if (!username || !email) return;
            var hint = (username.value || '').trim();
            if (!hint || (email.value || '').trim()) return;
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(hint)) return;
            email.value = hint;
            username.value = '';
            // The one field the move leaves empty, and the only thing still
            // being asked for above the fold.
            try { username.focus({ preventScroll: true }); } catch (e) { username.focus(); }
          })();
        </script>
        </#if>

        <#-- What happens next, and the reassurance that nothing is being asked
             for beyond an address. Kept below the button: it answers an
             objection, and objection copy above a CTA reads as friction. -->
        <p class="sp-reassure">${msg("spRegisterFoot")}</p>

    <#-- The IdP section stays empty: on this page the providers are rendered
         above the form (see "form"), because here they are the fast path
         rather than an alternative to a password the visitor already has. -->
    <#elseif section = "socialProviders">

    <#-- ===== Back to sign-in ===== -->
    <#elseif section = "info">
        <div id="kc-registration">
            ${msg("spHaveAccount")} <a class="sp-link" href="${url.loginUrl}">${msg("doLogIn")}</a>
        </div>
    </#if>

</@layout.registrationLayout>
