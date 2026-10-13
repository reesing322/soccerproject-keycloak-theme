"""Check the email theme's hand-written Dutch bundle (theme#34).

    python3 tools/check_email_messages.py [path/to/org.keycloak.keycloak-themes-<ver>.jar]

Always: no formal "u"/"uw" and no ASCII apostrophe in
themes/soccerproject/email/messages/messages_nl.properties, the same two rules
gen_messages.py enforces for the login bundle.

With Keycloak's themes jar (copy it out of the image, see README): every key of
Keycloak's own Dutch email bundle that says "u"/"uw" must be overridden here, and
each override may only use {n} arguments the key it replaces has (leaving one
out is fine: ours drop the realm name and say SoccerProject.com). Run it
after a Keycloak upgrade: a new or changed base mail shows up as a failure.
"""

import io
import os
import re
import sys
import zipfile

sys.dont_write_bytecode = True  # no tools/__pycache__ from the import below
from gen_messages import FORMAL_NL  # noqa: E402

BUNDLE = "themes/soccerproject/email/messages/messages_nl.properties"
BASE = "theme/base/email/messages/messages_nl.properties"
ARG = re.compile(r"\{(\d+)")

# Overridden by our own HTML templates, so their base text never reaches a player.
UNUSED = {"emailVerificationBodyHtml", "passwordResetBodyHtml"}


def parse(text):
    values = {}
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith(("#", "!")) or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value
    return values


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with io.open(os.path.join(root, BUNDLE), encoding="utf-8") as fh:
        ours = parse(fh.read())

    problems = []
    for key, value in ours.items():
        if "'" in value:
            problems.append("%s contains an ASCII apostrophe (MessageFormat eats it)" % key)
        if FORMAL_NL.search(value):
            problems.append("%s addresses the reader as “u”; the game says “je”" % key)

    if len(sys.argv) > 1:
        base = parse(zipfile.ZipFile(sys.argv[1]).read(BASE).decode("utf-8"))
        for key, value in sorted(base.items()):
            if key in UNUSED or not FORMAL_NL.search(value):
                continue
            if key not in ours:
                problems.append("%s: Keycloak’s Dutch says “u” and we do not override it" % key)
            else:
                unknown = set(ARG.findall(ours[key])) - set(ARG.findall(value))
                if unknown:
                    problems.append("%s uses {%s}, which Keycloak does not pass to this key" % (
                        key, "}, {".join(sorted(unknown))))

    if problems:
        raise SystemExit("\n".join(problems))
    print("%s: %d keys, no formal “u”%s" % (BUNDLE, len(ours), ", every formal base key overridden" if len(sys.argv) > 1 else ""))


if __name__ == "__main__":
    main()
