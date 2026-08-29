# ---------------------------------------------------------------------------
# R8 / ProGuard rules for the release build.
#
# R8 shrinks and obfuscates the app. It fails when it sees a reference to a
# class that is not on the classpath, even if that code path is never used.
# ---------------------------------------------------------------------------

# Stripe: the SDK references its optional "push provisioning" module (adding a
# card to Google Wallet). We do not use that feature, so the classes are absent.
# These five lines are exactly what the Android Gradle plugin generated in
# build/app/outputs/mapping/release/missing_rules.txt.
-dontwarn com.stripe.android.pushProvisioning.**

# Flutter's engine ships support for Play Store "deferred components" (loading
# parts of the app on demand). We do not use it, so the Play Core library is not
# bundled and R8 sees dangling references.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Keep Stripe's own entry points so the payment sheet still resolves at runtime.
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Flutter engine.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications keeps scheduled notifications across reboots
# via reflection, so its receivers must survive shrinking.
-keep class com.dexterous.** { *; }

# Firebase messaging services are resolved by name from the manifest.
-keep class com.google.firebase.** { *; }

# local_auth uses AndroidX Biometric, which is reflective in places.
-keep class androidx.biometric.** { *; }
