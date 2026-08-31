---
name: setup-biometrics
description: Configures Face ID, Touch ID, and Android BiometricPrompt permissions, MainActivity FlutterFragmentActivity setup, UI routing, and DI registration for biometric authentication.
---

# Setup Biometrics Skill

This skill configures native permissions, Android `FlutterFragmentActivity`, Dependency Injection hooks, and UI navigation for Face ID, Touch ID, and Android `BiometricPrompt` (`code_store_biometrics`).

## Instructions for the Agent

When triggered, you must perform the following steps:

1. **Update iOS `Info.plist`**:
   - View `ios/Runner/Info.plist`.
   - Ensure the `NSFaceIDUsageDescription` string key is present inside `<dict>`:
     ```xml
     <key>NSFaceIDUsageDescription</key>
     <string>Authenticate securely using Face ID or Touch ID.</string>
     ```

2. **Update Android `MainActivity.kt`**:
   - View `android/app/src/main/kotlin/.../MainActivity.kt`.
   - Ensure `MainActivity` extends `FlutterFragmentActivity` (required by Android for `BiometricPrompt` modal bottom sheets):
     ```kotlin
     package com.nungu.codestore

     import io.flutter.embedding.android.FlutterFragmentActivity

     class MainActivity: FlutterFragmentActivity()
     ```

3. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupBiometricsDI()` is called inside `setupDI()`.

4. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_biometrics` is declared under `dependencies:`.

5. **Verify UI & Routing Integration**:
   - Ensure route `AppRoutes.biometrics = '/biometrics'` points to `BiometricsScreen` in `lib/core/config/routes.dart`.
   - Ensure `Biometric Auth` item is present in `lib/features/home/widgets/app_drawer.dart`.
   - Keep `DashboardScreen` clean and untouched (Drawer-only navigation rule).

6. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` to confirm zero syntax or configuration errors.
   - Report to the user that biometric authentication is ready to use.
