# -*- coding: utf-8 -*-
"""
Generates themes/soccerproject/login/messages/messages_<locale>.properties.

Kept as a script rather than 30 hand-edited files so that adding a KEY is one
edit in one place: forgetting a key in one locale silently falls back to
English, which is exactly the half-translated page the theme is meant to avoid.
Adding a LOCALE is a new entry here plus the code in theme.properties' locales=.

Only two families of keys are written:

  * a handful of BASE keys re-worded in the product's own voice (a Keycloak
    realm says "Sign in to your account"; this one says "Log in" and calls the
    account a club). Everything else Keycloak already translates — every locale
    below has a complete bundle in KC 26.7.1, so those strings are left alone
    rather than re-translated worse.
  * the sp* keys, which only exist here.

MessageFormat: Keycloak runs EVERY msg() value through java.text.MessageFormat
(MessageFormatterMethod), which eats single quotes. So no value may contain an
ASCII apostrophe -- the typographic one (U+2019) is used throughout and is
asserted at the bottom of this file.
"""

import io
import os

ORDER = [
    ("languages",
     "aria-label on the language picker. Keycloak calls msg(\"languages\") in its\n#   own base template.ftl but base/login ships no such key, so without this the\n#   picker announces itself to a screen reader as the literal word \"languages\""),
    ("loginAccountTitle", "the login card title"),
    ("registerTitle", "the register card title"),
    ("doLogIn", "sign-in button + \"already have an account\" link"),
    ("doRegister", "register button + \"new here\" link"),
    ("noAccount", None),
    ("spHaveAccount", None),
    ("spHeroTitle", "hero: the brand line, untranslated on purpose (see below)"),
    ("spHeroDeck", None),
    ("spHeroLead", None),
    ("spTrustFree", None),
    ("spTrustYears", None),
    ("spTrustFair", None),
    ("spContinueWith", "{0} is the identity provider's display name"),
    ("spOrUseEmail", None),
    ("spWaysTitle", "the \"two ways in\" panel"),
    ("spWaySocial", None),
    ("spWayEmail", None),
    ("spWayEmailOnly", "used when the realm has no identity providers"),
    ("spRegisterLead", "register page: the lead under the title"),
    ("spRegisterLeadEmailOnly", None),
    ("spRegisterFoot", None),
    ("spSendResetEmail",
     "forgot-password submit. Keycloak has doSubmit (\"Submit\"), but eight other\n"
     "#   base pages share it, so it is not overridden"),
    ("spRememberedPassword",
     "forgot-password footer, in place of the base theme\u2019s \"\u00ab Back to Login\""),
    ("spFootLead", "page footer"),
    ("spFaq", None),
    ("spTerms", None),
    ("spPrivacy", None),
]

# The brand line is the landing page's <h1>. `src/i18n/resources.ts` keeps it in
# English in the Dutch bundle too, with the note: "de woordspeling op 'manage'
# overleeft geen vertaling" -- the pun does not survive translation, and the
# sign-in screen carries the same English line. Same call here, in all 30.
HERO_TITLE = "Can you manage it?"

# Keycloak's ENGLISH bundle is title case for these ("Forgot Your Password?"),
# while our own card titles are sentence case (frontend#736). Its other bundles
# are not: the Dutch is already "Bent u uw wachtwoord vergeten?" and
# "Accountinformatie bijwerken". So this is an English-only defect, and
# overriding all 30 would replace correct translations, in each language's own
# capitalisation conventions, to fix a fault none of them have.
EN_ONLY = {
    "emailForgotTitle": "Forgot your password?",
    "loginProfileTitle": "Update account information",
    "loginTotpTitle": "Mobile authenticator setup",
    # Not titles, but the same fault in the same bundle, and both sit on the
    # sign-in card next to our own sentence-case copy.
    "doForgotPassword": "Forgot password?",
    "doTryAnotherWay": "Try another way",
}

# Keys whose value is another key's, in every locale. `termsTitle` is the terms
# page's card title; ours is the same document the footer links to, so it takes
# the footer's wording rather than Keycloak's ("Terms and Conditions", and in
# Dutch "Algemene Voorwaarden" where our footer says "Gebruiksvoorwaarden").
ALIASES = {
    "termsTitle": "spTerms",
}

M = {}

M["en"] = dict(
    spSendResetEmail="Send reset email",
    spRememberedPassword="Remembered your password?",
    languages="Language",
    loginAccountTitle="Log in",
    registerTitle="Create your club",
    doLogIn="Log in",
    doRegister="Create your club",
    noAccount="New here?",
    spHaveAccount="Already have an account?",
    spHeroDeck="Run your own football club. A few minutes a day.",
    spHeroLead="Your club plays a league match every weekday. Free in your browser since 2004, now also on mobile.",
    spTrustFree="Free to play",
    spTrustYears="Online since 2004",
    spTrustFair="Never pay-to-win",
    spContinueWith="Continue with {0}",
    spOrUseEmail="or use an email address",
    spWaysTitle="Two ways in",
    spWaySocial="Continue with your Google or Facebook account — no new password to remember.",
    spWayEmail="Or create a new account with any other email address.",
    spWayEmailOnly="Create a new account with any email address.",
    spRegisterLead="Continue with your Google or Facebook account, or create a new account with any other email address.",
    spRegisterLeadEmailOnly="Create your account with any email address.",
    spRegisterFoot="Free to play. Nothing to download and nothing to pay.",
    spFootLead="Since 2004, your favourite football manager.",
    spFaq="FAQ",
    spTerms="Terms of service",
    spPrivacy="Privacy notice",
)

M["nl"] = dict(
    spSendResetEmail="Stuur herstelmail",
    spRememberedPassword="Weet je je wachtwoord weer?",
    languages="Taal",
    loginAccountTitle="Inloggen",
    registerTitle="Maak je club aan",
    doLogIn="Inloggen",
    doRegister="Maak je club aan",
    noAccount="Nieuw hier?",
    spHaveAccount="Heb je al een account?",
    spHeroDeck="Leid je eigen voetbalclub. Een paar minuten per dag.",
    spHeroLead="Elke weekdag speelt jouw club een competitiewedstrijd. Gratis in je browser sinds 2004, nu ook op mobiel.",
    spTrustFree="Gratis te spelen",
    spTrustYears="Online sinds 2004",
    spTrustFair="Nooit pay-to-win",
    spContinueWith="Doorgaan met {0}",
    spOrUseEmail="of gebruik een e-mailadres",
    spWaysTitle="Twee manieren om te starten",
    spWaySocial="Ga verder met je Google- of Facebook-account — geen nieuw wachtwoord om te onthouden.",
    spWayEmail="Of maak een nieuw account aan met een ander e-mailadres.",
    spWayEmailOnly="Maak een nieuw account aan met eender welk e-mailadres.",
    spRegisterLead="Ga verder met je Google- of Facebook-account, of maak een nieuw account aan met een ander e-mailadres.",
    spRegisterLeadEmailOnly="Maak je account aan met eender welk e-mailadres.",
    spRegisterFoot="Gratis te spelen. Niets te downloaden en niets te betalen.",
    spFootLead="Sinds 2004 jouw favoriete voetbalmanager.",
    spFaq="FAQ",
    spTerms="Gebruiksvoorwaarden",
    spPrivacy="Privacyverklaring",
)

