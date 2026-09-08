<#--
  SoccerProject.com — forgot-password page.  TARGET: Keycloak 26.7.1

  Forked from base/login/login-reset-password.ftl to fix its running order
  (frontend#736). The base page reads bottom-up:

      title
      [ the field, with no idea what it is for ]
      « Back to Login          [ submit ]
      "Enter your username or email address and we will send you..."

  The sentence explaining what to type sits in the `info` section, which this
  theme — like the base one — renders in the card footer, *below* the submit
  button. So the instruction arrives after the action it was meant to
  introduce, and the way out of the page is wedged in beside the way forward.

  Here the instruction is the card's lead, the field follows it, the submit
  button is last, and "back to sign in" is a quiet line in the footer, which is
  the same shape as login.ftl ("New here? Create your club") and register.ftl
  ("Already have an account? Log in").

  Unchanged: the form id, `url.loginAction`, the `username` field name, the
  `messagesPerField` key and the attempted-username prefill. Only the order,
  the button's label and the back link's wording differ.
-->
<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayMessage=!messagesPerField.existsError('username'); section>

    <#if section = "header">
        ${msg("emailForgotTitle")}

    <#elseif section = "form">
        <#-- The instruction, before the field rather than after the button. -->
        <p class="sp-card__subtitle">
            <#if realm.duplicateEmailsAllowed>${msg("emailInstructionUsername")}<#else>${msg("emailInstruction")}</#if>
        </p>

        <form id="kc-reset-password-form" class="sp-form" action="${url.loginAction}" method="post">
            <div class="sp-field">
                <label for="username">
                    <#if !realm.loginWithEmailAllowed>${msg("username")}
                    <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                    <#else>${msg("email")}</#if>
                </label>
                <div class="sp-input-wrap">
                    <input type="text" id="username" name="username"
                           class="sp-input <#if messagesPerField.existsError('username')>is-error</#if>"
                           autofocus value="${(auth.attemptedUsername!'')}" dir="ltr"
                           autocomplete="username"
                           <#if messagesPerField.existsError('username')>aria-invalid="true"</#if>/>
                </div>
                <#if messagesPerField.existsError('username')>
                    <span id="input-error-username" class="sp-field-error" aria-live="polite">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.01"/></svg>
                        <span>${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                    </span>
                </#if>
            </div>

            <#-- "Send reset email", not Keycloak's "Submit": the button should
                 say what happens next, and the next thing is an email arriving.
                 Its own key rather than an override of `doSubmit`, which eight
                 other base pages share. -->
            <button class="sp-btn sp-btn--primary sp-btn--block" type="submit">${msg("spSendResetEmail")}</button>
        </form>

    <#elseif section = "info">
        <div id="kc-reset-password-back">
            ${msg("spRememberedPassword")} <a class="sp-link" href="${url.loginUrl}">${msg("doLogIn")}</a>
        </div>
    </#if>

</@layout.registrationLayout>
