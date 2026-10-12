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
`themes/soccerproject/login/resources/css/sp-login.v8.css`. Do not tune those
values by eye.

**No dark mode, and no theme toggle.** The landing page pins its palette and
deliberately renders no theme control, because it is shown to people who have
never chosen one; these pages are the same pre-auth journey and follow the same
rule. A visitor who pressed a gold button on a navy gradient must not land on a
differently-coloured page.

The `email` theme is the exception: it is read inside the recipient's mail
client, not on our pages, and several clients recolour messages in dark mode on
their own. So `email/html/template.ftl` declares `color-scheme: light dark` and
ships its own `prefers-color-scheme: dark` block (Apple Mail, iOS Mail). Keep
it, and check the header, button and links in both schemes when you change that
file (theme#22).

## Only six templates are forked

`login.ftl`, `register.ftl` and `login-reset-password.ftl` — the last one only
because the base page renders its instruction *below* the submit button it is
meant to introduce (frontend#736) — `login-verify-email.ftl`, only to add one
line (theme#12), and `info.ftl` and `login-page-expired.ftl` (theme#24). Those
two are where a verify-email link opened in a second browser (iOS Mail → Safari)
ends: Keycloak cannot resume the sign-up there, and the stock pages offer only
"« Back to Application" or links that restart Keycloak's own login. The forks
put one primary button to the client's `baseUrl` on both, so they depend on the
realm giving `soccerproject-frontend` a `baseUrl`; without one the expired page
is stock and the email-verified page shows its title with no button (stock
shows no link there either). `info.ftl` recognises the email-verified case by comparing
`message.summary` with `msg("emailVerifiedMessage")` (the bean carries no key),
and its title comes through `template.ftl`'s `spTitle`, which outranks
Keycloak's `messageHeader`. `template.ftl` resolves a key-shaped
`messageHeader` through `msg()`, as the stock pages do: after required actions
Keycloak passes the bare key `accountUpdatedTitle`, not formatted text.

The forked base pages are pinned to Keycloak 26.7.1: re-diff each against
upstream on every Keycloak bump, because a bump will not update them. Every other auth page is Keycloak's own base
template, picking up this design through the `properties.kc*Class` hooks that
`login/theme.properties` maps onto our class names. That is the supported
theming mechanism, and it means a Keycloak upgrade cannot leave a page we forgot
to fork rendering unstyled.

`idp-commons.ftl` holds what the two forked sign-in pages share: the identity-provider
buttons (with inline brand marks, since no icon font is loaded) and the "two
ways in" panel.

## Languages

**Three are offered: English, Dutch and Czech**, the languages the application
ships (`src/i18n/locales.ts`). Cut back from 30 in frontend#735: the others
signed a manager in to auth pages in their own language and then dropped them
into an English app. Czech was switched back on when the app added it.

The other 27 bundles are still here and still generated; nothing was thrown away.
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

**Dutch says "je", never "u"** — the game does. Keycloak's own Dutch bundle
says "u/uw", so every base key that addresses the reader is re-worded in the
generator's `NL_JE` section, and the generator refuses a formal "u"/"uw" in any
Dutch value. The email theme's `email/messages/messages_nl.properties` (hand
written, not generated) follows the same rule and is kept key for key in step
with its `messages_en.properties`: the HTML mails read every sentence from
there, so a missing key is an English sentence in a Dutch mail.

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
(`sp-login.v8.css` → `v9`) and update `styles=` in `login/theme.properties`.

The favicons are cache-busted with a `?v=` query instead, because
`template.ftl` writes those URLs itself — bump the four `?v=` in its `<head>`.
Chrome caches a favicon per origin and will otherwise keep serving the old one
long after the bytes on disk changed. The icon set
(`login/resources/img/favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`,
`apple-touch-icon.png`) is a straight copy of `public/` in
`reesing322/soccerproject-frontend`; when the front end regenerates its icons,
re-copy all four and bump `?v=` in the same pass so the sign-in tab and the app
tab never show two different marks.

The account console carries the same mark from its own copy,
`account/resources/img/favicon.ico`, declared as `favicons.ico` in
`account/theme.properties` — Keycloak resolves theme resources per theme, so
the login theme's copy is not reachable from there. That makes it a *fifth*
file, not a reference to the login theme's four: re-copy it in the same pass
and bump its `?v=` as well. Bumping that `?v=` without re-copying the bytes is
worse than leaving both alone — it hands every cache a fresh URL for the *old*
mark, so the account tab drifts out of step on purpose.