M["fr"] = dict(
    spSendResetEmail="Envoyer le lien de réinitialisation",
    spRememberedPassword="Vous vous souvenez de votre mot de passe ?",
    languages="Langue",
    loginAccountTitle="Se connecter",
    registerTitle="Créez votre club",
    doLogIn="Se connecter",
    doRegister="Créez votre club",
    noAccount="Nouveau ici ?",
    spHaveAccount="Vous avez déjà un compte ?",
    spHeroDeck="Dirigez votre propre club de football. Quelques minutes par jour.",
    spHeroLead="Votre club dispute un match de championnat chaque jour de semaine. Gratuit dans votre navigateur depuis 2004, désormais aussi sur mobile.",
    spTrustFree="Gratuit",
    spTrustYears="En ligne depuis 2004",
    spTrustFair="Jamais de pay-to-win",
    spContinueWith="Continuer avec {0}",
    spOrUseEmail="ou utilisez une adresse e-mail",
    spWaysTitle="Deux façons de commencer",
    spWaySocial="Continuez avec votre compte Google ou Facebook — aucun nouveau mot de passe à retenir.",
    spWayEmail="Ou créez un nouveau compte avec n’importe quelle autre adresse e-mail.",
    spWayEmailOnly="Créez un nouveau compte avec n’importe quelle adresse e-mail.",
    spRegisterLead="Continuez avec votre compte Google ou Facebook, ou créez un nouveau compte avec n’importe quelle autre adresse e-mail.",
    spRegisterLeadEmailOnly="Créez votre compte avec n’importe quelle adresse e-mail.",
    spRegisterFoot="Gratuit. Rien à télécharger et rien à payer.",
    spFootLead="Depuis 2004, votre manager de football préféré.",
    spFaq="FAQ",
    spTerms="Conditions d’utilisation",
    spPrivacy="Politique de confidentialité",
)

M["de"] = dict(
    spSendResetEmail="Zurücksetz-E-Mail senden",
    spRememberedPassword="Passwort wieder eingefallen?",
    languages="Sprache",
    loginAccountTitle="Anmelden",
    registerTitle="Erstelle deinen Verein",
    doLogIn="Anmelden",
    doRegister="Verein erstellen",
    noAccount="Neu hier?",
    spHaveAccount="Hast du schon ein Konto?",
    spHeroDeck="Führe deinen eigenen Fußballverein. Ein paar Minuten am Tag.",
    spHeroLead="Dein Verein spielt an jedem Werktag ein Ligaspiel. Kostenlos im Browser seit 2004, jetzt auch mobil.",
    spTrustFree="Kostenlos spielbar",
    spTrustYears="Online seit 2004",
    spTrustFair="Niemals Pay-to-win",
    spContinueWith="Weiter mit {0}",
    spOrUseEmail="oder eine E-Mail-Adresse verwenden",
    spWaysTitle="Zwei Wege hinein",
    spWaySocial="Mach mit deinem Google- oder Facebook-Konto weiter — kein neues Passwort zu merken.",
    spWayEmail="Oder erstelle ein neues Konto mit einer beliebigen anderen E-Mail-Adresse.",
    spWayEmailOnly="Erstelle ein neues Konto mit einer beliebigen E-Mail-Adresse.",
    spRegisterLead="Mach mit deinem Google- oder Facebook-Konto weiter oder erstelle ein neues Konto mit einer beliebigen anderen E-Mail-Adresse.",
    spRegisterLeadEmailOnly="Erstelle dein Konto mit einer beliebigen E-Mail-Adresse.",
    spRegisterFoot="Kostenlos spielbar. Nichts herunterzuladen und nichts zu bezahlen.",
    spFootLead="Seit 2004 dein Lieblings-Fußballmanager.",
    spFaq="Häufige Fragen",
    spTerms="Nutzungsbedingungen",
    spPrivacy="Datenschutzerklärung",
)

M["es"] = dict(
    spSendResetEmail="Enviar correo de restablecimiento",
    spRememberedPassword="¿Ya recuerdas tu contraseña?",
    languages="Idioma",
    loginAccountTitle="Iniciar sesión",
    registerTitle="Crea tu club",
    doLogIn="Iniciar sesión",
    doRegister="Crea tu club",
    noAccount="¿Nuevo por aquí?",
    spHaveAccount="¿Ya tienes una cuenta?",
    spHeroDeck="Dirige tu propio club de fútbol. Unos minutos al día.",
    spHeroLead="Tu club juega un partido de liga cada día laborable. Gratis en tu navegador desde 2004, ahora también en el móvil.",
    spTrustFree="Gratis para jugar",
    spTrustYears="En línea desde 2004",
    spTrustFair="Nunca pay-to-win",
    spContinueWith="Continuar con {0}",
    spOrUseEmail="o usa una dirección de correo",
    spWaysTitle="Dos formas de entrar",
    spWaySocial="Continúa con tu cuenta de Google o Facebook: ninguna contraseña nueva que recordar.",
    spWayEmail="O crea una cuenta nueva con cualquier otra dirección de correo electrónico.",
    spWayEmailOnly="Crea una cuenta nueva con cualquier dirección de correo electrónico.",
    spRegisterLead="Continúa con tu cuenta de Google o Facebook, o crea una cuenta nueva con cualquier otra dirección de correo electrónico.",
    spRegisterLeadEmailOnly="Crea tu cuenta con cualquier dirección de correo electrónico.",
    spRegisterFoot="Gratis para jugar. Nada que descargar y nada que pagar.",
    spFootLead="Desde 2004, tu mánager de fútbol favorito.",
    spFaq="Preguntas frecuentes",
    spTerms="Términos del servicio",
    spPrivacy="Aviso de privacidad",
)

M["it"] = dict(
    spSendResetEmail="Invia e-mail di reimpostazione",
    spRememberedPassword="Ti sei ricordato la password?",
    languages="Lingua",
    loginAccountTitle="Accedi",
    registerTitle="Crea il tuo club",
    doLogIn="Accedi",
    doRegister="Crea il tuo club",
    noAccount="Nuovo qui?",
    spHaveAccount="Hai già un account?",
    spHeroDeck="Guida il tuo club di calcio. Pochi minuti al giorno.",
    spHeroLead="Il tuo club gioca una partita di campionato ogni giorno feriale. Gratis nel browser dal 2004, ora anche su mobile.",
    spTrustFree="Gratis",
    spTrustYears="Online dal 2004",
    spTrustFair="Mai pay-to-win",
    spContinueWith="Continua con {0}",
    spOrUseEmail="oppure usa un indirizzo e-mail",
    spWaysTitle="Due modi per iniziare",
    spWaySocial="Continua con il tuo account Google o Facebook: nessuna nuova password da ricordare.",
    spWayEmail="Oppure crea un nuovo account con qualsiasi altro indirizzo e-mail.",
    spWayEmailOnly="Crea un nuovo account con qualsiasi indirizzo e-mail.",
    spRegisterLead="Continua con il tuo account Google o Facebook, oppure crea un nuovo account con qualsiasi altro indirizzo e-mail.",
    spRegisterLeadEmailOnly="Crea il tuo account con qualsiasi indirizzo e-mail.",
    spRegisterFoot="Gratis. Niente da scaricare e niente da pagare.",
    spFootLead="Dal 2004, il tuo manager di calcio preferito.",
    spFaq="Domande frequenti",
    spTerms="Termini di servizio",
    spPrivacy="Informativa sulla privacy",
)

M["pt"] = dict(
    spSendResetEmail="Enviar e-mail de recuperação",
    spRememberedPassword="Já te lembras da palavra-passe?",
    languages="Idioma",
    loginAccountTitle="Iniciar sessão",
    registerTitle="Cria o teu clube",
    doLogIn="Iniciar sessão",
    doRegister="Cria o teu clube",
    noAccount="Novo por aqui?",
    spHaveAccount="Já tens uma conta?",
    spHeroDeck="Gere o teu próprio clube de futebol. Alguns minutos por dia.",
    spHeroLead="O teu clube joga um jogo do campeonato todos os dias úteis. Grátis no teu browser desde 2004, agora também no telemóvel.",
    spTrustFree="Grátis para jogar",
    spTrustYears="Online desde 2004",
    spTrustFair="Nunca pay-to-win",
    spContinueWith="Continuar com {0}",
    spOrUseEmail="ou usa um endereço de e-mail",
    spWaysTitle="Duas formas de entrar",
    spWaySocial="Continua com a tua conta Google ou Facebook — sem nova palavra-passe para memorizar.",
    spWayEmail="Ou cria uma nova conta com qualquer outro endereço de e-mail.",
    spWayEmailOnly="Cria uma nova conta com qualquer endereço de e-mail.",
    spRegisterLead="Continua com a tua conta Google ou Facebook, ou cria uma nova conta com qualquer outro endereço de e-mail.",
    spRegisterLeadEmailOnly="Cria a tua conta com qualquer endereço de e-mail.",
    spRegisterFoot="Grátis para jogar. Nada para descarregar e nada para pagar.",
    spFootLead="Desde 2004, o teu manager de futebol preferido.",
    spFaq="Perguntas frequentes",
    spTerms="Termos de serviço",
    spPrivacy="Aviso de privacidade",
)

