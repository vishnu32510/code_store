import 'package:flutter/services.dart';

import 'card_validator.dart';

/// Reusable string formatting utilities for card numbers and expiration dates.
class CardFormatter {
  CardFormatter._();

  /// Formats raw digits with the appropriate grouping spaces according to the detected brand.
  /// - Visa/Mastercard/Discover: `4-4-4-4`
  /// - American Express: `4-6-5`
  /// - Diners Club: `4-6-4`
  /// - Maestro / UnionPay (up to 19 digits): `4-4-4-4-3`
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
        currentIndex = clean.length;
        break;
      }
    }

    // Preserve any remaining digits beyond predefined groups so up to 19-digit cards
    // are never truncated:
    if (currentIndex < clean.length) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(clean.substring(currentIndex));
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

  /// Formats a card number into a masked presentation (e.g. `•••• •••• •••• 1234`),
  /// respecting brand grouping spaces and preserving the last [visibleEndDigits].
  static String maskNumber(
    String cardNumber, {
    int visibleEndDigits = 4,
    String maskChar = '•',
  }) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';

    final visibleCount = visibleEndDigits.clamp(0, clean.length);
    final maskedCount = clean.length - visibleCount;
    final maskedDigits = StringBuffer();

    for (var i = 0; i < maskedCount; i++) {
      maskedDigits.write(maskChar);
    }
    maskedDigits.write(clean.substring(maskedCount));

    final type = CardValidator.detectType(clean);
    final groupings = type.digitGroupings;
    final buffer = StringBuffer();
    var currentIndex = 0;
    final maskedStr = maskedDigits.toString();

    for (final group in groupings) {
      if (currentIndex >= maskedStr.length) break;
      final nextIndex = currentIndex + group;
      if (nextIndex <= maskedStr.length) {
        buffer.write(maskedStr.substring(currentIndex, nextIndex));
        if (nextIndex < maskedStr.length) {
          buffer.write(' ');
        }
        currentIndex = nextIndex;
      } else {
        buffer.write(maskedStr.substring(currentIndex));
        currentIndex = maskedStr.length;
        break;
      }
    }

    if (currentIndex < maskedStr.length) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(maskedStr.substring(currentIndex));
    }

    return buffer.toString();
  }
}

/// [TextInputFormatter] that formats card numbers with dynamic grouping spaces
/// according to the detected card issuer (e.g. 4-4-4-4 for Visa/Mastercard, 4-6-5 for Amex).
/// Includes smart cursor tracking to preserve cursor location during in-place edits.
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
      final maxDigits = type.maxLength;
      if (digitsToFormat.length > maxDigits) {
        digitsToFormat = digitsToFormat.substring(0, maxDigits);
      }
    }

    final formatted = CardFormatter.formatNumber(digitsToFormat);

    // Smart cursor tracking: count raw digits before the cursor in newValue
    final cursorIndex = newValue.selection.baseOffset;
    final textBeforeCursor =
        cursorIndex >= 0 && cursorIndex <= newValue.text.length
            ? newValue.text.substring(0, cursorIndex)
            : newValue.text;
    final digitsBeforeCursor =
        textBeforeCursor.replaceAll(RegExp(r'\D'), '').length;

    var formattedOffset = 0;
    var digitCount = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (digitCount == digitsBeforeCursor) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      formattedOffset = i + 1;
    }

    // Push cursor forward if landing right before a grouping space:
    if (formattedOffset < formatted.length &&
        formatted[formattedOffset] == ' ') {
      formattedOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formattedOffset.clamp(0, formatted.length),
      ),
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
    var clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Handle backspacing over '/' cleanly:
    if (oldValue.text.endsWith('/') &&
        newValue.text.length < oldValue.text.length) {
      if (clean.isNotEmpty) {
        clean = clean.substring(0, clean.length - 1);
      }
    }

    var autoPrefixed = false;
    // Auto-prefix single digit months 2-9 if typed as the first digit:
    if (clean.length == 1) {
      final firstDigit = int.tryParse(clean);
      if (firstDigit != null && firstDigit >= 2 && firstDigit <= 9) {
        clean = '0$clean';
        autoPrefixed = true;
      }
    }

    // Limit to 4 digits: 2 for month, 2 for year
    final digits = clean.length > 4 ? clean.substring(0, 4) : clean;
    var formatted = CardFormatter.formatExpiry(digits);

    // Auto-append slash when 2 valid month digits are typed:
    if (digits.length == 2 && newValue.text.length > oldValue.text.length) {
      formatted = '$digits/';
    }

    if (autoPrefixed) {
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    final cursorIndex = newValue.selection.baseOffset;
    final textBeforeCursor =
        cursorIndex >= 0 && cursorIndex <= newValue.text.length
            ? newValue.text.substring(0, cursorIndex)
            : newValue.text;
    final digitsBeforeCursor =
        textBeforeCursor.replaceAll(RegExp(r'\D'), '').length;

    var formattedOffset = 0;
    var digitCount = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (digitCount == digitsBeforeCursor) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      formattedOffset = i + 1;
    }

    if (formattedOffset < formatted.length &&
        formatted[formattedOffset] == '/') {
      formattedOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formattedOffset.clamp(0, formatted.length),
      ),
    );
  }
}
