# Offline render check

`Render.java` renders every page this theme serves — the two we own
(`login.ftl`, `register.ftl`) and the ones inherited from Keycloak's base theme
— against a mock of the beans Keycloak 26.7.1 puts in the model. It is a
regression check, not a test of Keycloak: what it catches is a missing message
key, a broken macro contract after a Keycloak upgrade, or a `properties.kc*`
hook this theme forgot to map.

It also writes the HTML, which is how the visual review in
reesing322/soccerproject-frontend#725 is done without a running Keycloak.

## Running it

Needs the Keycloak base `login` templates. Fetch them for the version the
`Dockerfile` pins:

```bash
KC=26.7.1
mkdir -p /tmp/kcbase
for f in $(gh api "/repos/keycloak/keycloak/contents/themes/src/main/resources/theme/base/login?ref=$KC" --jq '.[] | select(.type=="file") | .name'); do
  gh api -H "Accept: application/vnd.github.raw" \
    "/repos/keycloak/keycloak/contents/themes/src/main/resources/theme/base/login/$f?ref=$KC" > "/tmp/kcbase/$f"
done
```

Then flatten the realm and render. The realm step is not optional: the harness
takes the register form's fields, the identity providers, the locale list and
every flag the templates branch on from the realm, so that a preview cannot
disagree with the config it is previewing.

```bash
FM=~/.m2/repository/org/freemarker/freemarker/2.3.34/freemarker-2.3.34.jar
T=themes/soccerproject/login

python3 tools/render/realm_facts.py \
  ../soccerproject-keycloak-config/soccerproject-realm.json /tmp/realm.properties

javac -cp $FM -d /tmp/render tools/render/Render.java
java -cp $FM:/tmp/render \
  -Dsp.realmFacts=/tmp/realm.properties \
  -Dsp.resourcesPath=../../themes/soccerproject/login/resources \
  Render $T /tmp/kcbase $T/theme.properties preview/en \
  tools/render/keycloak-base-messages_en.properties $T/messages/messages_en.properties
```

`realm_facts.py` prints what it extracted. Two lines there are worth a glance
before trusting a preview:

- `userProfileApplied` — `false` means keycloak-config-cli will ignore the
  realm's `userProfile` block (it needs `attributes.userProfileEnabled`), so
  Keycloak keeps its built-in default profile and the register form gets
  firstName and lastName back, required. The preview shows that reality rather
  than the block you meant to apply.
- `profileAttributes` — the register form's fields, in order.

Swap the last argument for another bundle to review a different language; the
Keycloak base bundle stays English, so a non-English preview shows our strings
translated and Keycloak's in English. That is a limitation of the preview, not
of the deployed theme — there Keycloak resolves its own bundle for the locale.

## The vendored bundle

`keycloak-base-messages_en.properties` is a verbatim copy of Keycloak 26.7.1's
`themes/src/main/resources/theme/base/login/messages/messages_en.properties`,
from keycloak/keycloak, Apache License 2.0. It is vendored so a preview does not
need network access, and so the casing audit behind the `EN_ONLY` section of
`tools/gen_messages.py` can be re-run against the exact strings the pinned
Keycloak ships. Refresh it when the `Dockerfile`'s Keycloak version moves.

## Output

`preview/` is git-ignored — it is build output. Nothing reads it but a browser.
