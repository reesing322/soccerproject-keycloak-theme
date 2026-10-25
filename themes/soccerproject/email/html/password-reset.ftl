<#import "template.ftl" as layout>
<@layout.emailLayout>
  <@layout.spHeading text=msg("spResetHeading") />
  <p style="margin:0;">${msg("spResetLead")}</p>
  <#-- theme#52: an account that never finished signing up has no password,
       and this link is its way back in. Keycloak then sends one more mail to
       confirm the address (26.8 makes that explicit), so say so here. -->
  <p style="margin:12px 0 0;">${msg("spResetNoPassword")}</p>

  <@layout.spButton href=link label=msg("spResetButton") />

  <@layout.spSmallPrint expires=msg("spLinkExpires", linkExpirationFormatter(linkExpiration)) ignore=msg("spResetIgnore") />
</@layout.emailLayout>
