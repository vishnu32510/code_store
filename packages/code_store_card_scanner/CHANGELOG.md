## 1.0.0

* Initial release of `code_store_card_scanner`.
* Federated plugin architecture supporting iOS (Apple Vision via native SPM) and Android (Google Play Services ML Kit).
* Real-time regex card brand detection for Visa, Mastercard, American Express, Discover, JCB, Diners Club, UnionPay, Maestro, and Elo.
* Interactive 3D credit card preview with dynamic flip on CVV focus.
* Embedded camera live OCR streaming widget (`EmbeddedCardCamera`) and full-screen scanner (`CardScannerScreen`).
* Luhn algorithm validation, expiration formatting, and clean dependency injection (`setupCardScannerDI()`).
