<#import "template.ftl" as layout>
<@layout.emailLayout>
  <@layout.spHeading text=msg("spVerifyHeading") />
  <p style="margin:0;">${msg("spVerifyLead")}</p>

  <@layout.spButton href=link label=msg("spVerifyButton") />

  <@layout.spSmallPrint expires=msg("spLinkExpires", linkExpirationFormatter(linkExpiration)) ignore=msg("spVerifyIgnore") />
</@layout.emailLayout>
