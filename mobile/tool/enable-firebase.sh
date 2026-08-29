#!/usr/bin/env bash
# Turns on the Google Services Gradle plugin for Android push notifications.
#
# Run this AFTER you have placed google-services.json at
#   mobile/android/app/google-services.json
#
# Adding the plugin before that file exists makes the Android build fail, which
# is why it is not enabled by default.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$HERE"

if [ ! -f android/app/google-services.json ]; then
  echo "x android/app/google-services.json is missing."
  echo "  Download it from the Firebase console first - see SETUP_KEYS.md section 2."
  exit 1
fi

python3 - <<'PYEOF'
import os, re

def patch(path, transform):
    if not os.path.exists(path):
        return False
    s = open(path).read()
    new = transform(s)
    if new != s:
        open(path, 'w').write(new)
        print(f'  patched {path}')
    else:
        print(f'  {path} already configured')
    return True

# --- Kotlin DSL -----------------------------------------------------------
def settings_kts(s):
    if 'com.google.gms.google-services' in s:
        return s
    return re.sub(r'(id\("dev\.flutter\.flutter-gradle-plugin"\))',
                  'id("com.google.gms.google-services") version "4.4.2" apply false\n    \\1',
                  s, count=1)

def app_kts(s):
    if 'com.google.gms.google-services' in s:
        return s
    return re.sub(r'(id\("dev\.flutter\.flutter-gradle-plugin"\))',
                  '\\1\n    id("com.google.gms.google-services")',
                  s, count=1)

# --- Groovy DSL -----------------------------------------------------------
def settings_groovy(s):
    if 'com.google.gms.google-services' in s:
        return s
    return re.sub(r"(id \"dev\.flutter\.flutter-gradle-plugin\")",
                  "id \"com.google.gms.google-services\" version \"4.4.2\" apply false\n    \\1",
                  s, count=1)

def app_groovy(s):
    if 'com.google.gms.google-services' in s:
        return s
    if 'apply plugin:' in s:
        return s.replace("apply plugin: 'com.android.application'",
                         "apply plugin: 'com.android.application'\napply plugin: 'com.google.gms.google-services'", 1)
    return re.sub(r"(id \"dev\.flutter\.flutter-gradle-plugin\")",
                  "\\1\n    id \"com.google.gms.google-services\"",
                  s, count=1)

patch('android/settings.gradle.kts', settings_kts)
patch('android/settings.gradle', settings_groovy)
patch('android/app/build.gradle.kts', app_kts)
patch('android/app/build.gradle', app_groovy)
PYEOF

echo
echo "Done. Now run:  flutter clean && flutter run"
echo "If Gradle complains about the plugin version, bump 4.4.2 to the latest"
echo "google-services version in android/settings.gradle(.kts)."
