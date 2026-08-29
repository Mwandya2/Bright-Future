#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Bright Future mobile - one-time project setup.
#
#   cd mobile && ./setup.sh
#
# What it does:
#   1. Generates the native android/ and ios/ folders (via `flutter create` in a
#      throwaway directory, so nothing you see here is ever overwritten).
#   2. Applies the Bright Future app identity, permissions and build settings.
#   3. Installs packages and generates launcher icons + splash screens.
#
# Safe to re-run. Existing android/ and ios/ folders are left alone unless you
# pass --force-native.
# ---------------------------------------------------------------------------
set -euo pipefail

APP_ID="com.brightfuture.app"
APP_LABEL="Bright Future"
ORG="com.brightfuture"
PROJECT_NAME="bright_future_mobile"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

blue()  { printf '\033[34m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
warn()  { printf '\033[33m! %s\033[0m\n' "$*"; }
die()   { printf '\033[31mx %s\033[0m\n' "$*" >&2; exit 1; }

FORCE_NATIVE=0
for arg in "$@"; do
  [ "$arg" = "--force-native" ] && FORCE_NATIVE=1
done

# ── 0. Prerequisites ───────────────────────────────────────────
command -v flutter >/dev/null 2>&1 || die "Flutter is not on your PATH. Install it first: https://docs.flutter.dev/get-started/install"
blue "Flutter found: $(flutter --version | head -1)"

# ── 1. Native scaffolding ──────────────────────────────────────
if [ "$FORCE_NATIVE" = "1" ]; then
  rm -rf android ios
fi

if [ ! -d android ] || [ ! -d ios ]; then
  blue "Generating native android/ and ios/ projects..."
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  flutter create \
    --org "$ORG" \
    --project-name "$PROJECT_NAME" \
    --platforms=android,ios \
    --no-pub \
    "$TMP/scaffold" >/dev/null
  [ -d android ] || cp -R "$TMP/scaffold/android" ./android
  [ -d ios ] || cp -R "$TMP/scaffold/ios" ./ios
  green "Native projects created."
else
  blue "android/ and ios/ already exist - leaving them in place."
fi

# ── 2. Android: manifest ───────────────────────────────────────
blue "Applying Android configuration..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  cat > "$MANIFEST" <<'MANIFESTEOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Networking -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Push notifications (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Biometric app lock -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />

    <!-- Attaching files to print orders -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />

    <application
        android:label="Bright Future"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Deep links: https://brightfuture.best/... -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https" android:host="brightfuture.best" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />

        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="bright_future_default" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT" />
            <data android:mimeType="text/plain" />
        </intent>
        <!-- url_launcher: opening links, mail and phone apps -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="mailto" />
        </intent>
        <intent>
            <action android:name="android.intent.action.DIAL" />
            <data android:scheme="tel" />
        </intent>
    </queries>
</manifest>
MANIFESTEOF
  green "  AndroidManifest.xml written."
fi

# ── 3. Android: MainActivity must be a FragmentActivity ────────
# Both local_auth (biometrics) and flutter_stripe require it.
MAIN_KT="$(find android/app/src/main/kotlin -name 'MainActivity.kt' 2>/dev/null | head -1 || true)"
if [ -n "$MAIN_KT" ]; then
  python3 - "$MAIN_KT" <<'PYEOF'
import sys, re
p = sys.argv[1]
s = open(p).read()
s = s.replace('io.flutter.embedding.android.FlutterActivity',
              'io.flutter.embedding.android.FlutterFragmentActivity')
s = re.sub(r'class\s+MainActivity\s*:\s*FlutterActivity\(\)',
           'class MainActivity : FlutterFragmentActivity()', s)
open(p, 'w').write(s)
PYEOF
  green "  MainActivity now extends FlutterFragmentActivity."
fi

# ── 4. Android: theme parent (required by flutter_stripe) ──────
for STYLES in android/app/src/main/res/values/styles.xml android/app/src/main/res/values-night/styles.xml; do
  if [ -f "$STYLES" ]; then
    python3 - "$STYLES" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace('android:Theme.Light.NoTitleBar', 'Theme.MaterialComponents.Light.NoActionBar')
s = s.replace('android:Theme.Black.NoTitleBar', 'Theme.MaterialComponents.NoActionBar')
open(p, 'w').write(s)
PYEOF
  fi
done
green "  Android themes set to MaterialComponents."

# ── 5. Android: min SDK, app id and release signing ────────────
GRADLE=""
[ -f android/app/build.gradle.kts ] && GRADLE=android/app/build.gradle.kts
[ -f android/app/build.gradle ] && GRADLE=android/app/build.gradle

if [ -n "$GRADLE" ]; then
  python3 - "$GRADLE" "$APP_ID" <<'PYEOF'
import sys, re
path, app_id = sys.argv[1], sys.argv[2]
s = open(path).read()
kts = path.endswith('.kts')

# 1. application id
s = re.sub(r'applicationId\s*=\s*"[^"]*"', f'applicationId = "{app_id}"', s)
s = re.sub(r'applicationId\s+"[^"]*"', f'applicationId "{app_id}"', s)

# 2. minSdk 23 (flutter_stripe and encrypted secure storage both need >= 21;
#    23 keeps biometric prompt behaviour consistent)
s = re.sub(r'minSdk\s*=\s*[^\n]+', 'minSdk = 23', s)
s = re.sub(r'minSdkVersion\s+[^\n]+', 'minSdkVersion 23', s)

# 3. core library desugaring - flutter_local_notifications requires it
if 'isCoreLibraryDesugaringEnabled' not in s:
    s = re.sub(r'(compileOptions\s*\{)',
               r'\1\n        isCoreLibraryDesugaringEnabled = true',
               s, count=1)
    if kts:
        s = s.rstrip() + '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    else:
        s = s.rstrip() + "\n\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"

# 4. multidex + release signing wired to key.properties when present
if 'BRIGHT_FUTURE_SIGNING' not in s:
    if kts:
        header = '''import java.util.Properties
import java.io.FileInputStream

// BRIGHT_FUTURE_SIGNING - release keystore, read from android/key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

'''
        signing = '''
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }
'''
        s = header + s
        # insert signingConfigs before buildTypes
        s = s.replace('    buildTypes {', signing + '\n    buildTypes {', 1)
        s = re.sub(r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
                   'signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
                   s)
    else:
        header = '''def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
// BRIGHT_FUTURE_SIGNING

'''
        signing = '''
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }
'''
        s = header + s
        s = s.replace('    buildTypes {', signing + '\n    buildTypes {', 1)
        s = re.sub(r'signingConfig\s+signingConfigs\.debug',
                   "signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug",
                   s)

open(path, 'w').write(s)
print(f'  patched {path}')
PYEOF
else
  warn "Could not find android/app/build.gradle(.kts) - set the app id and minSdk by hand."
fi

# ── 5b. R8 / ProGuard keep rules ────────────────────────────────
# R8 fails the release build on references to Stripe's optional push
# provisioning module. These rules suppress that and protect the plugins that
# rely on reflection.
if [ -d android/app ] && [ ! -f android/app/proguard-rules.pro ]; then
  cat > android/app/proguard-rules.pro <<'PROGUARDEOF'
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.dexterous.** { *; }
-keep class com.google.firebase.** { *; }
-keep class androidx.biometric.** { *; }
PROGUARDEOF
  green "  android/app/proguard-rules.pro created."
fi

if [ -n "$GRADLE" ] && ! grep -q 'proguard-rules.pro' "$GRADLE"; then
  python3 - "$GRADLE" <<'PYEOF'
import sys, re
path = sys.argv[1]
s = open(path).read()
kts = path.endswith('.kts')
if kts:
    rules = ('\n            proguardFiles(\n'
             '                getDefaultProguardFile("proguard-android-optimize.txt"),\n'
             '                "proguard-rules.pro",\n'
             '            )')
    s = re.sub(r'(signingConfig = if \(keystorePropertiesFile[^\n]*\n)',
               lambda m: m.group(1).rstrip('\n') + rules + '\n', s, count=1)
else:
    rules = ("\n            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), "
             "'proguard-rules.pro'")
    s = re.sub(r'(signingConfig keystorePropertiesFile[^\n]*\n)',
               lambda m: m.group(1).rstrip('\n') + rules + '\n', s, count=1)
open(path, 'w').write(s)
print('  release build wired to proguard-rules.pro')
PYEOF
fi

# key.properties template
if [ ! -f android/key.properties.example ]; then
  cat > android/key.properties.example <<'KEYEOF'
# Copy to android/key.properties and fill in before building a release bundle.
# NEVER commit key.properties or the .jks file - both are already gitignored.
#
# Create the keystore first:
#   keytool -genkey -v -keystore ~/bright-future-upload.jks \
#     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
storePassword=CHANGE_ME
keyPassword=CHANGE_ME
keyAlias=upload
storeFile=/Users/you/bright-future-upload.jks
KEYEOF
  green "  android/key.properties.example created."
fi

# ── 6. iOS: bundle id, deployment target and usage strings ─────
blue "Applying iOS configuration..."
PBX="ios/Runner.xcodeproj/project.pbxproj"
if [ -f "$PBX" ]; then
  python3 - "$PBX" "$APP_ID" <<'PYEOF'
import sys, re
path, app_id = sys.argv[1], sys.argv[2]
s = open(path).read()
s = re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;',
           f'PRODUCT_BUNDLE_IDENTIFIER = {app_id};', s)
