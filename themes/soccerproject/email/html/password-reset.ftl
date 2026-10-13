<#import "template.ftl" as layout>
<@layout.emailLayout>
  <@layout.spHeading text=msg("spResetHeading") />
  <p style="margin:0;">${msg("spResetLead")}</p>

  <@layout.spButton href=link label=msg("spResetButton") />

  <@layout.spSmallPrint expires=msg("spLinkExpires", linkExpirationFormatter(linkExpiration)) ignore=msg("spResetIgnore") />
</@layout.emailLayout>
