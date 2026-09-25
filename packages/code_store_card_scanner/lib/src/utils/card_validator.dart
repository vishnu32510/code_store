import '../models/card_type.dart';
import 'card_input_formatters.dart';

/// Comprehensive validation result providing card brand, validity flags, and error message.
class CardValidationResult {
  const CardValidationResult({
    required this.isValid,
    required this.isPotentiallyValid,
    required this.cardType,
    this.errorMessage,
  });

  /// Whether the card number is fully valid (matches standard brand length and passes Luhn checksum).
  final bool isValid;

  /// Whether the card number could become valid as further digits are entered.
  final bool isPotentiallyValid;

  /// The detected card brand.
  final CardType cardType;

  /// Diagnostic error message if invalid, or `null` if valid.
  final String? errorMessage;

  @override
  String toString() =>
      'CardValidationResult(isValid: $isValid, isPotentiallyValid: $isPotentiallyValid, cardType: $cardType, error: $errorMessage)';
}

/// Robust validation and regex parsing utility for debit and credit cards.
class CardValidator {
  CardValidator._();

  // MARK: - Regex Brand Detection

  static final RegExp _visaRegex = RegExp(r'^4[0-9]*$');
  static final RegExp _mastercardRegex = RegExp(
    r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720)[0-9]*$',
  );
  static final RegExp _amexRegex = RegExp(r'^3[47][0-9]*$');
  static final RegExp _discoverRegex = RegExp(r'^(6011|65|64[4-9]|622)[0-9]*$');
  static final RegExp _jcbRegex = RegExp(r'^(35[2-8]|2131|1800)[0-9]*$');
  static final RegExp _dinersRegex = RegExp(r'^(30[0-5]|36|38|39)[0-9]*$');
  static final RegExp _unionPayRegex = RegExp(r'^(62|81)[0-9]*$');
  static final RegExp _maestroRegex = RegExp(
    r'^(5018|5020|5038|5893|6304|6759|6761|6762|6763)[0-9]*$',
  );
  static final RegExp _eloRegex = RegExp(
    r'^(4011|4312|4389|4514|4576|5041|5066|5090|6277|6362|6363|6516|6550)[0-9]*$',
  );

  /// Identifies the card brand in real-time from the raw or formatted card number.
  static CardType detectType(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return CardType.unknown;

    if (_eloRegex.hasMatch(clean)) return CardType.elo;
    if (_visaRegex.hasMatch(clean)) return CardType.visa;
    if (_mastercardRegex.hasMatch(clean)) return CardType.mastercard;
    if (_amexRegex.hasMatch(clean)) return CardType.americanExpress;
    if (_discoverRegex.hasMatch(clean)) return CardType.discover;
    if (_jcbRegex.hasMatch(clean)) return CardType.jcb;
    if (_dinersRegex.hasMatch(clean)) return CardType.dinersClub;
    if (_unionPayRegex.hasMatch(clean)) return CardType.unionPay;
    if (_maestroRegex.hasMatch(clean)) return CardType.maestro;

    return CardType.unknown;
  }

  // MARK: - Luhn Algorithm & Card Number Validation

  /// Validates a card number using the ISO/IEC 7812 Luhn checksum algorithm (Mod 10).
  static bool validateLuhn(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 8) return false;

    var sum = 0;
    var alternate = false;

    for (var i = clean.length - 1; i >= 0; i--) {
      var n = int.tryParse(clean[i]);
      if (n == null) return false;

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  /// Validates a card number against both length criteria for its brand and the Luhn checksum.
  static bool validateCardNumber(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return false;
    final type = detectType(clean);
    if (!type.isValidLength(clean.length)) return false;
    return validateLuhn(clean);
  }

  /// Checks whether a partially entered card number is viable as the user types.
  static bool isPotentiallyValid(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (clean.isEmpty) return true;
    if (RegExp(r'\D').hasMatch(clean)) return false;

    final type = detectType(clean);
    if (clean.length > type.maxLength) return false;
    if (type.isValidLength(clean.length)) return validateLuhn(clean);
    return true; // Still typing and within length limits
  }

  /// Full diagnostic validation returning a detailed [CardValidationResult].
  static CardValidationResult validate(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (clean.isEmpty) {
      return const CardValidationResult(
        isValid: false,
        isPotentiallyValid: true,
        cardType: CardType.unknown,
        errorMessage: 'Card number is required.',
      );
    }

    if (RegExp(r'\D').hasMatch(clean)) {
      return const CardValidationResult(
        isValid: false,
        isPotentiallyValid: false,
        cardType: CardType.unknown,
        errorMessage: 'Card number must contain digits only.',
      );
    }

    final type = detectType(clean);
    if (clean.length < type.minLength) {
      return CardValidationResult(
        isValid: false,
        isPotentiallyValid: true,
        cardType: type,
        errorMessage: 'Card number is incomplete.',
      );
    }

    if (clean.length > type.maxLength) {
      return CardValidationResult(
        isValid: false,
        isPotentiallyValid: false,
        cardType: type,
        errorMessage: 'Card number exceeds maximum allowed length.',
      );
    }

    if (!type.isValidLength(clean.length)) {
      return CardValidationResult(
        isValid: false,
        isPotentiallyValid: false,
        cardType: type,
        errorMessage: 'Invalid card length for ${type.displayName}.',
      );
    }

    final luhnOk = validateLuhn(clean);
    if (!luhnOk) {
      return CardValidationResult(
        isValid: false,
        isPotentiallyValid: false,
        cardType: type,
        errorMessage: 'Invalid card number checksum.',
      );
    }

    return CardValidationResult(
      isValid: true,
      isPotentiallyValid: true,
      cardType: type,
    );
  }

  // MARK: - Expiry Date Validation

  /// Validates month (1-12) and year against current calendar date.
  static bool validateExpiry(int? month, int? year) {
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    var fullYear = year;
    if (fullYear < 100) {
      fullYear += 2000;
    }

    final now = DateTime.now();
    if (fullYear < now.year) return false;
    if (fullYear == now.year && month < now.month) return false;
    if (fullYear > now.year + 25) return false;

    return true;
  }

  /// Validates an expiration date string formatted as "MM/YY" or "MM/YYYY".
  static bool validateExpiryDate(String expiryDate) {
    if (expiryDate.isEmpty) return false;
    final clean = expiryDate.replaceAll(RegExp(r'\s+'), '');
    final parts = clean.split(RegExp(r'[/\-]'));
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    return validateExpiry(month, year);
  }

  // MARK: - CVV Validation

  /// Validates CVV digits against the expected length for the card brand.
  /// If [type] is [CardType.unknown], accepts standard 3 or 4 digits.
  static bool validateCvv(String cvv, [CardType type = CardType.unknown]) {
    final clean = cvv.replaceAll(RegExp(r'\D'), '');
    if (type == CardType.unknown) {
      return clean.length == 3 || clean.length == 4;
    }
    return clean.length == type.cvvLength;
  }

  // MARK: - Card Formatting & Masking

  /// Formats raw digits with the appropriate grouping spaces according to the detected brand.
  static String formatNumber(String cardNumber) =>
      CardFormatter.formatNumber(cardNumber);

  /// Formats raw digits into "MM/YY".
  static String formatExpiry(String raw) => CardFormatter.formatExpiry(raw);

  /// Formats a card number into a masked presentation (e.g. `•••• •••• •••• 1234`).
  static String maskNumber(
    String cardNumber, {
    int visibleEndDigits = 4,
    String maskChar = '•',
  }) =>
      CardFormatter.maskNumber(
        cardNumber,
        visibleEndDigits: visibleEndDigits,
        maskChar: maskChar,
      );
}
