---
name: setup-messaging
description: Configures Firebase Push Notifications & Local Scheduling permissions and native hooks across AndroidManifest.xml, Info.plist, AppDelegate.swift, and DI.
---

# Setup Messaging Skill

This skill configures native permissions, background modes, and application delegate hooks for Firebase Cloud Messaging (FCM) and Scheduled Local Notifications (`code_store_messaging`).

## Instructions for the Agent

When triggered, you must perform the following steps:

1. **Update Android `AndroidManifest.xml`**:
   - View `android/app/src/main/AndroidManifest.xml`.
   - Ensure the following permissions are present inside `<manifest>`:
     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
     <uses-permission android:name="android.permission.VIBRATE" />
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
     <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
     <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
     ```

2. **Update iOS `Info.plist`**:
   - View `ios/Runner/Info.plist`.
   - Ensure `UIBackgroundModes` array is present with `fetch` and `remote-notification`:
     ```xml
     <key>UIBackgroundModes</key>
     <array>
         <string>fetch</string>
         <string>remote-notification</string>
     </array>
     ```

3. **Update iOS `AppDelegate.swift`**:
   - View `ios/Runner/AppDelegate.swift`.
   - Ensure `UNUserNotificationCenter` delegate is assigned in `didFinishLaunchingWithOptions`:
     ```swift
     if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     }
     ```

4. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupMessagingDI()` is called and `getIt<IMessagingService>().initialize(onNavigate: (route) => AppRouter.router.go(route))` is called during asynchronous startup in `setupDI()`.

5. **Completion & Verification**:
   - Run `flutter analyze` to confirm zero syntax or configuration errors.
   - Report to the user that push notifications and scheduled alert configurations are complete.
