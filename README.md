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
`themes/soccerproject/login/resources/css/sp-login.v7.css`. Do not tune those
values by eye.

**No dark mode, and no theme toggle.** The landing page pins its palette and
deliberately renders no theme control, because it is shown to people who have
never chosen one; these pages are the same pre-auth journey and follow the same
rule. A visitor who pressed a gold button on a navy gradient must not land on a
differently-coloured page.

## Only three templates are forked

`login.ftl`, `register.ftl` and `login-reset-password.ftl` — the last one only
because the base page renders its instruction *below* the submit button it is
meant to introduce (frontend#736). Every other auth page is Keycloak's own base
template, picking up this design through the `properties.kc*Class` hooks that
`login/theme.properties` maps onto our class names. That is the supported
theming mechanism, and it means a Keycloak upgrade cannot leave a page we forgot
to fork rendering unstyled.

`idp-commons.ftl` holds what the two forked pages share: the identity-provider
buttons (with inline brand marks, since no icon font is loaded) and the "two
ways in" panel.

## Languages

**Two are offered: English and Dutch.** Cut back from 30 in frontend#735 —
the application ships only those two (`src/i18n/locales.ts`), so the other 28
signed a manager in to auth pages in their own language and then dropped them
into an English app.

The 28 bundles are still here and still generated; nothing was thrown away.
Turning one back on is two edits and no translation work — its code in
`login/theme.properties` and in the realm's `supportedLocales` — and every one
of them has a **complete** base bundle in Keycloak 26.7.1, so no page comes out
half-English when it is switched on: our own strings live in `login/messages/`,
everything else is Keycloak's own translation. The full set is listed in a
comment next to `locales=`.

The obvious next step is to enable them in step with the app's own switcher, one
language at a time, rather than all at once.

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

It has two sections besides the per-locale copy. `ALIASES` gives a Keycloak key
one of our values in every language — `termsTitle` takes the footer's wording so
the terms page and the link to it agree. `EN_ONLY` overrides Keycloak's own
**English** strings and nothing else: its English bundle is title case in places
("Forgot Your Password?", "Try Another Way") where our copy is sentence case,
but its other bundles are not — the Dutch is already "Bent u uw wachtwoord
vergeten?". Overriding all 30 to fix an English fault would replace correct
translations, in each language's own capitalisation conventions, with ours.

## Reviewing a change without a running Keycloak

`tools/render/` renders every page against a mock of Keycloak's model and writes
the HTML to `preview/`, which is **not** committed (see `.gitignore`) — it is
build output, and 70-odd HTML files would churn on every CSS or copy change.
Produce it with the command in `tools/render/README.md`, then open
`preview/index.html`.

Run it after any Keycloak upgrade: it is what catches a macro contract or a
`properties.kc*` hook that moved, and it renders the awkward states as well as
the happy ones — a form redisplayed after a validation error, a realm with no
identity providers, a `login_hint` that is a handle rather than an address.

The register form's fields are **not** listed anywhere in this repo. They come
from the realm's declarative user profile
(`soccerproject-keycloak-config/soccerproject-realm.json`), which `register.ftl`
renders through Keycloak's own `userProfileFormFields` macro. To change which
fields a new manager is asked for, change the realm — and note that
keycloak-config-cli only applies that block when the realm also sets
`attributes.userProfileEnabled`, silently keeping Keycloak's built-in default
profile (username, email, firstName, lastName) when it does not.

## Cache busting

Keycloak serves theme resources with a 30-day cache header and the URL does not
change when a file's *content* does. After editing the CSS, rename it
(`sp-login.v7.css` → `v8`) and update `styles=` in `login/theme.properties`.
