<#--
  SoccerProject.com — sign-in page.  TARGET: Keycloak 26.7.1
  Section contract for KC26: header | form | socialProviders | info

  Only the presentation differs from the base page: the same form fields, the
  same names, the same `url.loginAction`, the same `messagesPerField` checks and
  the same tab order.
-->
<#import "template.ftl" as layout>
<#import "idp-commons.ftl" as idp>
<#assign spHasSocial = realm.password && social?? && social.providers?? && social.providers?has_content>
<#assign spCanRegister = realm.password && realm.registrationAllowed && !registrationDisabled??>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=spCanRegister; section>

    <#-- ===== Card heading ===== -->
    <#if section = "header">
        ${msg("loginAccountTitle")}

    <#-- ===== Login form ===== -->
    <#elseif section = "form">
    <div id="kc-form">
      <div id="kc-form-wrapper">
        <#if realm.password>
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" novalidate="novalidate">
                <#if !usernameHidden??>
                    <div class="sp-field">
                        <label for="username">
                            <#if !realm.loginWithEmailAllowed>${msg("username")}
                            <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                            <#else>${msg("email")}</#if>
                        </label>
                        <div class="sp-input-wrap">
                            <input id="username" class="sp-input <#if messagesPerField.existsError('username','password')>is-error</#if>"
                                   name="username" value="${(login.username!'')}"
                                   type="<#if realm.loginWithEmailAllowed && realm.registrationEmailAsUsername>email<#else>text</#if>"
                                   autofocus autocomplete="username" dir="ltr"
                                   <#if messagesPerField.existsError('username','password')>aria-invalid="true"</#if>/>
                        </div>
                        <#if messagesPerField.existsError('username','password')>
                            <span id="input-error" class="sp-field-error" aria-live="polite">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.01"/></svg>
                                <span>${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                            </span>
                        </#if>
                    </div>
                </#if>

                <div class="sp-field">
                    <label for="password">${msg("password")}</label>
                    <div class="sp-input-wrap">
                        <input id="password" class="sp-input <#if messagesPerField.existsError('username','password')>is-error</#if>"
                               name="password" type="password" autocomplete="current-password" dir="ltr"
                               <#if messagesPerField.existsError('username','password')>aria-invalid="true"</#if>/>
                        <button type="button" class="sp-eye" data-sp-eye="password"
                                aria-label="${msg("showPassword")}" aria-controls="password"
                                data-label-show="${msg("showPassword")}" data-label-hide="${msg("hidePassword")}">
                            <svg class="icon-show" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></svg>
                            <svg class="icon-hide" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 3l18 18"/><path d="M10.6 5.2A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7a17.6 17.6 0 0 1-3.4 4.3"/><path d="M6.2 6.6A17.6 17.6 0 0 0 2 12s3.5 7 10 7a9.7 9.7 0 0 0 4.2-.9"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/></svg>
                        </button>
                    </div>
                    <#if usernameHidden?? && messagesPerField.existsError('username','password')>
                        <span id="input-error" class="sp-field-error" aria-live="polite">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.01"/></svg>
                            <span>${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                        </span>
                    </#if>
                </div>

                <div class="sp-row">
                    <#if realm.rememberMe && !usernameHidden??>
                        <label class="sp-check">
                            <input id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>>
                            <span>${msg("rememberMe")}</span>
                        </label>
                    <#else>
                        <span></span>
                    </#if>
                    <#if realm.resetPasswordAllowed>
                        <a class="sp-link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                    </#if>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                <button class="sp-btn sp-btn--primary sp-btn--block" name="login" id="kc-login" type="submit">${msg("doLogIn")}</button>
            </form>
        </#if>
      </div>
    </div>

    <#-- ===== Identity providers (own section since KC25) ===== -->
    <#elseif section = "socialProviders">
        <#if spHasSocial>
            <@idp.idpButtons providers=social.providers/>
        </#if>

        <#-- The "two ways in" panel sits with the buttons rather than in the
             card footer: it is the sentence that explains what the buttons
             above it mean, and a first-time visitor reads it before deciding
             whether to look for a "create account" link at all. Only shown
             when the realm can actually take a registration. -->
        <#if spCanRegister>
            <@idp.waysIn hasSocial=spHasSocial/>
        </#if>

    <#-- ===== Registration link (footer) ===== -->
    <#elseif section = "info">
        <#if spCanRegister>
            <div id="kc-registration">
                ${msg("noAccount")} <a class="sp-link" href="${url.registrationUrl}">${msg("doRegister")}</a>
            </div>
        </#if>
    </#if>

</@layout.registrationLayout>