M["pt-BR"] = dict(
    spSendResetEmail="Enviar e-mail de redefinição",
    spRememberedPassword="Lembrou sua senha?",
    languages="Idioma",
    loginAccountTitle="Entrar",
    registerTitle="Crie seu clube",
    doLogIn="Entrar",
    doRegister="Crie seu clube",
    noAccount="Novo por aqui?",
    spHaveAccount="Já tem uma conta?",
    spHeroDeck="Comande seu próprio clube de futebol. Alguns minutos por dia.",
    spHeroLead="Seu clube joga uma partida do campeonato todo dia útil. Grátis no navegador desde 2004, agora também no celular.",
    spTrustFree="Grátis para jogar",
    spTrustYears="Online desde 2004",
    spTrustFair="Nunca pay-to-win",
    spContinueWith="Continuar com {0}",
    spOrUseEmail="ou use um endereço de e-mail",
    spWaysTitle="Duas formas de entrar",
    spWaySocial="Continue com sua conta do Google ou do Facebook — nenhuma senha nova para lembrar.",
    spWayEmail="Ou crie uma nova conta com qualquer outro endereço de e-mail.",
    spWayEmailOnly="Crie uma nova conta com qualquer endereço de e-mail.",
    spRegisterLead="Continue com sua conta do Google ou do Facebook, ou crie uma nova conta com qualquer outro endereço de e-mail.",
    spRegisterLeadEmailOnly="Crie sua conta com qualquer endereço de e-mail.",
    spRegisterFoot="Grátis para jogar. Nada para baixar e nada para pagar.",
    spFootLead="Desde 2004, seu técnico de futebol favorito.",
    spFaq="Perguntas frequentes",
    spTerms="Termos de serviço",
    spPrivacy="Aviso de privacidade",
)

M["ro"] = dict(
    spSendResetEmail="Trimite e-mailul de resetare",
    spRememberedPassword="Ți-ai amintit parola?",
    languages="Limbă",
    loginAccountTitle="Autentificare",
    registerTitle="Creează-ți clubul",
    doLogIn="Autentificare",
    doRegister="Creează-ți clubul",
    noAccount="Ești nou aici?",
    spHaveAccount="Ai deja un cont?",
    spHeroDeck="Condu-ți propriul club de fotbal. Câteva minute pe zi.",
    spHeroLead="Clubul tău joacă un meci de campionat în fiecare zi lucrătoare. Gratuit în browser din 2004, acum și pe mobil.",
    spTrustFree="Gratuit",
    spTrustYears="Online din 2004",
    spTrustFair="Niciodată pay-to-win",
    spContinueWith="Continuă cu {0}",
    spOrUseEmail="sau folosește o adresă de e-mail",
    spWaysTitle="Două moduri de a intra",
    spWaySocial="Continuă cu contul tău Google sau Facebook — nicio parolă nouă de reținut.",
    spWayEmail="Sau creează un cont nou cu orice altă adresă de e-mail.",
    spWayEmailOnly="Creează un cont nou cu orice adresă de e-mail.",
    spRegisterLead="Continuă cu contul tău Google sau Facebook ori creează un cont nou cu orice altă adresă de e-mail.",
    spRegisterLeadEmailOnly="Creează-ți contul cu orice adresă de e-mail.",
    spRegisterFoot="Gratuit. Nimic de descărcat și nimic de plătit.",
    spFootLead="Din 2004, managerul tău de fotbal preferat.",
    spFaq="Întrebări frecvente",
    spTerms="Termenii serviciului",
    spPrivacy="Notă de confidențialitate",
)

M["cs"] = dict(
    spSendResetEmail="Odeslat e-mail pro obnovení",
    spRememberedPassword="Vzpomněl sis na heslo?",
    languages="Jazyk",
    loginAccountTitle="Přihlásit se",
    registerTitle="Vytvoř si klub",
    doLogIn="Přihlásit se",
    doRegister="Vytvoř si klub",
    noAccount="Jsi tu nový?",
    spHaveAccount="Už máš účet?",
    spHeroDeck="Veď svůj vlastní fotbalový klub. Pár minut denně.",
    spHeroLead="Tvůj klub hraje ligový zápas každý všední den. Zdarma v prohlížeči od roku 2004, nyní i na mobilu.",
    spTrustFree="Zdarma",
    spTrustYears="Online od roku 2004",
    spTrustFair="Nikdy pay-to-win",
    spContinueWith="Pokračovat pomocí {0}",
    spOrUseEmail="nebo použij e-mailovou adresu",
    spWaysTitle="Dvě cesty dovnitř",
    spWaySocial="Pokračuj se svým účtem Google nebo Facebook — žádné nové heslo k zapamatování.",
    spWayEmail="Nebo si vytvoř nový účet s jakoukoli jinou e-mailovou adresou.",
    spWayEmailOnly="Vytvoř si nový účet s jakoukoli e-mailovou adresou.",
    spRegisterLead="Pokračuj se svým účtem Google nebo Facebook, nebo si vytvoř nový účet s jakoukoli jinou e-mailovou adresou.",
    spRegisterLeadEmailOnly="Vytvoř si účet s jakoukoli e-mailovou adresou.",
    spRegisterFoot="Zdarma. Nic ke stažení a nic k placení.",
    spFootLead="Od roku 2004 tvůj oblíbený fotbalový manažer.",
    spFaq="Časté dotazy",
    spTerms="Podmínky služby",
    spPrivacy="Zásady ochrany osobních údajů",
)

M["sk"] = dict(
    spSendResetEmail="Odoslať e-mail na obnovenie",
    spRememberedPassword="Spomenul si si heslo?",
    languages="Jazyk",
    loginAccountTitle="Prihlásiť sa",
    registerTitle="Vytvor si klub",
    doLogIn="Prihlásiť sa",
    doRegister="Vytvor si klub",
    noAccount="Si tu nový?",
    spHaveAccount="Už máš účet?",
    spHeroDeck="Veď svoj vlastný futbalový klub. Pár minút denne.",
    spHeroLead="Tvoj klub hrá ligový zápas každý pracovný deň. Zadarmo v prehliadači od roku 2004, teraz aj na mobile.",
    spTrustFree="Zadarmo",
    spTrustYears="Online od roku 2004",
    spTrustFair="Nikdy pay-to-win",
    spContinueWith="Pokračovať s {0}",
    spOrUseEmail="alebo použi e-mailovú adresu",
    spWaysTitle="Dve cesty dnu",
    spWaySocial="Pokračuj so svojím účtom Google alebo Facebook — žiadne nové heslo na zapamätanie.",
    spWayEmail="Alebo si vytvor nový účet s ľubovoľnou inou e-mailovou adresou.",
    spWayEmailOnly="Vytvor si nový účet s ľubovoľnou e-mailovou adresou.",
    spRegisterLead="Pokračuj so svojím účtom Google alebo Facebook, alebo si vytvor nový účet s ľubovoľnou inou e-mailovou adresou.",
    spRegisterLeadEmailOnly="Vytvor si účet s ľubovoľnou e-mailovou adresou.",
    spRegisterFoot="Zadarmo. Nič na stiahnutie a nič na zaplatenie.",
    spFootLead="Od roku 2004 tvoj obľúbený futbalový manažér.",
    spFaq="Časté otázky",
    spTerms="Podmienky služby",
    spPrivacy="Zásady ochrany osobných údajov",
)