# RunnerTests keeps its own suffix
s = s.replace(f'PRODUCT_BUNDLE_IDENTIFIER = {app_id};\n\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n\t\t\t\tTEST_HOST',
              f'PRODUCT_BUNDLE_IDENTIFIER = {app_id}.RunnerTests;\n\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n\t\t\t\tTEST_HOST')
s = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;',
           'IPHONEOS_DEPLOYMENT_TARGET = 14.0;', s)
open(path, 'w').write(s)
print('  bundle id and deployment target set.')
PYEOF
fi

PLIST="ios/Runner/Info.plist"
if [ -f "$PLIST" ] && command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  set_plist() {
    /usr/libexec/PlistBuddy -c "Delete :$1" "$PLIST" >/dev/null 2>&1 || true
    /usr/libexec/PlistBuddy -c "Add :$1 $2 $3" "$PLIST" >/dev/null 2>&1 || true
  }
  set_plist "CFBundleDisplayName" "string" "$APP_LABEL"
  set_plist "NSFaceIDUsageDescription" "string" "Bright Future uses Face ID to unlock your account on this device."
  set_plist "NSCameraUsageDescription" "string" "Take a photo to attach to a print order."
  set_plist "NSPhotoLibraryUsageDescription" "string" "Choose a document or photo to attach to a print order."
  set_plist "NSPhotoLibraryAddUsageDescription" "string" "Save receipts and course certificates to your photos."
  /usr/libexec/PlistBuddy -c "Delete :UIBackgroundModes" "$PLIST" >/dev/null 2>&1 || true
  /usr/libexec/PlistBuddy -c "Add :UIBackgroundModes array" "$PLIST" >/dev/null 2>&1 || true
  /usr/libexec/PlistBuddy -c "Add :UIBackgroundModes: string remote-notification" "$PLIST" >/dev/null 2>&1 || true
  green "  Info.plist usage strings and push background mode set."
