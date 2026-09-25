import 'package:flutter/services.dart';

import 'card_validator.dart';

/// Reusable string formatting utilities for card numbers and expiration dates.
class CardFormatter {
  CardFormatter._();

  /// Formats raw digits with the appropriate grouping spaces according to the detected brand.
  /// - Visa/Mastercard/Discover: `4-4-4-4`
  /// - American Express: `4-6-5`
  /// - Diners Club: `4-6-4`
  static String formatNumber(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';

    final type = CardValidator.detectType(clean);
    final groupings = type.digitGroupings;
    final buffer = StringBuffer();
    var currentIndex = 0;

    for (final group in groupings) {
      if (currentIndex >= clean.length) break;
      final nextIndex = currentIndex + group;
      if (nextIndex <= clean.length) {
        buffer.write(clean.substring(currentIndex, nextIndex));
        if (nextIndex < clean.length) {
          buffer.write(' ');
        }
        currentIndex = nextIndex;
      } else {
        buffer.write(clean.substring(currentIndex));
        break;
      }
    }

    return buffer.toString();
  }

  /// Formats raw digits into `MM/YY` format.
  static String formatExpiry(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';
    if (clean.length <= 2) return clean;
    return '${clean.substring(0, 2)}/${clean.substring(2, clean.length.clamp(2, 4))}';
  }
}

/// [TextInputFormatter] that formats card numbers with dynamic grouping spaces
/// according to the detected card issuer (e.g. 4-4-4-4 for Visa/Mastercard, 4-6-5 for Amex).
class CardNumberInputFormatter extends TextInputFormatter {
  const CardNumberInputFormatter({this.enforceStandardLength = true});

  /// Whether to clamp the input to the standard maximum length for the detected card type.
  final bool enforceStandardLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    String digitsToFormat = clean;
    if (enforceStandardLength) {
      final type = CardValidator.detectType(clean);
      final maxDigits = type.standardNumberLength;
      if (digitsToFormat.length > maxDigits) {
        digitsToFormat = digitsToFormat.substring(0, maxDigits);
      }
    }

    final formatted = CardFormatter.formatNumber(digitsToFormat);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] that formats expiration dates into `MM/YY` format,
/// automatically inserting the slash after the month digits and capping at 4 digits.
class CardExpiryInputFormatter extends TextInputFormatter {
  const CardExpiryInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Limit to 4 digits: 2 for month, 2 for year
    final digits = clean.length > 4 ? clean.substring(0, 4) : clean;
    final formatted = CardFormatter.formatExpiry(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