M["sl"] = dict(
    spSendResetEmail="Pošlji e-pošto za ponastavitev",
    spRememberedPassword="Se spet spomniš gesla?",
    languages="Jezik",
    loginAccountTitle="Prijava",
    registerTitle="Ustvari svoj klub",
    doLogIn="Prijava",
    doRegister="Ustvari svoj klub",
    noAccount="Si nov tukaj?",
    spHaveAccount="Že imaš račun?",
    spHeroDeck="Vodi svoj lastni nogometni klub. Nekaj minut na dan.",
    spHeroLead="Tvoj klub igra ligaško tekmo vsak delovni dan. Brezplačno v brskalniku od leta 2004, zdaj tudi na mobilnem telefonu.",
    spTrustFree="Brezplačno",
    spTrustYears="Na spletu od leta 2004",
    spTrustFair="Nikoli pay-to-win",
    spContinueWith="Nadaljuj z {0}",
    spOrUseEmail="ali uporabi e-poštni naslov",
    spWaysTitle="Dve poti noter",
    spWaySocial="Nadaljuj s svojim računom Google ali Facebook — brez novega gesla za pomnjenje.",
    spWayEmail="Ali ustvari nov račun s katerim koli drugim e-poštnim naslovom.",
    spWayEmailOnly="Ustvari nov račun s katerim koli e-poštnim naslovom.",
    spRegisterLead="Nadaljuj s svojim računom Google ali Facebook ali ustvari nov račun s katerim koli drugim e-poštnim naslovom.",
    spRegisterLeadEmailOnly="Ustvari svoj račun s katerim koli e-poštnim naslovom.",
    spRegisterFoot="Brezplačno. Nič za prenos in nič za plačilo.",
    spFootLead="Od leta 2004 tvoj najljubši nogometni manager.",
    spFaq="Pogosta vprašanja",
    spTerms="Pogoji uporabe",
    spPrivacy="Obvestilo o zasebnosti",
)

M["pl"] = dict(
    spSendResetEmail="Wyślij e-mail resetujący",
    spRememberedPassword="Przypomniałeś sobie hasło?",
    languages="Język",
    loginAccountTitle="Zaloguj się",
    registerTitle="Załóż swój klub",
    doLogIn="Zaloguj się",
    doRegister="Załóż swój klub",
    noAccount="Nowy tutaj?",
    spHaveAccount="Masz już konto?",
    spHeroDeck="Prowadź własny klub piłkarski. Kilka minut dziennie.",
    spHeroLead="Twój klub gra mecz ligowy w każdy dzień roboczy. Za darmo w przeglądarce od 2004 roku, teraz także na telefonie.",
    spTrustFree="Za darmo",
    spTrustYears="Online od 2004 roku",
    spTrustFair="Nigdy pay-to-win",
    spContinueWith="Kontynuuj z {0}",
    spOrUseEmail="albo użyj adresu e-mail",
    spWaysTitle="Dwie drogi do gry",
    spWaySocial="Kontynuuj ze swoim kontem Google lub Facebook — żadnego nowego hasła do zapamiętania.",
    spWayEmail="Albo załóż nowe konto z dowolnym innym adresem e-mail.",
    spWayEmailOnly="Załóż nowe konto z dowolnym adresem e-mail.",
    spRegisterLead="Kontynuuj ze swoim kontem Google lub Facebook albo załóż nowe konto z dowolnym innym adresem e-mail.",
    spRegisterLeadEmailOnly="Załóż konto z dowolnym adresem e-mail.",
    spRegisterFoot="Za darmo. Nic do pobrania i nic do zapłaty.",
    spFootLead="Od 2004 roku Twój ulubiony menedżer piłkarski.",
    spFaq="Najczęstsze pytania",
    spTerms="Warunki korzystania",
    spPrivacy="Informacja o prywatności",
)

M["hu"] = dict(
    spSendResetEmail="Visszaállító e-mail küldése",
    spRememberedPassword="Eszedbe jutott a jelszavad?",
    languages="Nyelv",
    loginAccountTitle="Bejelentkezés",
    registerTitle="Hozd létre a klubodat",
    doLogIn="Bejelentkezés",
    doRegister="Hozd létre a klubodat",
    noAccount="Új vagy itt?",
    spHaveAccount="Van már fiókod?",
    spHeroDeck="Irányítsd a saját futballklubodat. Napi néhány perc.",
    spHeroLead="A klubod minden hétköznap bajnoki mérkőzést játszik. 2004 óta ingyen a böngésződben, most már mobilon is.",
    spTrustFree="Ingyenes",
    spTrustYears="2004 óta online",
    spTrustFair="Soha nem pay-to-win",
    spContinueWith="Folytatás ezzel: {0}",
    spOrUseEmail="vagy használj e-mail-címet",
    spWaysTitle="Két út befelé",
    spWaySocial="Folytasd a Google- vagy Facebook-fiókoddal — nincs új jelszó, amit meg kell jegyezned.",
    spWayEmail="Vagy hozz létre új fiókot bármely más e-mail-címmel.",
    spWayEmailOnly="Hozz létre új fiókot bármely e-mail-címmel.",
    spRegisterLead="Folytasd a Google- vagy Facebook-fiókoddal, vagy hozz létre új fiókot bármely más e-mail-címmel.",
    spRegisterLeadEmailOnly="Hozd létre a fiókodat bármely e-mail-címmel.",
    spRegisterFoot="Ingyenes. Nincs mit letölteni és nincs mit fizetni.",
    spFootLead="2004 óta a kedvenc futballmenedzsered.",
    spFaq="Gyakori kérdések",
    spTerms="Szolgáltatási feltételek",
    spPrivacy="Adatvédelmi tájékoztató",
)

M["hr"] = dict(
    spSendResetEmail="Pošalji e-mail za ponovno postavljanje",
    spRememberedPassword="Sjetio si se lozinke?",
    languages="Jezik",
    loginAccountTitle="Prijava",
    registerTitle="Stvori svoj klub",
    doLogIn="Prijava",
    doRegister="Stvori svoj klub",
    noAccount="Nov si ovdje?",
    spHaveAccount="Već imaš račun?",
    spHeroDeck="Vodi svoj vlastiti nogometni klub. Nekoliko minuta dnevno.",
    spHeroLead="Tvoj klub igra ligašku utakmicu svaki radni dan. Besplatno u pregledniku od 2004., sada i na mobitelu.",
    spTrustFree="Besplatno",
    spTrustYears="Online od 2004.",
    spTrustFair="Nikad pay-to-win",
    spContinueWith="Nastavi s {0}",
    spOrUseEmail="ili upotrijebi e-mail adresu",
    spWaysTitle="Dva načina za ulazak",
    spWaySocial="Nastavi sa svojim Google ili Facebook računom — bez nove lozinke za pamćenje.",
    spWayEmail="Ili otvori novi račun s bilo kojom drugom e-mail adresom.",
    spWayEmailOnly="Otvori novi račun s bilo kojom e-mail adresom.",
    spRegisterLead="Nastavi sa svojim Google ili Facebook računom ili otvori novi račun s bilo kojom drugom e-mail adresom.",
    spRegisterLeadEmailOnly="Otvori račun s bilo kojom e-mail adresom.",
    spRegisterFoot="Besplatno. Ništa za preuzimanje i ništa za platiti.",
    spFootLead="Od 2004. tvoj omiljeni nogometni menedžer.",
    spFaq="Česta pitanja",
    spTerms="Uvjeti usluge",
    spPrivacy="Obavijest o privatnosti",
)

