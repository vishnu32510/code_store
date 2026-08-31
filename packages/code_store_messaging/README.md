# `code_store_messaging`

Modular Firebase Cloud Messaging (FCM) & local notification package with Dependency Injection (`setupMessagingDI()`), foreground presentation banners, scheduled & recurring alerts, rich media big picture support, actionable quick reply buttons, badge counts, and Android notification grouping.

---

## 📱 Required Permissions & Native Setup

When importing `code_store_messaging` into any Flutter project, configure the following native files:

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)

Add these permissions inside `<manifest>`:

```xml
<!-- Network for FCM -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Required for persisting scheduled notifications across device restart -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Notification vibration -->
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Required on Android 13+ (API 33+) to show notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Required on Android 12+ (API 31+) for exact scheduled alarms -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

---

### 🍎 iOS (`ios/Runner/Info.plist` & `ios/Runner/AppDelegate.swift`)

#### 1. `ios/Runner/Info.plist`
Enable background modes for remote notifications & background fetch:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### 2. `ios/Runner/AppDelegate.swift`
Ensure `UNUserNotificationCenter` delegate is registered so foreground notifications and scheduling fire reliably:

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

### 🌐 Web (`web/firebase-messaging-sw.js`)

For Web Push Notifications to work in the background when the tab is closed, ensure `web/firebase-messaging-sw.js` is present in your web root with your Web Firebase config:

```javascript
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSy...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
  measurementId: "..."
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((payload) => {
  const title = (payload.notification && payload.notification.title) || 'Notification';
  const options = {
    body: (payload.notification && payload.notification.body) || '',
    icon: '/icons/Icon-192.png',
    data: payload.data,
  };
  self.registration.showNotification(title, options);
});
```

---

## 🚀 Quick Start & DI Integration

### 1. Register in DI
```dart
import 'package:code_store_messaging/code_store_messaging.dart';

Future<void> setupDI() async {
  setupMessagingDI();
  await getIt<IMessagingService>().initialize();
}
```

### 2. Request Permissions & Token
```dart
final messaging = getIt<IMessagingService>();

// Request permissions on iOS and Android 13+
final settings = await messaging.requestPermission();

// Retrieve device token
final token = await messaging.getToken();

// Subscribe to topics
await messaging.subscribeToTopic('general_updates');
```

### 3. Schedule Local Notification
```dart
await messaging.scheduleNotification(
  id: 1,
  title: 'Reminder',
  body: 'Daily check-in time!',
  scheduledDate: DateTime.now().add(const Duration(hours: 2)),
);
```