else
  warn "PlistBuddy not available - add the NSFaceIDUsageDescription / camera / photo keys to ios/Runner/Info.plist by hand."
fi

PODFILE="ios/Podfile"
if [ -f "$PODFILE" ]; then
  python3 - "$PODFILE" <<'PYEOF'
import sys, re
p = sys.argv[1]
s = open(p).read()
if "platform :ios" in s:
    s = re.sub(r"#?\s*platform :ios, '[0-9.]+'", "platform :ios, '14.0'", s, count=1)
else:
    s = "platform :ios, '14.0'\n" + s
open(p, 'w').write(s)
PYEOF
  green "  Podfile platform set to iOS 14."
fi

# ── 7. Packages, icons, splash ─────────────────────────────────
blue "Fetching packages..."
flutter pub get

blue "Generating launcher icons..."
dart run flutter_launcher_icons >/dev/null 2>&1 && green "  Icons generated." || warn "  Icon generation skipped (run 'dart run flutter_launcher_icons' to see why)."

blue "Generating native splash screens..."
dart run flutter_native_splash:create >/dev/null 2>&1 && green "  Splash screens generated." || warn "  Splash generation skipped (run 'dart run flutter_native_splash:create' to see why)."

echo
green "Setup complete."
echo
cat <<'NEXTEOF'
Next steps
----------
  1. Start your Spring Boot backend:   npm run dev:backend   (from the repo root)
  2. Run the app:

       flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api      # Android emulator
       flutter run --dart-define=API_BASE_URL=http://localhost:8080/api     # iOS simulator

     On a physical phone use your computer's LAN address, e.g.
       flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080/api

  3. See SETUP_KEYS.md for the keys and files you still need to add
     (Firebase push, Stripe payments, release signing).
NEXTEOF