M["el"] = dict(
    spSendResetEmail="Αποστολή email επαναφοράς",
    spRememberedPassword="Θυμήθηκες τον κωδικό σου;",
    languages="Γλώσσα",
    loginAccountTitle="Σύνδεση",
    registerTitle="Δημιούργησε τον σύλλογό σου",
    doLogIn="Σύνδεση",
    doRegister="Δημιούργησε τον σύλλογό σου",
    noAccount="Νέος εδώ;",
    spHaveAccount="Έχεις ήδη λογαριασμό;",
    spHeroDeck="Διοίκησε τη δική σου ποδοσφαιρική ομάδα. Λίγα λεπτά την ημέρα.",
    spHeroLead="Η ομάδα σου παίζει αγώνα πρωταθλήματος κάθε εργάσιμη ημέρα. Δωρεάν στον browser από το 2004, τώρα και στο κινητό.",
    spTrustFree="Δωρεάν",
    spTrustYears="Online από το 2004",
    spTrustFair="Ποτέ pay-to-win",
    spContinueWith="Συνέχεια με {0}",
    spOrUseEmail="ή χρησιμοποίησε μια διεύθυνση email",
    spWaysTitle="Δύο τρόποι για να μπεις",
    spWaySocial="Συνέχισε με τον λογαριασμό σου Google ή Facebook — κανένας νέος κωδικός για να θυμάσαι.",
    spWayEmail="Ή δημιούργησε νέο λογαριασμό με οποιαδήποτε άλλη διεύθυνση email.",
    spWayEmailOnly="Δημιούργησε νέο λογαριασμό με οποιαδήποτε διεύθυνση email.",
    spRegisterLead="Συνέχισε με τον λογαριασμό σου Google ή Facebook, ή δημιούργησε νέο λογαριασμό με οποιαδήποτε άλλη διεύθυνση email.",
    spRegisterLeadEmailOnly="Δημιούργησε τον λογαριασμό σου με οποιαδήποτε διεύθυνση email.",
    spRegisterFoot="Δωρεάν. Τίποτα για κατέβασμα και τίποτα για πληρωμή.",
    spFootLead="Από το 2004, ο αγαπημένος σου football manager.",
    spFaq="Συχνές ερωτήσεις",
    spTerms="Όροι χρήσης",
    spPrivacy="Δήλωση απορρήτου",
)

M["no"] = dict(
    spSendResetEmail="Send e-post for tilbakestilling",
    spRememberedPassword="Husket du passordet?",
    languages="Språk",
    loginAccountTitle="Logg inn",
    registerTitle="Opprett klubben din",
    doLogIn="Logg inn",
    doRegister="Opprett klubben din",
    noAccount="Ny her?",
    spHaveAccount="Har du allerede en konto?",
    spHeroDeck="Led din egen fotballklubb. Noen minutter om dagen.",
    spHeroLead="Klubben din spiller seriekamp hver ukedag. Gratis i nettleseren siden 2004, nå også på mobil.",
    spTrustFree="Gratis å spille",
    spTrustYears="På nett siden 2004",
    spTrustFair="Aldri pay-to-win",
    spContinueWith="Fortsett med {0}",
    spOrUseEmail="eller bruk en e-postadresse",
    spWaysTitle="To veier inn",
    spWaySocial="Fortsett med Google- eller Facebook-kontoen din — ingen nye passord å huske.",
    spWayEmail="Eller opprett en ny konto med en hvilken som helst annen e-postadresse.",
    spWayEmailOnly="Opprett en ny konto med en hvilken som helst e-postadresse.",
    spRegisterLead="Fortsett med Google- eller Facebook-kontoen din, eller opprett en ny konto med en hvilken som helst annen e-postadresse.",
    spRegisterLeadEmailOnly="Opprett kontoen din med en hvilken som helst e-postadresse.",
    spRegisterFoot="Gratis å spille. Ingenting å laste ned og ingenting å betale.",
    spFootLead="Siden 2004 din favorittfotballmanager.",
    spFaq="Ofte stilte spørsmål",
    spTerms="Vilkår for bruk",
    spPrivacy="Personvernerklæring",
)

M["sv"] = dict(
    spSendResetEmail="Skicka återställningsmejl",
    spRememberedPassword="Kom du ihåg lösenordet?",
    languages="Språk",
    loginAccountTitle="Logga in",
    registerTitle="Skapa din klubb",
    doLogIn="Logga in",
    doRegister="Skapa din klubb",
    noAccount="Ny här?",
    spHaveAccount="Har du redan ett konto?",
    spHeroDeck="Led din egen fotbollsklubb. Några minuter om dagen.",
    spHeroLead="Din klubb spelar en seriematch varje vardag. Gratis i webbläsaren sedan 2004, nu även i mobilen.",
    spTrustFree="Gratis att spela",
    spTrustYears="Online sedan 2004",
    spTrustFair="Aldrig pay-to-win",
    spContinueWith="Fortsätt med {0}",
    spOrUseEmail="eller använd en e-postadress",
    spWaysTitle="Två vägar in",
    spWaySocial="Fortsätt med ditt Google- eller Facebook-konto — inget nytt lösenord att komma ihåg.",
    spWayEmail="Eller skapa ett nytt konto med vilken annan e-postadress som helst.",
    spWayEmailOnly="Skapa ett nytt konto med vilken e-postadress som helst.",
    spRegisterLead="Fortsätt med ditt Google- eller Facebook-konto, eller skapa ett nytt konto med vilken annan e-postadress som helst.",
    spRegisterLeadEmailOnly="Skapa ditt konto med vilken e-postadress som helst.",
    spRegisterFoot="Gratis att spela. Inget att ladda ner och inget att betala.",
    spFootLead="Sedan 2004 din favoritfotbollsmanager.",
    spFaq="Vanliga frågor",
    spTerms="Användarvillkor",
    spPrivacy="Integritetspolicy",
)

M["da"] = dict(
    spSendResetEmail="Send nulstillingsmail",
    spRememberedPassword="Kom du i tanke om adgangskoden?",
    languages="Sprog",
    loginAccountTitle="Log ind",
    registerTitle="Opret din klub",
    doLogIn="Log ind",
    doRegister="Opret din klub",
    noAccount="Ny her?",
    spHaveAccount="Har du allerede en konto?",
    spHeroDeck="Led din egen fodboldklub. Et par minutter om dagen.",
    spHeroLead="Din klub spiller en ligakamp hver hverdag. Gratis i browseren siden 2004, nu også på mobil.",
    spTrustFree="Gratis at spille",
    spTrustYears="Online siden 2004",
    spTrustFair="Aldrig pay-to-win",
    spContinueWith="Fortsæt med {0}",
    spOrUseEmail="eller brug en e-mailadresse",
    spWaysTitle="To veje ind",
    spWaySocial="Fortsæt med din Google- eller Facebook-konto — ingen ny adgangskode at huske.",
    spWayEmail="Eller opret en ny konto med en hvilken som helst anden e-mailadresse.",
    spWayEmailOnly="Opret en ny konto med en hvilken som helst e-mailadresse.",
    spRegisterLead="Fortsæt med din Google- eller Facebook-konto, eller opret en ny konto med en hvilken som helst anden e-mailadresse.",
    spRegisterLeadEmailOnly="Opret din konto med en hvilken som helst e-mailadresse.",
    spRegisterFoot="Gratis at spille. Intet at downloade og intet at betale.",
    spFootLead="Siden 2004 din yndlingsfodboldmanager.",
    spFaq="Ofte stillede spørgsmål",
    spTerms="Servicevilkår",
    spPrivacy="Privatlivspolitik",
)

