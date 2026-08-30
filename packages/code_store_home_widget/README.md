# `code_store_home_widget`

Modular Home Screen Widget engine for iOS (WidgetKit) and Android (Glance / AppWidgets) with payload synchronization, offscreen snapshot rendering, and deep-link routing.

---

## 📱 Required Permissions & Native Setup

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)

Register your widget receivers inside `<application>`:

```xml
<receiver
    android:name=".HomeWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/home_widget_info" />
</receiver>
```

---

### 🍎 iOS (`ios/Runner/Runner.entitlements` & Widget Extension)

1. **App Groups Capability**:
   * In Xcode, select `Runner` target → **Signing & Capabilities** → Click `+ Capability` → Add **App Groups**.
   * Check or add your App Group ID (e.g. `group.com.example.app`).
   * Add the exact same **App Groups** capability to your Widget Extension target (`<WidgetName>Extension`).

---

## 🚀 Quick Start
```dart
// Initialize in DI
await getIt<HomeWidgetService>().initialize(
  appGroupId: 'group.com.example.app',
  defaultAndroidName: 'HomeWidgetProvider',
  defaultIOSName: 'HomeWidgetProvider',
);

// Sync payload from Flutter
await getIt<HomeWidgetService>().syncPayload(
  HomeWidgetPayload(title: 'Title', message: 'Message'),
);
```
