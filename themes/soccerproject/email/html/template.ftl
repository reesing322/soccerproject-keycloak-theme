<#--
  SoccerProject.com — HTML email shell.
  Bulletproof, table-based, inline-styled layout (no external CSS / web fonts —
  email clients strip them). Light base with a best-effort dark-mode block for
  clients that honour prefers-color-scheme (Apple Mail, iOS Mail, some others).
  All base HTML emails call <@layout.emailLayout> from here, so this single
  file re-skins verification, password-reset, execute-actions, etc.
-->
<#macro emailLayout>
<!DOCTYPE html>
<html lang="${(locale.language)!'en'}" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <title>SoccerProject.com</title>
  <!--[if mso]><style>* { font-family: 'Arial Narrow', Arial, sans-serif !important; }</style><![endif]-->
  <style>
    /* progressive only — most of the styling is inlined below */
    a { color: #2670c2; }
    .sp-btn-a:hover { background: #2670c2 !important; }
    @media (prefers-color-scheme: dark) {
      .sp-body   { background: #060f1d !important; }
      .sp-card   { background: #0e1c33 !important; border-color: rgba(255,255,255,.10) !important; }
      .sp-text   { color: #e8eef7 !important; }
      .sp-muted  { color: #a4bad4 !important; }
      .sp-faint  { color: #728cab !important; }
      .sp-hr     { border-color: rgba(255,255,255,.12) !important; }
      .sp-codebox{ background: #0b1830 !important; border-color: rgba(255,255,255,.16) !important; color: #e8eef7 !important; }
      .sp-foot   { color: #728cab !important; }
      a { color: #6fa8ec !important; }
    }
    @media only screen and (max-width: 600px) {
      .sp-w { width: 100% !important; }
      .sp-pad { padding-left: 22px !important; padding-right: 22px !important; }
    }
  </style>
</head>
<body class="sp-body" style="margin:0; padding:0; width:100%; background:#d6e3ed; -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%;">

  <!-- preheader (hidden) -->
  <div style="display:none; max-height:0; overflow:hidden; mso-hide:all; font-size:1px; line-height:1px; color:#d6e3ed;">
    SoccerProject.com &mdash; Can You Manage It?
  </div>

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#d6e3ed;" class="sp-body">
    <tr>
      <td align="center" style="padding:32px 16px;">

        <!-- container -->
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" class="sp-w" style="width:600px; max-width:600px;">

          <!-- brand banner -->
          <tr>
            <td style="border-radius:16px 16px 0 0; background:#06182f; background-image:linear-gradient(115deg,#020a14,#06182f 46%,#1d4d7e); padding:26px 36px;" class="sp-pad">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="left" style="font-family:'Oswald','Arial Narrow',Arial,sans-serif; font-size:21px; font-weight:700; color:#ffffff; letter-spacing:.4px;">
                    SoccerProject<span style="color:#9fc4ec;">.com</span>
                  </td>
                  <td align="right" style="font-family:'Oswald','Arial Narrow',Arial,sans-serif; font-size:11px; font-weight:600; letter-spacing:2px; text-transform:uppercase; color:#9fc4ec;">
                    Can You Manage It?
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- card body -->
          <tr>
            <td class="sp-card sp-pad" style="background:#ffffff; border:1px solid #c8d7e5; border-top:0; border-radius:0 0 16px 16px; padding:38px 36px 32px;">
              <div class="sp-text" style="font-family:'Barlow Semi Condensed',Arial,sans-serif; font-size:16px; line-height:1.6; color:#021326;">
                <#nested>
              </div>
            </td>
          </tr>

          <!-- footer -->
          <tr>
            <td align="center" style="padding:22px 24px 8px;">
              <div class="sp-foot" style="font-family:'Barlow Semi Condensed',Arial,sans-serif; font-size:12.5px; line-height:1.6; color:#6c87a3;">
                ${msg("spEmailFootReason")}<br>
                &copy; ${.now?string('yyyy')} SoccerProject.com &middot; ${msg("spEmailFootLead")}
              </div>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>

<#--
  Helper macros the page templates can use for a consistent look.
  Usage in a page (e.g. password-reset.ftl) — you can either rely on the
  inherited base text or wrap content in these. They degrade gracefully.
-->
<#macro spButton href label>
  <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:26px 0;">
    <tr>
      <td align="center" bgcolor="#2e7fd6" style="border-radius:11px;">
        <a class="sp-btn-a" href="${href}" target="_blank"
           style="display:inline-block; padding:14px 30px; font-family:'Oswald','Arial Narrow',Arial,sans-serif; font-size:15px; font-weight:700; letter-spacing:1px; text-transform:uppercase; color:#ffffff; text-decoration:none; background:#2e7fd6; border-radius:11px;">
          ${label}
        </a>
      </td>
    </tr>
  </table>
</#macro>
