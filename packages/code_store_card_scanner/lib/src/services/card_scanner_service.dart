import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/card_details.dart';
import '../models/card_scan_result.dart';
import '../models/card_type.dart';
import '../utils/card_ocr_parser.dart';
import '../utils/card_validator.dart';
import 'i_card_scanner_service.dart';

/// Concrete card scanner service leveraging the device camera and offline OCR,
/// with support for real-time regex brand detection and Luhn checksum validation.
class CardScannerService implements ICardScannerService {
  const CardScannerService();

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    // card_scanner supports Android and iOS devices with camera
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Future<CardScanResult> scanCard() async {
    if (kIsWeb) {
      return const CardScanResult.failure(
        'Card scanning is not supported on web.',
      );
    }
    return const CardScanResult.failure(
      'Live camera scanning is UI-driven via EmbeddedCardCamera or CardCameraOverlayScanner.',
    );
  }

  @override
  CardDetails parseOcrLines(List<String> lines) {
    return CardOcrParser.parseRecognizedLines(lines);
  }

  @override
  CardType detectCardType(String cardNumber) {
    return CardValidator.detectType(cardNumber);
  }

  @override
  bool validateCardNumber(String cardNumber) {
    return CardValidator.validateLuhn(cardNumber);
  }

  @override
  bool validateExpiryDate(int? month, int? year) {
    return CardValidator.validateExpiry(month, year);
  }

  @override
  bool validateCvv(String cvv, CardType type) {
    return CardValidator.validateCvv(cvv, type);
  }

  @override
  String formatCardNumber(String cardNumber) {
    return CardValidator.formatNumber(cardNumber);
  }
}
