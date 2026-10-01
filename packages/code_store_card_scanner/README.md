# code_store_card_scanner

Modular debit and credit card scanning, real-time OCR text recognition, regex brand detection, and interactive 3D card preview for Flutter applications.

---

## Features

- **Zero CocoaPods iOS Architecture**: 100% native Swift Package Manager using Apple's built-in Vision framework (`apple_vision_recognize_text`). Adds **0 MB** ML model bloat, completely eliminating heavy CocoaPods dependencies (~150 MB saved).
- **Lean Google Play Services OCR for Android**: Unbundled Google Play Services ML Kit (`play-services-mlkit-text-recognition`). Uses a lightweight Java bridge (~400 KB) with install-time model pre-downloading to prevent model bloat.
- **Cross-Platform Federated Architecture**: Clean separation between app API, platform interface, and native platform engines (`ios`, `android`).
- **Real-Time Regex Brand Detection**: Instantly detects and displays badges for Visa, Mastercard, American Express, Discover, JCB, Diners Club, UnionPay, Maestro, and Elo.
- **Dynamic Postfix/Suffix Icon**: Visual card brand badge displayed directly inside the Card Number input field.
- **Interactive 3D Card Preview**: Realistic credit card preview that updates dynamically and smoothly flips 180° when CVV is focused.
- **Robust Validation**: Luhn algorithm checksum verification, expiry date validation, and card length checks.
- **Web & Simulator Mock Fallback**: Built-in testing presets and simulated scan fallback for web, desktop, and simulator testing without camera hardware.

---

## Federated Packages

| Package | Role | Key Engine |
| :--- | :--- | :--- |
| **`code_store_card_scanner`** | App-facing API, UI widgets, & 3D preview | Camera stream orchestration |
| **`code_store_card_scanner_platform_interface`** | Common platform contract & models | `CardCameraFrame`, `CardScannerPlatform` |
| **`code_store_card_scanner_ios`** | iOS native implementation | Apple Vision (Swift Package Manager) |
| **`code_store_card_scanner_android`** | Android native implementation | Google Play Services ML Kit (Java) |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  code_store_card_scanner:
    path: packages/code_store_card_scanner
```

---

## Platform Setup

### iOS
Add `NSCameraUsageDescription` to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to scan debit and credit cards.</string>
```

> **Note:** iOS compiles with **0 CocoaPods** using pure Swift Package Manager.

### Android
Add camera permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

*(Optional)* Pre-download the ML Kit OCR model on install from Google Play:
```xml
<application>
  <meta-data
      android:name="com.google.mlkit.vision.DEPENDENCIES"
      android:value="ocr" />
</application>
```

---

## Quick Start

### 1. Register Dependency Injection

```dart
import 'package:code_store_card_scanner/code_store_card_scanner.dart';

void setupDI() {
  setupCardScannerDI();
}
```

### 2. Navigate to `CardScannerScreen`

```dart
final CardDetails? scannedCard = await Navigator.of(context).push<CardDetails>(
  MaterialPageRoute(
    builder: (context) => CardScannerScreen(
      onCardScanned: (card) {
        Navigator.of(context).pop(card);
      },
    ),
  ),
);

if (scannedCard != null) {
  print('Scanned: ${scannedCard.number}, Expiry: ${scannedCard.expiryMonth}/${scannedCard.expiryYear}');
}
```

### 3. Embed Directly in Custom UI (`EmbeddedCardCamera`)

```dart
EmbeddedCardCamera(
  onCardDetected: (CardDetails card) {
    print('Card detected: ${card.number}');
  },
  overlayColor: Colors.black.withOpacity(0.5),
)
```
