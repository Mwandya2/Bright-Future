# Keys and files — step by step

Nothing here is needed to **run** the app on your own machine. Each section
switches on one more capability. They are ordered by when you actually need
them, so work top to bottom and stop when you have what you need today.

Nothing secret is committed. `.gitignore` already excludes `key.properties`,
`*.jks`, `google-services.json` and `GoogleService-Info.plist`.

| # | Thing | Cost | When you need it |
|---|---|---|---|
| 1 | Android upload keystore | free | before your first Play Store upload |
| 2 | Production API URL | ~$5–20/mo hosting | before anyone but you uses the app |
| 3 | Firebase config files | free | for push notifications |
| 4 | Apple Developer Program | $99/year | to ship on iOS at all |
| 5 | APNs key | free (needs #4) | for push on iOS |
| 6 | Google Play Console | $25 once | to ship on Android |
| 7 | ClickPesa keys | free (fees per transaction) | for mobile money payments |

---

## 1. Android upload keystore — do this first, it is free and takes 5 minutes

This is a file **you generate**, not something you fetch from a website. It is
the identity of your app on Google Play forever.

**Step 1.** In Terminal:

```bash
keytool -genkey -v -keystore ~/bright-future-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Step 2.** It asks you a series of questions. Answer them like this:

| Prompt | What to type |
|---|---|
| Enter keystore password | A password you invent. **Write it down.** |
| Re-enter new password | The same one |
| What is your first and last name? | `Peter Mwandya` |
| What is the name of your organizational unit? | `Bright Future Digital Hub` |
| What is the name of your organization? | `Bright Future Digital Hub` |
| What is the name of your City or Locality? | your city |
| What is the name of your State or Province? | your region |
| What is the two-letter country code? | `TZ` |
| Is CN=... correct? | `yes` |

**Step 3.** Tell the project where it is:

```bash
cd ~/brightfuture/mobile
cp android/key.properties.example android/key.properties
open -e android/key.properties
```

Fill in the four lines with real values:

```properties
storePassword=the password you just invented
keyPassword=the same password
keyAlias=upload
storeFile=/Users/YOURNAME/bright-future-upload.jks
```

Run `echo $HOME` if you are not sure of your username.

**Step 4. Back up `bright-future-upload.jks` somewhere safe** — a password
manager, an encrypted drive, anywhere that is not just this laptop. If you lose
this file you can never publish an update to your app. You would have to publish
a brand-new listing and every existing user would have to reinstall.

Never send this file or its password to anyone, including me.

---

## 2. Production API URL — the real work before shipping

Right now your backend runs on your laptop at `localhost:8080`. A phone on
someone else's network cannot reach that. You need the Spring Boot API running
on a public server with an HTTPS address.

### Two things to fix before you deploy

**A. The database.** `backend/src/main/resources/application.yml` defaults to
H2 **in memory** — every restart wipes all users, courses and bookings. The
PostgreSQL driver is already in your `pom.xml`, so switching is just environment
variables, no code change.

**B. The secrets.** These are currently committed with default values in
`application.yml`:

```yaml
app:
  jwt:
    secret: ${JWT_SECRET:BrightFutureSuperSecretKeyForJWTSigningAnd...}
  admin:
    default-password: ${ADMIN_PASSWORD:Admin@BrightFuture2026!}
```

Anyone who reads your repository can forge a login token with that JWT secret.
That is fine for local development — the `${VAR:default}` syntax means the
default is only used when the variable is unset — but you **must** set real
values in production.

### Deploying (Railway is the gentlest option for a first deploy)

1. Push your repo to GitHub if it is not there already.
2. Go to [railway.app](https://railway.app) and sign in with GitHub.
3. **New Project → Deploy from GitHub repo** → pick `brightfuture`.
4. In the project, **+ New → Database → PostgreSQL**. Railway creates it and
   exposes its connection details as variables.
5. Open your app service → **Variables** → add:

   | Variable | Value |
   |---|---|
   | `SPRING_DATASOURCE_URL` | `jdbc:postgresql://${{Postgres.PGHOST}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}}` |
   | `SPRING_DATASOURCE_USERNAME` | `${{Postgres.PGUSER}}` |
   | `SPRING_DATASOURCE_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
   | `SPRING_DATASOURCE_DRIVER_CLASS_NAME` | `org.postgresql.Driver` |
   | `SPRING_JPA_DATABASE_PLATFORM` | `org.hibernate.dialect.PostgreSQLDialect` |
   | `JWT_SECRET` | a long random string — see below |
   | `ADMIN_EMAIL` | your real admin address |
   | `ADMIN_PASSWORD` | a strong password you choose |

   Generate the JWT secret with:
   ```bash
   openssl rand -base64 48
   ```

6. Railway gives you a public URL like `https://brightfuture-production.up.railway.app`.
   **Your `API_BASE_URL` is that URL with `/api` on the end.**

7. Test it in a browser: `https://your-url/api/courses` should return JSON.

8. Build the app against it:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-url/api
   ```

**Alternatives:** [Render](https://render.com) and [Fly.io](https://fly.io) work
the same way and are similarly priced. Any VPS works too if you are comfortable
with Docker and Nginx.

**One cleanup once you are on HTTPS:** delete
`android:usesCleartextTraffic="true"` from
`android/app/src/main/AndroidManifest.xml`. It only exists so plain-HTTP
localhost works while you develop.

---

## 3. Firebase — push notifications (free)

Without this the app still shows local alerts (booking created, order submitted)
and keeps an in-app inbox. Only notifications sent *from your server to a closed
app* are missing.

### Create the project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and
   sign in with a Google account.
2. **Create a project** → name it `Bright Future` → Continue.
3. Google Analytics: you can **turn it off**. You do not need it for push.
4. Wait for it to finish, then **Continue**.

### Add the Android app

5. On the project home page, click the **Android** icon (the little robot).
6. **Android package name:** `com.brightfuture.app` — this must match exactly.
7. **App nickname:** `Bright Future Android` (optional).
8. **Debug signing certificate SHA-1:** leave blank. You only need this for
   Google Sign-In or Dynamic Links, neither of which the app uses.
9. **Register app** → **Download google-services.json**.
10. Move the file into place:
    ```bash
    mv ~/Downloads/google-services.json ~/brightfuture/mobile/android/app/
    ```
11. Click through the remaining "add the SDK" steps in Firebase — the app
    already has that code. Just press Next / Continue to console.

### Add the iOS app

12. Back on the project home page, **Add app → iOS**.
13. **Apple bundle ID:** `com.brightfuture.app` — same as Android.
14. **Register app** → **Download GoogleService-Info.plist**.
15. This one cannot just be copied into a folder — Xcode has to know about it:
    ```bash
    open ~/brightfuture/mobile/ios/Runner.xcworkspace
    ```
    In Xcode's left sidebar, find the yellow **Runner** folder (inside the blue
    Runner project). Drag `GoogleService-Info.plist` from Finder onto it. In the
    dialog that appears, tick **Copy items if needed** and make sure **Runner**
    is ticked under "Add to targets". Click Finish.

### Switch on the Android Gradle plugin

16. ```bash
    cd ~/brightfuture/mobile
    ./tool/enable-firebase.sh
    flutter clean && flutter run
    ```

    This step is separate on purpose: adding the plugin before
    `google-services.json` exists makes the Android build fail with a confusing
    error, so it is off by default.

### Send yourself a test push

17. Firebase Console → **Messaging** → **Create your first campaign** →
    **Firebase Notification messages**.
18. Type a title and body → **Send test message** → paste your device's FCM
    token. To find the token, the app logs it at startup; or use
    **Next → select your app → Review → Publish** to send to everyone.
19. To make a tap open a specific screen, add a **custom data** key `route`
    with a value like `/bookings` or `/printing`.

---

## 4. Apple Developer Program — $99 per year

Required to run the app on a real iPhone for more than 7 days, and to publish at
all. Skip this section entirely if you are shipping Android first.

1. Go to [developer.apple.com/programs](https://developer.apple.com/programs)
   and click **Enroll**.
2. Sign in with your Apple ID. **Two-factor authentication must be on** — turn
   it on in your iPhone's Settings → your name → Sign-In & Security if it is not.
3. Choose the entity type:
   * **Individual / Sole Proprietor** — fastest, usually approved in a day or
     two. Your app is listed under your personal name.
   * **Organization** — your app is listed under "Bright Future Digital Hub",
     but you need a **D-U-N-S number** for the business, which can take one to
     two weeks to obtain (it is free from Dun & Bradstreet).

   If you want the company name on the App Store listing, start the D-U-N-S
   application now, because it is the long pole.
4. Fill in your details and pay the **$99** annual fee.
5. Wait for the approval email — typically 24–48 hours.

Then in Xcode: open `ios/Runner.xcworkspace`, select the **Runner** target →
**Signing & Capabilities** → tick **Automatically manage signing** → pick your
team from the dropdown.

---

## 5. APNs key — iOS push (free, but needs #4 first)

Apple will not let Firebase deliver notifications to iPhones without this.

1. Go to [developer.apple.com/account](https://developer.apple.com/account) and
   sign in.
2. **Certificates, Identifiers & Profiles** → **Keys** (left sidebar) → the
   blue **+** button.
3. **Key Name:** `Bright Future Push`.
4. Tick **Apple Push Notifications service (APNs)** → **Continue** →
   **Register**.
5. **Download** the `.p8` file. **You can only download it once.** Save it
   somewhere safe immediately.
6. On that same confirmation page, note the **Key ID** — a 10-character code
   like `A1B2C3D4E5`. It is also in the filename:
   `AuthKey_A1B2C3D4E5.p8`.
7. Find your **Team ID**: still in the developer portal, click your name in the
   top right → **Membership details**. The Team ID is another 10-character code.
8. Go back to [console.firebase.google.com](https://console.firebase.google.com)
   → your project → the **gear icon** → **Project settings** → **Cloud
   Messaging** tab.
9. Scroll to **Apple app configuration** → your iOS app → **APNs Authentication
   Key** → **Upload**.
10. Upload the `.p8`, and type in the **Key ID** and **Team ID** from steps 6
    and 7. Save.

Finally, in Xcode: **Runner** target → **Signing & Capabilities** →
**+ Capability** → add **Push Notifications**.

---

## 6. Google Play Console — $25, one time

1. Go to [play.google.com/console](https://play.google.com/console) and sign in
   with the Google account you want to own the app.
2. Choose **Personal** or **Organization**. Organization requires a D-U-N-S
   number, same as Apple.
3. Pay the **$25 one-time** registration fee.
4. Complete identity verification — Google asks for a government ID and, for
   organizations, business documents. This can take a few days.

**Plan your timeline around this:** new *personal* developer accounts must run a
closed test with **at least 12 testers, opted in continuously for 14 days**,
before Google will let them publish to production. So if you are on a personal
account, start your closed test roughly three weeks before you want to launch.
Organization accounts are exempt.

Then:

```bash
cd ~/brightfuture/mobile
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-api-url/api
```

Upload `build/app/outputs/bundle/release/app-release.aab`.

---

## 7. ClickPesa — mobile money payments

Course fees are collected by **ClickPesa USSD push**: the student types their
mobile money number, gets a PIN prompt on their handset, and the app polls until
the payment settles. M-Pesa, Tigo Pesa, Airtel Money and Halopesa all work
through it. No cards, no Stripe, and no public callback URL — the status
endpoint is the source of truth.

**The credentials live on the server only.** The app never holds a ClickPesa
credential; it calls your own `/api/payments/*` endpoints, and the backend reads
the course price from the database rather than trusting the app. That means a
modified client cannot choose what it pays.

1. From the ClickPesa dashboard, copy your **client id** and **api key**.
2. Put them in a gitignored file on the server side:
   ```bash
   # backend/.env.local — never commit this
   CLICKPESA_CLIENT_ID=your_client_id
   CLICKPESA_API_KEY=your_api_key
   ```
3. Start the backend with them loaded:
   ```bash
   set -a; source backend/.env.local; set +a
   mvn spring-boot:run -f backend/pom.xml
   ```

`application.yml` reads `${CLICKPESA_CLIENT_ID:}` and `${CLICKPESA_API_KEY:}`,
so the app still builds and runs with no credentials at all — the payment
endpoints simply answer "not switched on yet" and checkout falls back to
"reserve my place, pay at the hub".

**The three ClickPesa calls**, all in `ClickPesaService.java`:

| Call | What it does |
|---|---|
| `POST /third-parties/generate-token` | Swaps client id + api key for a bearer token |
| `POST /third-parties/payments/initiate-ussd-push-request` | Sends the PIN prompt. Money has **not** moved yet |
| `GET /third-parties/payments/{orderReference}` | The authoritative status. Never enrol on anything else |

**Phone numbers** are normalised to `255XXXXXXXXX` on both sides —
`Validators.normalizeTzMobile` in the app, `ClickPesaService.normalizeTzPhone`
on the server. Only 06x and 07x mobile prefixes are accepted, so a landline or a
typo is caught before it costs a round trip.

**What you need to supply:** the client id and api key in `backend/.env.local`.
Nothing goes into the app build, and there is no `--dart-define` for payments.

> **iOS behaves differently, on purpose.** Apple requires in-app purchase for
> *digital* content bought inside an iOS app, whatever gateway you use. So on
> iOS the app reserves a place free of charge and points the student at the
> website to pay; Android takes the payment in-app. The switch is
> `PaymentService.canPayInApp`.
>
> A course taught **in person at the hub** is a physical service and could be
> charged for on iOS too. If that is your case you can flip that getter — but
> check with App Review before you ship it.

> **Live keys move real money.** ClickPesa has no test mode in the way Stripe
> does. The first successful USSD push debits a real wallet, so do your first
> run with a small-priced course and a number you control.

---

## Quick reference — every build flag

| Flag | Required? | Example |
|---|---|---|
| `API_BASE_URL` | Yes for release | `https://api.brightfuture.best/api` |

Payments need no build flag — ClickPesa is configured on the server, in
`backend/.env.local`.

Rather than retyping them, keep them in a gitignored file:

```json
// mobile/env.release.json
{
  "API_BASE_URL": "https://api.brightfuture.best/api"
}
```

```bash
flutter build appbundle --release --dart-define-from-file=env.release.json
```