M["fi"] = dict(
    spSendResetEmail="Lähetä palautusviesti",
    spRememberedPassword="Muistitko salasanasi?",
    languages="Kieli",
    loginAccountTitle="Kirjaudu sisään",
    registerTitle="Luo oma seurasi",
    doLogIn="Kirjaudu sisään",
    doRegister="Luo oma seurasi",
    noAccount="Uusi täällä?",
    spHaveAccount="Onko sinulla jo tili?",
    spHeroDeck="Johda omaa jalkapalloseuraasi. Muutama minuutti päivässä.",
    spHeroLead="Seurasi pelaa sarjaottelun joka arkipäivä. Ilmaiseksi selaimessa vuodesta 2004, nyt myös mobiilissa.",
    spTrustFree="Ilmainen",
    spTrustYears="Verkossa vuodesta 2004",
    spTrustFair="Ei koskaan pay-to-win",
    spContinueWith="Jatka palvelulla {0}",
    spOrUseEmail="tai käytä sähköpostiosoitetta",
    spWaysTitle="Kaksi tapaa aloittaa",
    spWaySocial="Jatka Google- tai Facebook-tililläsi — ei uutta salasanaa muistettavaksi.",
    spWayEmail="Tai luo uusi tili millä tahansa muulla sähköpostiosoitteella.",
    spWayEmailOnly="Luo uusi tili millä tahansa sähköpostiosoitteella.",
    spRegisterLead="Jatka Google- tai Facebook-tililläsi tai luo uusi tili millä tahansa muulla sähköpostiosoitteella.",
    spRegisterLeadEmailOnly="Luo tilisi millä tahansa sähköpostiosoitteella.",
    spRegisterFoot="Ilmainen. Ei mitään ladattavaa eikä mitään maksettavaa.",
    spFootLead="Vuodesta 2004 suosikkijalkapallomanagerisi.",
    spFaq="Usein kysytyt kysymykset",
    spTerms="Käyttöehdot",
    spPrivacy="Tietosuojaseloste",
)

M["lt"] = dict(
    spSendResetEmail="Siųsti atkūrimo laišką",
    spRememberedPassword="Prisiminei slaptažodį?",
    languages="Kalba",
    loginAccountTitle="Prisijungti",
    registerTitle="Sukurk savo klubą",
    doLogIn="Prisijungti",
    doRegister="Sukurk savo klubą",
    noAccount="Naujokas čia?",
    spHaveAccount="Jau turi paskyrą?",
    spHeroDeck="Vadovauk savo futbolo klubui. Kelios minutės per dieną.",
    spHeroLead="Tavo klubas žaidžia lygos rungtynes kiekvieną darbo dieną. Nemokamai naršyklėje nuo 2004 m., dabar ir telefone.",
    spTrustFree="Nemokama",
    spTrustYears="Internete nuo 2004 m.",
    spTrustFair="Niekada ne pay-to-win",
    spContinueWith="Tęsti su {0}",
    spOrUseEmail="arba naudok el. pašto adresą",
    spWaysTitle="Du keliai vidun",
    spWaySocial="Tęsk su savo Google arba Facebook paskyra — jokio naujo slaptažodžio, kurį reikėtų prisiminti.",
    spWayEmail="Arba sukurk naują paskyrą su bet kuriuo kitu el. pašto adresu.",
    spWayEmailOnly="Sukurk naują paskyrą su bet kuriuo el. pašto adresu.",
    spRegisterLead="Tęsk su savo Google arba Facebook paskyra arba sukurk naują paskyrą su bet kuriuo kitu el. pašto adresu.",
    spRegisterLeadEmailOnly="Sukurk paskyrą su bet kuriuo el. pašto adresu.",
    spRegisterFoot="Nemokama. Nieko nereikia atsisiųsti ir nieko mokėti.",
    spFootLead="Nuo 2004 m. tavo mėgstamiausias futbolo vadybininkas.",
    spFaq="Dažni klausimai",
    spTerms="Paslaugų sąlygos",
    spPrivacy="Privatumo pranešimas",
)

M["lv"] = dict(
    spSendResetEmail="Nosūtīt atiestatīšanas e-pastu",
    spRememberedPassword="Atcerējies paroli?",
    languages="Valoda",
    loginAccountTitle="Pieteikties",
    registerTitle="Izveido savu klubu",
    doLogIn="Pieteikties",
    doRegister="Izveido savu klubu",
    noAccount="Jauns šeit?",
    spHaveAccount="Jau ir konts?",
    spHeroDeck="Vadi savu futbola klubu. Dažas minūtes dienā.",
    spHeroLead="Tavs klubs spēlē līgas spēli katru darbdienu. Bez maksas pārlūkprogrammā kopš 2004. gada, tagad arī mobilajā ierīcē.",
    spTrustFree="Bez maksas",
    spTrustYears="Tiešsaistē kopš 2004. gada",
    spTrustFair="Nekad pay-to-win",
    spContinueWith="Turpināt ar {0}",
    spOrUseEmail="vai izmanto e-pasta adresi",
    spWaysTitle="Divi ceļi iekšā",
    spWaySocial="Turpini ar savu Google vai Facebook kontu — nav jaunas paroles, kas jāatceras.",
    spWayEmail="Vai izveido jaunu kontu ar jebkuru citu e-pasta adresi.",
    spWayEmailOnly="Izveido jaunu kontu ar jebkuru e-pasta adresi.",
    spRegisterLead="Turpini ar savu Google vai Facebook kontu vai izveido jaunu kontu ar jebkuru citu e-pasta adresi.",
    spRegisterLeadEmailOnly="Izveido savu kontu ar jebkuru e-pasta adresi.",
    spRegisterFoot="Bez maksas. Nekas nav jālejupielādē un nekas nav jāmaksā.",
    spFootLead="Kopš 2004. gada tavs iecienītākais futbola menedžeris.",
    spFaq="Biežāk uzdotie jautājumi",
    spTerms="Pakalpojuma noteikumi",
    spPrivacy="Privātuma paziņojums",
)

M["tr"] = dict(
    spSendResetEmail="Sıfırlama e-postası gönder",
    spRememberedPassword="Şifreni hatırladın mı?",
    languages="Dil",
    loginAccountTitle="Giriş yap",
    registerTitle="Kulübünü kur",
    doLogIn="Giriş yap",
    doRegister="Kulübünü kur",
    noAccount="Burada yeni misin?",
    spHaveAccount="Zaten hesabın var mı?",
    spHeroDeck="Kendi futbol kulübünü yönet. Günde birkaç dakika.",
    spHeroLead="Kulübün her hafta içi bir lig maçı oynuyor. 2004’ten beri tarayıcında ücretsiz, artık mobilde de.",
    spTrustFree="Ücretsiz",
    spTrustYears="2004’ten beri çevrimiçi",
    spTrustFair="Asla pay-to-win değil",
    spContinueWith="{0} ile devam et",
    spOrUseEmail="ya da bir e-posta adresi kullan",
    spWaysTitle="İçeri girmenin iki yolu",
    spWaySocial="Google veya Facebook hesabınla devam et — hatırlaman gereken yeni bir şifre yok.",
    spWayEmail="Ya da başka herhangi bir e-posta adresiyle yeni bir hesap oluştur.",
    spWayEmailOnly="Herhangi bir e-posta adresiyle yeni bir hesap oluştur.",
    spRegisterLead="Google veya Facebook hesabınla devam et ya da başka herhangi bir e-posta adresiyle yeni bir hesap oluştur.",
    spRegisterLeadEmailOnly="Hesabını herhangi bir e-posta adresiyle oluştur.",
    spRegisterFoot="Ücretsiz. İndirilecek bir şey yok, ödenecek bir şey yok.",
    spFootLead="2004’ten beri en sevdiğin futbol menajeri.",
    spFaq="Sık sorulan sorular",
    spTerms="Hizmet koşulları",
    spPrivacy="Gizlilik bildirimi",
)

