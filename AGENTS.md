# AGENTS.md

Keycloak themes for SoccerProject (`login`, `account`, `email`, provider `soccerproject`), pinned to
**Keycloak 26.7.1** by the `Dockerfile`. [`README.md`](README.md) is the full reference: read the
section for the area you change before you change it. PRs target `main`; a merge that touches
`themes/**` or the `Dockerfile` builds and pushes the image to GHCR (`.github/workflows/build.yml`).

## Guardrails

- **The design is the landing page's.** Colour tokens, type and chrome mirror
  `soccerproject-frontend` (`src/pages/landing/tokens.ts`, `src/styles/landing.css`). Change them
  there first, then mirror them here; never tune by eye. No dark mode and no theme toggle on the
  auth pages; only the `email` theme carries a dark block.
- **Email layout mirrors the backend's** (`EMailMessageEventUtilities.htmlDocument` in
  `soccerproject-backend`): change one, change the other.
- **Forked templates are pinned.** Re-diff each forked `.ftl` against Keycloak's base on every
  Keycloak bump; a bump does not update them. Every other page is styled through
  `properties.kc*Class` in `login/theme.properties`.
- **`login/messages/*.properties` is generated**: edit `tools/gen_messages.py` and re-run it. Never
  an ASCII apostrophe in a value (`MessageFormat` eats it; use `’`). Dutch says "je", never "u".
- **Email bundles are hand-written** and kept key for key with `messages_en.properties`; run
  `tools/check_email_messages.py` after an edit.
- **Languages** need `locales=` here and `supportedLocales` in
  `soccerproject-keycloak-config/soccerproject-realm.json` to agree. Register fields come from that
  realm's user profile, not from this repo.
- **Touch targets** are at least 44px on a phone; check a new control at 375px wide.

## Checking a change

There is no running Keycloak and no test suite. Render every page offline with `tools/render/`
(command in [`tools/render/README.md`](tools/render/README.md)) and open `preview/index.html`;
`preview/` is build output and is not committed.

## Commits

`fix(login): theme#N — <what the user sees>` (scope `login`, `email` or `account`). Issues live in
this repo and are written `theme#N`; frontend issues as `frontend#N`.

Only report to me in ASD-STE100 Simplified Technical English.
