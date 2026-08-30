# `code_store_core`

Modular core foundation package containing reusable utility services (`ToastService`, `DownloadService`, `OpenLinkService`, `HttpServices`, `FlashlightControlService`), global navigator keys, and DI bootstrap.

---

## 📱 Required Permissions & Native Setup

Depending on the core services used in your app, configure the following native permissions:

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Network for HttpServices & Downloads -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Flashlight / Torch feature -->
<uses-feature
    android:name="android.hardware.camera"
    android:required="false" />
<uses-permission android:name="android.permission.CAMERA" />

<!-- URL Launcher Package Visibility (<queries>) -->
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="http" />
    </intent>
</queries>
```

---

### 🍎 iOS (`ios/Runner/Info.plist`)

```xml
<!-- Camera / Torch permission -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required for certain app features.</string>

<!-- Gal / Photo Library Save (DownloadService) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Photo library save access is used to download images.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is used to choose and save images.</string>

<!-- URL Schemes (OpenLinkService / url_launcher) -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
</array>
```

---

## 🚀 Quick Start
```dart
// Register core singletons in DI
setupCoreDI(defaultBaseUrl: 'https://api.example.com');

// Display toasts anywhere
getIt<IToastService>().showToast('Operation successful!');
```