M["uk"] = dict(
    spSendResetEmail="Надіслати лист для відновлення",
    spRememberedPassword="Згадали пароль?",
    languages="Мова",
    loginAccountTitle="Увійти",
    registerTitle="Створи свій клуб",
    doLogIn="Увійти",
    doRegister="Створи свій клуб",
    noAccount="Уперше тут?",
    spHaveAccount="Уже маєш акаунт?",
    spHeroDeck="Керуй власним футбольним клубом. Кілька хвилин на день.",
    spHeroLead="Твій клуб грає матч чемпіонату щобудня. Безкоштовно у браузері з 2004 року, тепер і на мобільному.",
    spTrustFree="Безкоштовно",
    spTrustYears="Онлайн з 2004 року",
    spTrustFair="Ніколи не pay-to-win",
    spContinueWith="Продовжити з {0}",
    spOrUseEmail="або скористайся адресою електронної пошти",
    spWaysTitle="Два шляхи всередину",
    spWaySocial="Продовжуй зі своїм акаунтом Google або Facebook — жодного нового пароля запам’ятовувати.",
    spWayEmail="Або створи новий акаунт із будь-якою іншою адресою електронної пошти.",
    spWayEmailOnly="Створи новий акаунт із будь-якою адресою електронної пошти.",
    spRegisterLead="Продовжуй зі своїм акаунтом Google або Facebook чи створи новий акаунт із будь-якою іншою адресою електронної пошти.",
    spRegisterLeadEmailOnly="Створи акаунт із будь-якою адресою електронної пошти.",
    spRegisterFoot="Безкоштовно. Нічого не треба завантажувати і нічого платити.",
    spFootLead="З 2004 року твій улюблений футбольний менеджер.",
    spFaq="Часті запитання",
    spTerms="Умови користування",
    spPrivacy="Повідомлення про конфіденційність",
)

M["ru"] = dict(
    spSendResetEmail="Отправить письмо для сброса",
    spRememberedPassword="Вспомнили пароль?",
    languages="Язык",
    loginAccountTitle="Войти",
    registerTitle="Создай свой клуб",
    doLogIn="Войти",
    doRegister="Создай свой клуб",
    noAccount="Впервые здесь?",
    spHaveAccount="Уже есть аккаунт?",
    spHeroDeck="Управляй собственным футбольным клубом. Несколько минут в день.",
    spHeroLead="Твой клуб играет матч чемпионата каждый будний день. Бесплатно в браузере с 2004 года, теперь и на мобильном.",
    spTrustFree="Бесплатно",
    spTrustYears="Онлайн с 2004 года",
    spTrustFair="Никогда не pay-to-win",
    spContinueWith="Продолжить с {0}",
    spOrUseEmail="или используй адрес электронной почты",
    spWaysTitle="Два пути внутрь",
    spWaySocial="Продолжай со своим аккаунтом Google или Facebook — не нужно запоминать новый пароль.",
    spWayEmail="Или создай новый аккаунт с любым другим адресом электронной почты.",
    spWayEmailOnly="Создай новый аккаунт с любым адресом электронной почты.",
    spRegisterLead="Продолжай со своим аккаунтом Google или Facebook либо создай новый аккаунт с любым другим адресом электронной почты.",
    spRegisterLeadEmailOnly="Создай аккаунт с любым адресом электронной почты.",
    spRegisterFoot="Бесплатно. Ничего не нужно скачивать и ничего платить.",
    spFootLead="С 2004 года твой любимый футбольный менеджер.",
    spFaq="Частые вопросы",
    spTerms="Условия использования",
    spPrivacy="Уведомление о конфиденциальности",
)

M["ca"] = dict(
    spSendResetEmail="Envia el correu de restabliment",
    spRememberedPassword="Ja recordes la contrasenya?",
    languages="Idioma",
    loginAccountTitle="Inicia la sessió",
    registerTitle="Crea el teu club",
    doLogIn="Inicia la sessió",
    doRegister="Crea el teu club",
    noAccount="Ets nou aquí?",
    spHaveAccount="Ja tens un compte?",
    spHeroDeck="Dirigeix el teu propi club de futbol. Uns minuts al dia.",
    spHeroLead="El teu club juga un partit de lliga cada dia feiner. Gratis al navegador des del 2004, ara també al mòbil.",
    spTrustFree="Gratis",
    spTrustYears="En línia des del 2004",
    spTrustFair="Mai pay-to-win",
    spContinueWith="Continua amb {0}",
    spOrUseEmail="o fes servir una adreça electrònica",
    spWaysTitle="Dues maneres d’entrar",
    spWaySocial="Continua amb el teu compte de Google o Facebook: cap contrasenya nova per recordar.",
    spWayEmail="O crea un compte nou amb qualsevol altra adreça electrònica.",
    spWayEmailOnly="Crea un compte nou amb qualsevol adreça electrònica.",
    spRegisterLead="Continua amb el teu compte de Google o Facebook, o crea un compte nou amb qualsevol altra adreça electrònica.",
    spRegisterLeadEmailOnly="Crea el teu compte amb qualsevol adreça electrònica.",
    spRegisterFoot="Gratis. Res per descarregar i res per pagar.",
    spFootLead="Des del 2004, el teu mànager de futbol preferit.",
    spFaq="Preguntes freqüents",
    spTerms="Condicions del servei",
    spPrivacy="Avís de privadesa",
)

M["id"] = dict(
    spSendResetEmail="Kirim email pengaturan ulang",
    spRememberedPassword="Sudah ingat kata sandimu?",
    languages="Bahasa",
    loginAccountTitle="Masuk",
    registerTitle="Buat klubmu",
    doLogIn="Masuk",
    doRegister="Buat klubmu",
    noAccount="Baru di sini?",
    spHaveAccount="Sudah punya akun?",
    spHeroDeck="Kelola klub sepak bolamu sendiri. Beberapa menit sehari.",
    spHeroLead="Klubmu bermain satu pertandingan liga setiap hari kerja. Gratis di browser sejak 2004, sekarang juga di ponsel.",
    spTrustFree="Gratis dimainkan",
    spTrustYears="Online sejak 2004",
    spTrustFair="Tidak pernah pay-to-win",
    spContinueWith="Lanjutkan dengan {0}",
    spOrUseEmail="atau gunakan alamat email",
    spWaysTitle="Dua cara masuk",
    spWaySocial="Lanjutkan dengan akun Google atau Facebook-mu — tidak ada kata sandi baru yang harus diingat.",
    spWayEmail="Atau buat akun baru dengan alamat email lain mana pun.",
    spWayEmailOnly="Buat akun baru dengan alamat email mana pun.",
    spRegisterLead="Lanjutkan dengan akun Google atau Facebook-mu, atau buat akun baru dengan alamat email lain mana pun.",
    spRegisterLeadEmailOnly="Buat akunmu dengan alamat email mana pun.",
    spRegisterFoot="Gratis dimainkan. Tidak ada yang perlu diunduh dan tidak ada yang perlu dibayar.",
    spFootLead="Sejak 2004, manajer sepak bola favoritmu.",
    spFaq="Pertanyaan umum",
    spTerms="Ketentuan layanan",
    spPrivacy="Pemberitahuan privasi",
)

M["ja"] = dict(
    spSendResetEmail="再設定メールを送信",
    spRememberedPassword="パスワードを思い出しましたか？",
    languages="言語",
    loginAccountTitle="ログイン",
    registerTitle="クラブを作成",
    doLogIn="ログイン",
    doRegister="クラブを作成",
    noAccount="はじめての方ですか？",
    spHaveAccount="すでにアカウントをお持ちですか？",
    spHeroDeck="自分のサッカークラブを運営しよう。1日数分から。",
    spHeroLead="あなたのクラブは平日毎日リーグ戦を戦います。2004年からブラウザで無料、今はスマートフォンでも。",
    spTrustFree="無料でプレイ",
    spTrustYears="2004年からオンライン",
    spTrustFair="課金で勝てるゲームではありません",
    spContinueWith="{0} で続行",
    spOrUseEmail="またはメールアドレスを使う",
    spWaysTitle="参加方法は2つ",
    spWaySocial="Google または Facebook のアカウントでそのまま続行できます。新しいパスワードを覚える必要はありません。",
    spWayEmail="または、ほかの好きなメールアドレスで新しいアカウントを作成できます。",
    spWayEmailOnly="好きなメールアドレスで新しいアカウントを作成できます。",
    spRegisterLead="Google または Facebook のアカウントで続行するか、ほかの好きなメールアドレスで新しいアカウントを作成してください。",
    spRegisterLeadEmailOnly="好きなメールアドレスでアカウントを作成してください。",
    spRegisterFoot="無料でプレイ。ダウンロードも支払いも不要です。",
    spFootLead="2004年から、あなたのお気に入りのサッカーマネージャー。",
    spFaq="よくある質問",
    spTerms="利用規約",
    spPrivacy="プライバシーに関する通知",
)

