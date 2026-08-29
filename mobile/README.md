# Bright Future - Mobile App

The Flutter app for **Bright Future Digital Hub**. It talks to the same
Spring Boot REST API as the Next.js website, so courses, bookings, print orders
and admin actions stay in sync across web and mobile.

The website under `frontend/` and the API under `backend/` are **unchanged** -
this folder is entirely additive.

---

## First run (five minutes)

```bash
# 1. Install Flutter if you have not already
#    https://docs.flutter.dev/get-started/install/macos
#    Then check everything is wired up:
flutter doctor

# 2. Set up the project (generates android/ and ios/, applies config, installs packages)
cd mobile
./setup.sh

# 3. Start the backend in another terminal, from the repo root
npm run dev:backend

# 4. Run the app
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api    # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api   # iOS simulator
```

Sign in with the seeded accounts from the root `README.md`:

* Student - `student@brightfuture.best.com` / `Student@123!`
* Admin - `admin@brightfuture.best.com` / `Admin@BrightFuture2026!`
  (or use the *Administrator sign in* link at the bottom of the login screen)

> **`10.0.2.2` is not a typo.** It is the special address an Android emulator
> uses to reach your computer. On a real phone use your laptop's wifi address
> (`ipconfig getifaddr en0` on macOS) and make sure both are on the same network.

Next: **`SETUP_KEYS.md`** lists every key and file you still need for push
notifications, payments and release builds.

---

## What is in the app

### For students

| Screen | What it does |
|---|---|
| Onboarding | Three-slide intro, shown once |
| Sign up / Sign in | JWT auth against `/api/auth/*`, saved in the device keychain |
| Home | Greeting, quick actions, continue-learning carousel, next booking, active print job |
| Courses | Search, category filters, grid of course cards |
| Course detail | Full description, enrol, progress slider that writes back to the API |
| My courses | In-progress and completed tabs with progress bars |
| Computer lab | Book a workstation (type, date, time, duration, notes); cancel bookings |
| Printing | Submit a print order with a **live price estimate**, attach a file, track status |
| Ecosystem | All nine Bright Future modules, mirrored from the website |
| Notifications | In-app inbox of everything that has happened |
| Profile | Stats, all your lists, sign out |
| Settings | Light/dark/system theme, biometric app lock, notification toggle, clear offline data |
| Contact | Call, email, or send a message straight into the admin inbox |

### For administrators

| Screen | What it does |
|---|---|
| Dashboard | Live counts of users, courses, bookings, orders, messages |
| Users & roles | Search everyone, promote to instructor |
| Course catalogue | Create, edit, publish/unpublish and delete courses |
| Lab bookings | Filter by status, confirm/complete/cancel any booking |
| Print orders | Filter by status, move orders through the queue |
| Messages | Read contact enquiries and reply by email |

### Beyond the website

* **Offline mode** - courses, enrolments, bookings and orders are cached, so the
  app opens and shows your data with no connection. A banner tells you when you
  are looking at saved data.
* **Biometric app lock** - Face ID / fingerprint gate on a saved session.
* **Push notifications** - Firebase Cloud Messaging, plus local alerts and an
  in-app inbox.
* **Mobile money payments** - ClickPesa USSD push for paid courses, so the
  student approves with their M-Pesa / Tigo Pesa / Airtel PIN. On iOS enrolment
  is free in the app and the fee is settled on the website, as Apple requires.
* **File attachments** - attach the actual document to a print order.
* **Dark mode** throughout.
* **Live price estimates** - the printing calculator mirrors the backend's
  pricing formula exactly, so the number you see is the number you are charged.

---

## Project layout

