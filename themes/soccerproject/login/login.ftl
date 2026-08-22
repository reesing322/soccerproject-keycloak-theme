<#--
  SoccerProject.com — sign-in page.  TARGET: Keycloak 26.7.1
  Section contract for KC26: header | form | socialProviders | info
-->
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>

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
                            <svg class="lead" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21a8 8 0 1 0-16 0"/><circle cx="12" cy="8" r="4"/></svg>
                            <input tabindex="1" id="username" class="sp-input <#if messagesPerField.existsError('username','password')>is-error</#if>"
                                   name="username" value="${(login.username!'')}" type="text"
                                   autofocus autocomplete="username" dir="ltr"
                                   aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                        </div>
                        <#if messagesPerField.existsError('username','password')>
                            <span id="input-error" class="sp-field-error" aria-live="polite">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </#if>

                <div class="sp-field">
                    <label for="password">${msg("password")}</label>
                    <div class="sp-input-wrap">
                        <svg class="lead" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="10.5" width="16" height="10" rx="2"/><path d="M8 10.5V7a4 4 0 0 1 8 0v3.5"/></svg>
                        <input tabindex="2" id="password" class="sp-input <#if messagesPerField.existsError('username','password')>is-error</#if>"
                               name="password" type="password" autocomplete="current-password" dir="ltr"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                        <button type="button" class="sp-eye" data-sp-eye="password"
                                aria-label="${msg("spShowPassword")}" aria-controls="password">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <#if usernameHidden?? && messagesPerField.existsError('username','password')>
                        <span id="input-error" class="sp-field-error" aria-live="polite">
                            ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                        </span>
                    </#if>
                </div>

                <div class="sp-row">
                    <#if realm.rememberMe && !usernameHidden??>
                        <label class="sp-check">
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>>
                            <span>${msg("rememberMe")}</span>
                        </label>
                    <#else>
                        <span></span>
                    </#if>
                    <#if realm.resetPasswordAllowed>
                        <a tabindex="5" class="sp-link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                    </#if>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                <button tabindex="4" class="sp-btn sp-btn--primary" name="login" id="kc-login" type="submit">${msg("doLogIn")}</button>
            </form>
        </#if>
      </div>
    </div>

    <#-- ===== Identity providers (own section since KC25) ===== -->
    <#elseif section = "socialProviders">
        <#if realm.password && social?? && social.providers?? && social.providers?has_content>
            <div id="kc-social-providers">
                <div class="sp-or">${msg("identity-provider-login-label")}</div>
                <div class="sp-social">
                    <#list social.providers as p>
                        <a id="social-${p.alias}" href="${p.loginUrl}" type="button">
                            <#if p.iconClasses?has_content><i class="${p.iconClasses}" aria-hidden="true"></i></#if>
                            <span>${p.displayName!}</span>
                        </a>
                    </#list>
                </div>
            </div>
        </#if>

    <#-- ===== Registration link (footer) ===== -->
    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration">
                ${msg("noAccount")} <a tabindex="6" class="sp-link" href="${url.registrationUrl}">${msg("doRegister")}</a>
            </div>
        </#if>
    </#if>

</@layout.registrationLayout>