M["ko"] = dict(
    spSendResetEmail="재설정 메일 보내기",
    spRememberedPassword="비밀번호가 기억나셨나요?",
    languages="언어",
    loginAccountTitle="로그인",
    registerTitle="클럽 만들기",
    doLogIn="로그인",
    doRegister="클럽 만들기",
    noAccount="처음이신가요?",
    spHaveAccount="이미 계정이 있으신가요?",
    spHeroDeck="나만의 축구 클럽을 운영하세요. 하루 몇 분이면 충분합니다.",
    spHeroLead="당신의 클럽은 평일마다 리그 경기를 치릅니다. 2004년부터 브라우저에서 무료로, 이제 모바일에서도.",
    spTrustFree="무료 플레이",
    spTrustYears="2004년부터 서비스 중",
    spTrustFair="절대 페이 투 윈 아님",
    spContinueWith="{0}(으)로 계속하기",
    spOrUseEmail="또는 이메일 주소 사용",
    spWaysTitle="시작하는 두 가지 방법",
    spWaySocial="Google 또는 Facebook 계정으로 바로 계속하세요. 새 비밀번호를 외울 필요가 없습니다.",
    spWayEmail="또는 다른 아무 이메일 주소로 새 계정을 만드세요.",
    spWayEmailOnly="아무 이메일 주소로 새 계정을 만드세요.",
    spRegisterLead="Google 또는 Facebook 계정으로 계속하거나, 다른 아무 이메일 주소로 새 계정을 만드세요.",
    spRegisterLeadEmailOnly="아무 이메일 주소로 계정을 만드세요.",
    spRegisterFoot="무료 플레이. 내려받을 것도, 결제할 것도 없습니다.",
    spFootLead="2004년부터, 당신이 가장 좋아하는 축구 매니저.",
    spFaq="자주 묻는 질문",
    spTerms="서비스 약관",
    spPrivacy="개인정보 처리방침",
)

M["zh-CN"] = dict(
    spSendResetEmail="发送重置邮件",
    spRememberedPassword="想起密码了？",
    languages="语言",
    loginAccountTitle="登录",
    registerTitle="创建你的俱乐部",
    doLogIn="登录",
    doRegister="创建你的俱乐部",
    noAccount="第一次来？",
    spHaveAccount="已经有账号了？",
    spHeroDeck="经营属于你自己的足球俱乐部。每天几分钟。",
    spHeroLead="你的俱乐部每个工作日都有一场联赛。自 2004 年起在浏览器中免费畅玩，现在也支持手机。",
    spTrustFree="免费游玩",
    spTrustYears="自 2004 年起在线",
    spTrustFair="绝不付费致胜",
    spContinueWith="使用 {0} 继续",
    spOrUseEmail="或使用电子邮件地址",
    spWaysTitle="两种加入方式",
    spWaySocial="使用你的 Google 或 Facebook 账号直接继续，无需记住新密码。",
    spWayEmail="或者用任意其他电子邮件地址创建新账号。",
    spWayEmailOnly="用任意电子邮件地址创建新账号。",
    spRegisterLead="使用你的 Google 或 Facebook 账号继续，或者用任意其他电子邮件地址创建新账号。",
    spRegisterLeadEmailOnly="用任意电子邮件地址创建你的账号。",
    spRegisterFoot="免费游玩。无需下载，无需付费。",
    spFootLead="自 2004 年起，你最喜欢的足球经理游戏。",
    spFaq="常见问题",
    spTerms="服务条款",
    spPrivacy="隐私声明",
)

# Locale code -> messages_<suffix>.properties. Keycloak turns a locale into a
# bundle name the way java.util.ResourceBundle does (FileBasedTheme.
# toBundleName), so `pt-BR` is `pt_BR`; and for `zh-CN` it additionally loads
# `zh_Hans`, which is the name Keycloak's own community bundle uses.
FILE_SUFFIX = {"pt-BR": "pt_BR", "zh-CN": "zh_Hans"}

HEADER = """# SoccerProject.com — %(name)s
#
# GENERATED by tools/gen_messages.py — edit the copy there, not here, so that
# a new key cannot land in some locales and not others.
#
# Only two things live in this file: base Keycloak keys re-worded in the
# product's own voice, and the theme's own sp* keys. Every other string on
# these pages is Keycloak's own translation for this locale.
"""

LOCALE_NAMES = {
    "en": "English", "nl": "Nederlands", "fr": "Français", "de": "Deutsch",
    "es": "Español", "it": "Italiano", "pt": "Português",
    "pt-BR": "Português (Brasil)", "ro": "Română",
    "cs": "Čeština", "sk": "Slovenčina", "sl": "Slovenščina",
    "pl": "Polski", "hu": "Magyar", "hr": "Hrvatski",
    "el": "Ελληνικά", "no": "Norsk",
    "sv": "Svenska", "da": "Dansk", "fi": "Suomi", "lt": "Lietuvių",
    "lv": "Latviešu", "tr": "Türkçe",
    "uk": "Українська",
    "ru": "Русский", "ca": "Català",
    "id": "Bahasa Indonesia", "ja": "日本語",
    "ko": "한국어", "zh-CN": "中文",
}


def escape(value):
    # .properties escaping. The files are UTF-8 (Keycloak reads them charset
    # aware, PropertiesUtil), so only the structural characters need escaping.
    return value.replace("\\", "\\\\").replace("\n", "\\n")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.environ.get("SP_MESSAGES_DIR")
    if not out_dir:
        raise SystemExit("set SP_MESSAGES_DIR")

    keys = [k for k, _ in ORDER] + sorted(ALIASES)
    problems = []

    for code, values in M.items():
        values = dict(values)
        values["spHeroTitle"] = HERO_TITLE
        for key, source in ALIASES.items():
            values[key] = values[source]
        if code == "en":
            values.update(EN_ONLY)
        missing = [k for k in keys if k not in values]
        allowed = set(keys) | (set(EN_ONLY) if code == "en" else set())
        extra = [k for k in values if k not in allowed]
        if missing:
            problems.append("%s missing %s" % (code, missing))
        if extra:
            problems.append("%s has unknown %s" % (code, extra))
        for k, v in values.items():
            if "'" in v:
                problems.append("%s/%s contains an ASCII apostrophe (MessageFormat eats it)" % (code, k))
        M[code] = values

    if problems:
        raise SystemExit("\n".join(problems))

    for code in sorted(M):
        suffix = FILE_SUFFIX.get(code, code)
        path = os.path.join(out_dir, "messages_%s.properties" % suffix)
        with io.open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(HEADER % {"name": LOCALE_NAMES[code]})
            for key, note in ORDER:
                if note:
                    fh.write("\n# %s\n" % note)
                fh.write("%s=%s\n" % (key, escape(M[code][key])))
            fh.write("\n# Keycloak keys taking a value from one of ours (see ALIASES).\n")
            for key in sorted(ALIASES):
                fh.write("%s=%s\n" % (key, escape(M[code][key])))
            if code == "en":
                fh.write("\n# Sentence case, English only (see EN_ONLY).\n")
                for key in sorted(EN_ONLY):
                    fh.write("%s=%s\n" % (key, escape(M[code][key])))
        print(path)

    print("%d locales, %d keys each" % (len(M), len(keys)))


if __name__ == "__main__":
    main()
