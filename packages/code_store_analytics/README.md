# `code_store_analytics`

Modular Firebase Analytics package with DI registration (`setupAnalyticsDI()`), `IAnalyticsService` interface, `FirebaseAnalyticsObserver` for GoRouter / Navigator screen tracking, and standard event helpers.

---

## 📱 Required Permissions & Native Setup

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Required to send analytics telemetry -->
<uses-permission android:name="android.permission.INTERNET" />
```

---

### 🍎 iOS (`ios/Runner/Info.plist`)
* Standard Firebase analytics does not require additional plist entries unless implementing IDFA (AdSupport) tracking via App Tracking Transparency (`NSUserTrackingUsageDescription`).

---

## 🚀 Quick Start
```dart
// DI registration
setupAnalyticsDI();

// Log events from anywhere
getIt<IAnalyticsService>().logEvent(
  name: 'purchase_success',
  parameters: {'item_id': 'sku_123', 'price': 9.99},
);
```
