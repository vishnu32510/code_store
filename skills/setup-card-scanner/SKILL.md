---
name: setup-card-scanner
description: Configures camera permissions, DI registration, UI routing, and drawer navigation for debit/credit card scanning and regex brand detection.
---

# Setup Card Scanner Skill

This skill configures native camera permissions, Dependency Injection hooks, UI navigation, and drawer entry for credit/debit card scanning and real-time regex brand detection (`code_store_card_scanner`).

## Instructions for the Agent

When triggered, you must perform the following steps:

1. **Update iOS `Info.plist`**:
   - View `ios/Runner/Info.plist`.
   - Ensure the `NSCameraUsageDescription` string key is present inside `<dict>`:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>Camera access is required for scanning debit/credit cards and flashlight control.</string>
     ```

2. **Update Android `AndroidManifest.xml`**:
   - Ensure `<uses-permission android:name="android.permission.CAMERA" />` is declared.
   - Ensure camera hardware is optional (`<uses-feature android:name="android.hardware.camera" android:required="false" />`).

3. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_card_scanner` is declared under `dependencies:`.

4. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupCardScannerDI()` is called inside `setupDI()`.

5. **Verify UI & Routing Integration**:
   - Ensure route `AppRoutes.cardScanner = '/card-scanner'` points to `CardScannerScreen` in `lib/core/config/routes.dart`.
   - Ensure `Card Scanner` item is present in `lib/features/home/widgets/app_drawer.dart`.
   - Keep `DashboardScreen` clean and untouched (Drawer-only navigation rule).

6. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` to confirm zero syntax or configuration errors.
   - Report to the user that card scanning and brand detection are ready to use.
