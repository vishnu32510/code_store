# 💳 native_card_scanner

[![pub package](https://img.shields.io/pub/v/native_card_scanner.svg)](https://pub.dev/packages/native_card_scanner)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**The only zero-bloat, zero-CocoaPods credit card scanner for Flutter.**

Uses built-in **Apple Vision** on iOS and unbundled **Google Play Services ML Kit** on Android. Scans cards in real-time with zero model bloat, automatic brand detection, and an interactive 3D card preview.

---

## ⚡ Why This Scanner?

| Feature | `native_card_scanner` (This Package) | Typical ML Kit Plugins |
| :--- | :---: | :---: |
| **🍎 iOS App Size Impact** | **0 MB** *(Uses built-in Apple Vision)* | **+135 MB to 150 MB** *(Heavy static C++ binaries)* |
| **🤖 Android App Size Impact** | **~400 KB** *(Play Services thin bridge)* | **+10 MB to 15 MB** *(Bundled models in APK)* |
| **📦 CocoaPods Required?** | ❌ **No (100% Swift Package Manager)** |  Yes (Requires `Podfile` & heavy Pods) |
| **🚀 Scan Latency** | ⚡ **Instant** *(On-device Neural Engine)* | ⏱️ Slower cold starts |
| **💳 Interactive 3D Card** |  Included *(Flips 180° on CVV focus)* | ❌ None (Scanner viewfinder only) |
| **🏷️ Real-Time Brand Icons** |  9 Brands *(Visa, MC, Amex, Discover...)* | ❌ Manual regex required |
| **🌐 Web & Simulator Support** |  Built-in mock test presets | ❌ Crashes without physical camera |

---

## 📸 Showcase

| Live Camera OCR | Interactive 3D Flip | Real-Time Brand Badges |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/vishnu32510/code_store/main/packages/code_store_card_scanner/assets/demo_scan.gif" width="240" alt="Live Scanner Demo"/> | <img src="https://raw.githubusercontent.com/vishnu32510/code_store/main/packages/code_store_card_scanner/assets/demo_card_flip.gif" width="240" alt="3D Card Flip Demo"/> | <img src="https://raw.githubusercontent.com/vishnu32510/code_store/main/packages/code_store_card_scanner/assets/brand_badges.png" width="240" alt="Card Brands"/> |

*(Add your recordings or screenshots to `assets/` to display them here!)*

---

## 🚀 Quick Start (10 Seconds)

### 1. Show the Scanner Modal
```dart
final CardDetails? card = await CardCameraOverlayScanner.show(context);

if (card != null) {
  print('Number: ${card.formattedNumber}'); // "4532 •••• •••• 8892"
  print('Expiry: ${card.formattedExpiry}'); // "08/28"
  print('Brand: ${card.cardType.name}');    // "visa"
}
```

### 2. Or Embed Directly in Your Form
```dart
EmbeddedCardCamera(
  onCardDetected: (CardDetails card) {
    print('Scanned: ${card.cardNumber}');
  },
)
```

---

## 🛠️ Platform Permissions

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to scan payment cards.</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
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
