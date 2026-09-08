<#--
  SoccerProject.com — create-an-account page.  TARGET: Keycloak 26.7.1

  Forked from base/login/register.ftl for composition, not for behaviour. The
  field set is still Keycloak's declarative user profile
  (<@userProfileCommons.userProfileFormFields>), the password pair is still
  rendered by the same `afterField` callback the base page uses, terms
  acceptance and both reCAPTCHA modes are unchanged, and the form still posts to
  `url.registrationAction` with the same field names. What changes:

    * the social buttons are ON this page, and above the form. #725's ask is
      that a new player can see that a Google or Facebook account works — on
      the base page they are only ever shown one door, the email one.
    * a lead paragraph states both routes in words, so the choice does not
      depend on recognising two logos.
    * password fields get the theme's own reveal control, the same one login.ftl
      uses, instead of the PatternFly glyph button.
-->
<#import "template.ftl" as layout>
<#import "user-profile-commons.ftl" as userProfileCommons>
<#import "register-commons.ftl" as registerCommons>
<#import "idp-commons.ftl" as idp>
<#assign spHasSocial = social?? && social.providers?? && social.providers?has_content>
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

            <@userProfileCommons.userProfileFormFields; callback, attribute>
                <#if callback = "afterField">
                <#-- Password pair, rendered just under the username — or under
                     the email when the realm uses email as the username, which
                     ours does (registrationEmailAsUsername=true). -->
                    <#if passwordRequired?? && (attribute.name == 'username' || (attribute.name == 'email' && realm.registrationEmailAsUsername))>
                        <div class="sp-field">
                            <div class="kc-label-wrap">
                                <label for="password" class="sp-label">${msg("password")}</label>
                                <span class="required">*</span>
                            </div>
                            <div class="sp-input-wrap" dir="ltr">
                                <input type="password" id="password" class="sp-input" name="password"
                                       autocomplete="new-password"
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
                </#if>
            </@userProfileCommons.userProfileFormFields>

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
