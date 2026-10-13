<#--
  SoccerProject.com — HTML email shell.
  Bulletproof, table-based, inline-styled layout (no external CSS / web fonts —
  email clients strip them). All base HTML emails call <@layout.emailLayout>
  from here, so this single file re-skins verification, password-reset,
  execute-actions, etc.

  Same layout as the backend's own mail (theme#14): soccerproject-backend
  EMailMessageEventUtilities.htmlDocument — the "heritage" tokens below, a
  primary-blue header with the wordmark, a white card, and the footer inside
  the card (wordmark, why this mail came, legal entity · privacy link). A player
  gets both kinds of mail, so change the two together.

  One deliberate difference: the dark-mode block. Auth mail is opened on a
  phone straight after sign-up, and iOS Mail recolours it (theme#22); the
  backend's mail has no such block yet.
-->
<#-- heritage tokens, hand-copied from the backend layout (which copies them from
     soccerproject-frontend designThemeTokens.ts) -->
<#assign spPrimary = "#1d5fa8">
<#assign spPrimaryInk = "#ffffff">
<#assign spText = "#161e29">
<#assign spTextSoft = "#525c6d">
<#assign spSurface = "#ffffff">
<#assign spSurface2 = "#eaeff7">
<#assign spBorder = "#bcc8d9">
<#assign spRadius = "10px">
<#assign spFont = "'Plus Jakarta Sans', -apple-system, system-ui, 'Segoe UI', Roboto, sans-serif">

<#-- Marketing site for THIS environment, as in login/template.ftl (theme#8):
     auth.<env>.soccerproject.com in the action link -> www.<env>.soccerproject.com.
     A mail without a link, or any other host, keeps production. -->
<#assign spSite = 'https://www.soccerproject.com'>
<#assign spAuthHost = (link!'')?matches('^https?://auth\\.((?:[a-z0-9-]+\\.)*soccerproject\\.com)(:[0-9]+)?/.*')>
<#if spAuthHost>
  <#assign spSite = 'https://www.' + spAuthHost?groups[1]>
</#if>

<#macro emailLayout>
<!DOCTYPE html>
<html lang="${(locale.language)!'en'}" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <title>${msg("spEmailBrand")}</title>
  <style>
    /* progressive only — the layout itself is inlined below */
    :root { color-scheme: light dark; supported-color-schemes: light dark; }
    /* Keycloak's stock mails (execute-actions, …) render a bare <a> in the body */
    a { color: ${spPrimary}; }
    /* iOS/Apple Mail data detectors wrap bare text such as a domain name in
       <a x-apple-data-detectors> and paint it link-blue (theme#22). Keep it
       looking like the text it was. */
    a[x-apple-data-detectors] {
      color: inherit !important; text-decoration: none !important;
      font-size: inherit !important; font-family: inherit !important;
      font-weight: inherit !important; line-height: inherit !important;
    }
    @media (prefers-color-scheme: dark) {
      .sp-body  { background: #0b121c !important; }
      .sp-card  { background: #141d2a !important; border-color: #2a3646 !important; }
      .sp-text  { color: #e8eef7 !important; }
      .sp-muted { color: #a9b4c4 !important; }
      .sp-hr    { border-color: #2a3646 !important; }
      a         { color: #7fb0ea !important; }
      /* the !important above would beat the button's inline white label;
         header and button keep the primary blue and its white ink (6.6:1) */
      .sp-btn-a { color: ${spPrimaryInk} !important; }
    }
  </style>
</head>
<body class="sp-body" style="margin:0; padding:0; background:${spSurface2}; font-family:${spFont}; color:${spText}; -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="sp-body" style="background:${spSurface2};">
    <tr>
      <td align="center" style="padding:16px 8px;">
        <#-- Word-based Outlook ignores max-width: pin it to 600 there. -->
        <!--[if mso]><table role="presentation" width="600" align="center" cellpadding="0" cellspacing="0" border="0"><tr><td><![endif]-->
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="sp-card" style="width:100%; max-width:600px; background:${spSurface}; border:1px solid ${spBorder}; border-radius:${spRadius};">

          <!-- header -->
          <tr>
            <td bgcolor="${spPrimary}" style="background:${spPrimary}; padding:16px; border-radius:${spRadius} ${spRadius} 0 0;">
              <span style="font-family:${spFont}; font-size:18px; font-weight:700; color:${spPrimaryInk}; word-break:break-word;">${msg("spEmailBrand")}</span>
            </td>
          </tr>

          <!-- body -->
          <tr>
            <td class="sp-text" style="padding:20px 16px; font-family:${spFont}; color:${spText}; font-size:15px; line-height:1.5;">
              <#nested>
            </td>
          </tr>

          <!-- footer -->
          <tr>
            <td class="sp-muted" style="padding:16px; font-family:${spFont}; color:${spTextSoft}; font-size:12px;">
              ${msg("spEmailBrand")}
              <div style="margin-top:8px;">${msg("spEmailFootReason")}</div>
              <div style="margin-top:8px;">${msg("spEmailLegalEntity")} &middot; <a href="${spSite}/legal/privacy-notice" style="color:${spPrimary};">${msg("spEmailPrivacyLink")}</a></div>
            </td>
          </tr>

        </table>
        <!--[if mso]></td></tr></table><![endif]-->
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>

<#-- The page templates' building blocks, in the backend layout's styles. -->
<#macro spHeading text>
  <h2 class="sp-text" style="margin:0 0 12px; font-family:${spFont}; font-size:22px; line-height:1.3; font-weight:700; color:${spText};">${text}</h2>
</#macro>

<#-- A table-cell button: an anchor styled with CSS alone is no button in Outlook.
     Same as the backend's ctaButton. -->
<#macro spButton href label>
  <div style="margin-top:16px;">
    <table role="presentation" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td bgcolor="${spPrimary}" style="background:${spPrimary}; border-radius:${spRadius};">
          <a class="sp-btn-a" href="${href}" target="_blank" style="display:inline-block; padding:12px 24px; font-family:${spFont}; font-size:14px; font-weight:600; color:${spPrimaryInk}; text-decoration:none;">${label}</a>
        </td>
      </tr>
    </table>
  </div>
</#macro>

<#-- Expiry line and the "ignore this" line under a rule, muted. -->
<#macro spSmallPrint expires ignore>
  <p class="sp-muted" style="margin:16px 0 0; font-size:13px; color:${spTextSoft};">${expires}</p>
  <hr class="sp-hr" style="border:0; border-top:1px solid ${spBorder}; margin:20px 0 0;">
  <p class="sp-muted" style="margin:12px 0 0; font-size:13px; color:${spTextSoft};">${ignore}</p>
</#macro>
