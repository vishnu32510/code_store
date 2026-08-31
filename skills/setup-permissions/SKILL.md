---
name: setup-permissions
description: Configures native camera, photo library, location, microphone, bluetooth, and IDFA tracking permissions across AndroidManifest.xml, Info.plist, and DI.
---

# Setup Permissions Skill

This skill configures native OS permission declarations across iOS (`Info.plist`), Android (`AndroidManifest.xml`), Dependency Injection, and UI routing for `code_store_permissions`.

## Instructions for the Agent

When triggered, execute the following steps:

1. **Update iOS `Info.plist`**:
   - View `ios/Runner/Info.plist`.
   - Ensure the following privacy usage descriptions are present inside `<dict>`:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>Camera access is required to take photos, scan codes, or use flashlight tools.</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Photo library access is required to select, preview, and save photos within the app.</string>
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>Photo library access is required to download and save images to your device gallery.</string>
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>Location access is required to deliver localized features and services.</string>
     <key>NSMicrophoneUsageDescription</key>
     <string>Microphone access is required to record audio and voice messages.</string>
     <key>NSBluetoothAlwaysUsageDescription</key>
     <string>Bluetooth access is required to discover and connect with nearby devices.</string>
     <key>NSUserTrackingUsageDescription</key>
     <string>Tracking permission helps provide a more personalized app experience.</string>
     ```

2. **Update Android `AndroidManifest.xml`**:
   - View `android/app/src/main/AndroidManifest.xml`.
   - Ensure the following permissions are present inside `<manifest>`:
     ```xml
     <uses-permission android:name="android.permission.CAMERA" />
     <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
     <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
     <uses-permission android:name="android.permission.RECORD_AUDIO" />
     <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
     <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
     ```

3. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupPermissionsDI()` is called inside `setupDI()`.

4. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_permissions` is declared under `dependencies:`.

5. **Verify UI & Routing Integration**:
   - Route `AppRoutes.permissions = '/permissions'` points to `PermissionsScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

6. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` to confirm zero errors.
