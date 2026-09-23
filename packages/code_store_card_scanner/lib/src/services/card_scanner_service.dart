import 'dart:io';

import 'package:card_scanner/card_scanner.dart' as plugin;
import 'package:flutter/foundation.dart';

import '../models/card_details.dart';
import '../models/card_scan_result.dart';
import '../models/card_type.dart';
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
  Future<CardScanResult> scanCard({
    bool mockFallbackIfUnavailable = false,
  }) async {
    if (kIsWeb) {
      if (mockFallbackIfUnavailable) {
        return CardScanResult.success(_generateMockCard());
      }
      return const CardScanResult.failure(
        'Card scanning is not supported on web.',
      );
    }

    try {
      final pluginDetails = await plugin.CardScanner.scanCard(
        scanOptions: const plugin.CardScanOptions(
          scanCardHolderName: true,
          scanExpiryDate: true,
          enableLuhnCheck: true,
        ),
      );

      if (pluginDetails == null) {
        return const CardScanResult.cancelled();
      }

      final rawNumber = pluginDetails.cardNumber.replaceAll(' ', '');
      final type = detectCardType(rawNumber);
      final isValid = validateCardNumber(rawNumber);

      int? expiryMonth;
      int? expiryYear;

      final expiryString = pluginDetails.expiryDate;
      if (expiryString.isNotEmpty) {
        final parts = expiryString.split(RegExp(r'[/.-]'));
        if (parts.isNotEmpty) {
          expiryMonth = int.tryParse(parts[0].trim());
        }
        if (parts.length > 1) {
          expiryYear = int.tryParse(parts[1].trim());
        }
      }

      final domainDetails = CardDetails(
        cardNumber: rawNumber,
        cardHolderName: pluginDetails.cardHolderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cardType: type,
        isValidNumber: isValid,
      );

      return CardScanResult.success(domainDetails);
    } catch (e) {
      debugPrint('CardScannerService: scan failed: $e');

      // Fallback for simulators or environments where camera hardware throws
      if (mockFallbackIfUnavailable) {
        return CardScanResult.success(_generateMockCard());
      }

      return CardScanResult.failure(e.toString());
    }
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

  CardDetails _generateMockCard() {
    return const CardDetails(
      cardNumber: '4532015112830366',
      cardHolderName: 'ALEX MORGAN',
      expiryMonth: 12,
      expiryYear: 28,
      cvv: '842',
      cardType: CardType.visa,
      isValidNumber: true,
    );
  }
}