```
mobile/
├── lib/
│   ├── main.dart               # wiring: services, repositories, providers
│   ├── app.dart                # MaterialApp, routes, auth gate
│   ├── routes.dart             # every named route in one place
│   ├── core/
│   │   ├── config/             # AppConfig - all build-time settings
│   │   ├── network/            # ApiClient (JWT, envelopes, error mapping)
│   │   ├── storage/            # keychain, prefs, offline cache
│   │   ├── services/           # notifications, biometrics, payments, connectivity
│   │   ├── theme/              # colours + themes from the web DESIGN.md
│   │   └── utils/              # formatters, validators
│   ├── data/
│   │   ├── models/             # one class per backend DTO
│   │   └── repositories/       # one class per API area
│   ├── providers/              # ChangeNotifier state, one per feature
│   └── ui/
│       ├── widgets/            # the shared component set
│       └── screens/            # one folder per feature area
├── backend-addons/             # optional Java files for payments + uploads
├── tool/enable-firebase.sh     # switches on Android push once you have the config file
├── setup.sh                    # one-time native project setup
└── SETUP_KEYS.md               # every key you need to supply
```

**If you are new to Flutter, read the files in this order:**
`main.dart` → `app.dart` → `providers/auth_provider.dart` →
`core/network/api_client.dart` → `ui/screens/courses/courses_screen.dart`.
That path covers the whole architecture in about 600 lines.

### How a screen gets its data

```
Screen  →  context.watch<CourseProvider>()   (rebuilds when data changes)
             ↓
        CourseProvider                        (loading / error / cache state)
             ↓
        CourseRepository                      (knows the endpoints)
             ↓
        ApiClient                             (adds the JWT, unwraps the envelope)
             ↓
        Spring Boot  /api/courses
```

Every provider exposes `loading`, `refreshing`, `error` and `fromCache`, so
screens can show a skeleton, an error with retry, or an offline banner without
repeating themselves.

---

## Common commands

```bash
flutter run                       # debug, hot reload with r
flutter run --release             # release performance on a device
flutter analyze                   # static analysis - run this before committing
flutter test                      # unit and widget tests
flutter clean && flutter pub get  # when the build behaves oddly

flutter build apk --release       # single APK, for sideloading and testing
flutter build appbundle --release # what you upload to Google Play
flutter build ipa --release       # what you upload to App Store Connect
```

Always pass your `--dart-define` flags on release builds - see `SETUP_KEYS.md`.

---

## Troubleshooting

**"Cannot reach the Bright Future server"**
The backend is not running, or `API_BASE_URL` is wrong. On the Android emulator
it must be `10.0.2.2`, never `localhost`.

**Dependency resolution fails after `flutter pub get`**
Your Flutter version may be newer than the pinned packages. Run:
```bash
flutter pub upgrade --major-versions
```
then `flutter analyze` and fix anything it flags.

**Android build fails mentioning `google-services.json`**
You ran `tool/enable-firebase.sh` without the file in place. Either add the file
or revert the plugin lines it added in `android/settings.gradle(.kts)` and
`android/app/build.gradle(.kts)`.

**iOS build fails on CocoaPods**
```bash
cd ios && pod repo update && pod install && cd ..
```

**Biometric lock never appears**
The device needs a fingerprint, face or passcode enrolled. Settings shows the
toggle greyed out with an explanation when it does not.

---

## Shipping checklist

- [ ] `flutter analyze` is clean
- [ ] `flutter test` passes
- [ ] `API_BASE_URL` points at your production HTTPS server
- [ ] `usesCleartextTraffic` removed from the Android manifest
- [ ] App icon and splash regenerated from a 1024x1024 logo
- [ ] Version bumped in `pubspec.yaml` (`version: 1.0.0+1` → `1.0.1+2`)
- [ ] Android: `key.properties` filled in, `flutter build appbundle --release` succeeds
- [ ] iOS: signing team selected in Xcode, `flutter build ipa --release` succeeds
- [ ] Privacy policy and terms live at the URLs in `AppConfig`
- [ ] Store listing: screenshots, description, category (Education), content rating
- [ ] Tested on a real phone on mobile data, not just wifi
