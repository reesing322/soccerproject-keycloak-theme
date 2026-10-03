<#import "template.ftl" as layout>
<@layout.emailLayout>
  <p class="sp-text" style="margin:0 0 8px; font-family:'Oswald','Arial Narrow',Arial,sans-serif; font-size:24px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#021326;">
    ${msg("spResetHeading")}
  </p>
  <p class="sp-muted" style="margin:0 0 18px; color:#41607e;">
    ${msg("spResetLead")}
  </p>

  <@layout.spButton href=link label=msg("spResetButton") />

  <p class="sp-faint" style="margin:14px 0 0; font-size:13px; color:#6c87a3;">
    ${msg("spLinkExpires", linkExpirationFormatter(linkExpiration))}
  </p>
  <p style="margin:8px 0 0; font-size:13px; word-break:break-all;">
    <a href="${link}" style="color:#2670c2;">${link}</a>
  </p>
  <hr class="sp-hr" style="border:0; border-top:1px solid #e2ecf6; margin:24px 0 0;">
  <p class="sp-faint" style="margin:14px 0 0; font-size:12.5px; color:#6c87a3;">
    ${msg("spResetIgnore")}
  </p>
</@layout.emailLayout>
