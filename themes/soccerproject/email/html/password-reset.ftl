<#import "template.ftl" as layout>
<@layout.emailLayout>
  <p class="sp-text" style="margin:0 0 8px; font-family:'Oswald','Arial Narrow',Arial,sans-serif; font-size:24px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#021326;">
    Reset your password
  </p>
  <p class="sp-muted" style="margin:0 0 18px; color:#41607e;">
    We received a request to reset the password for your SoccerProject.com
    account. Click below to choose a new one.
  </p>

  <@layout.spButton href=link label="Reset password" />

  <p class="sp-faint" style="margin:14px 0 0; font-size:13px; color:#6c87a3;">
    This link expires in ${linkExpirationFormatter(linkExpiration)}. If the button
    doesn't work, copy and paste this URL into your browser:
  </p>
  <p style="margin:8px 0 0; font-size:13px; word-break:break-all;">
    <a href="${link}" style="color:#2670c2;">${link}</a>
  </p>
  <hr class="sp-hr" style="border:0; border-top:1px solid #e2ecf6; margin:24px 0 0;">
  <p class="sp-faint" style="margin:14px 0 0; font-size:12.5px; color:#6c87a3;">
    Didn't request this? Ignore this email and your password stays unchanged.
  </p>
</@layout.emailLayout>
