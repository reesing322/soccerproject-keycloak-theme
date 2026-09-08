# SoccerProject.com — Keycloak themes

Three themes under one provider (`soccerproject`), built for **Keycloak 26.7.1**
(the version the `Dockerfile` pins):

| Theme | What it skins |
|---|---|
| `login` | sign-in, register, reset password, OTP — every auth page |
| `account` | the account console (`keycloak.v3`, CSS-only branding) |
| `email` | the transactional HTML emails |

## The design comes from the landing page

`login` was rebuilt for
[reesing322/soccerproject-frontend#725](https://github.com/reesing322/soccerproject-frontend/issues/725):
the auth pages have to read as the next click of the public landing page, not as
a redirect to a different application. So the design is not "a themed Keycloak" —
it is the landing page's own composition, palette and type:

| Here | Source of truth in `soccerproject-front` |
|---|---|
| `--sp-*` colour tokens | `src/pages/landing/tokens.ts` (pinned hexes) |
| type scale, pills, 8px cards | `src/styles/landing.css` |
| masthead and footer | `src/components/AppShell.tsx` (`LandingShell`) |
| the puppet mark | `public/puppet-white.png`, byte-identical |

When the landing page's handoff changes, change it there first and mirror it in
`themes/soccerproject/login/resources/css/sp-login.v6.css`. Do not tune those
values by eye.

**No dark mode, and no theme toggle.** The landing page pins its palette and
deliberately renders no theme control, because it is shown to people who have
never chosen one; these pages are the same pre-auth journey and follow the same
rule. A visitor who pressed a gold button on a navy gradient must not land on a
differently-coloured page.

## Only two templates are forked

`login.ftl` and `register.ftl`. Every other auth page is Keycloak's own base
template, picking up this design through the `properties.kc*Class` hooks that
`login/theme.properties` maps onto our class names. That is the supported
theming mechanism, and it means a Keycloak upgrade cannot leave a page we forgot
to fork rendering unstyled.

`idp-commons.ftl` holds what the two forked pages share: the identity-provider
buttons (with inline brand marks, since no icon font is loaded) and the "two
ways in" panel.

## Languages

30 locales, listed in `login/theme.properties`. Every one has a **complete** base
message bundle in Keycloak 26.7.1, so no page comes out half-English: our own
strings are translated in `login/messages/`, everything else is Keycloak's own
translation.

Two things have to agree for the picker to appear at all:

1. `locales=` in `themes/soccerproject/login/theme.properties`
2. `supportedLocales` on the realm — `soccerproject-keycloak-config/soccerproject-realm.json`

`login/messages/*.properties` is **generated**. Edit `tools/gen_messages.py` and
re-run it, so a new key cannot land in some locales and not others:

```bash
SP_MESSAGES_DIR=themes/soccerproject/login/messages python3 tools/gen_messages.py
```

The generator refuses an ASCII apostrophe in any value: Keycloak runs every
`msg()` through `java.text.MessageFormat`, which would eat it. Use `’`.

## Reviewing a change without a running Keycloak

`tools/render/` renders every page against a mock of Keycloak's model and writes
the HTML to `preview/`. Open `preview/index.html`. See `tools/render/README.md`
for how to run it — and run it after any Keycloak upgrade, since it is what
catches a macro contract or a `properties.kc*` hook that moved.

## Cache busting

Keycloak serves theme resources with a 30-day cache header and the URL does not
change when a file's *content* does. After editing the CSS, rename it
(`sp-login.v6.css` → `v7`) and update `styles=` in `login/theme.properties`.
