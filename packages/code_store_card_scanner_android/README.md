# code_store_card_scanner_android

The Android implementation of [`code_store_card_scanner`](../code_store_card_scanner).

## Features
- **Unbundled Google Play Services ML Kit**: Uses `play-services-mlkit-text-recognition`, adding only ~400 KB thin client code and zero embedded model weight.
- **Install-Time Pre-Download**: Pre-downloads the OCR model automatically via Google Play on install.
- **Zero iOS Footprint**: Contains no iOS podspecs or Swift files, preventing accidental CocoaPods re-generation on iOS builds.
