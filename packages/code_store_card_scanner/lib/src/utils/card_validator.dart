import '../models/card_type.dart';

/// Robust validation and regex parsing utility for debit and credit cards.
class CardValidator {
  CardValidator._();

  // MARK: - Regex Brand Detection

  static final RegExp _visaRegex = RegExp(r'^4[0-9]*$');
  static final RegExp _mastercardRegex =
      RegExp(r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720)[0-9]*$');
  static final RegExp _amexRegex = RegExp(r'^3[47][0-9]*$');
  static final RegExp _discoverRegex =
      RegExp(r'^(6011|65|64[4-9]|622)[0-9]*$');
  static final RegExp _jcbRegex = RegExp(r'^(35[2-8]|2131|1800)[0-9]*$');
  static final RegExp _dinersRegex = RegExp(r'^(30[0-5]|36|38|39)[0-9]*$');
  static final RegExp _unionPayRegex = RegExp(r'^(62|81)[0-9]*$');
  static final RegExp _maestroRegex =
      RegExp(r'^(5018|5020|5038|5893|6304|6759|6761|6762|6763)[0-9]*$');
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

  // MARK: - Luhn Algorithm Validation

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

  // MARK: - CVV Validation

  /// Validates CVV digits against the expected length for the card brand.
  static bool validateCvv(String cvv, CardType type) {
    final clean = cvv.replaceAll(RegExp(r'\D'), '');
    return clean.length == type.cvvLength;
  }

  // MARK: - Card Formatting

  /// Formats raw digits with the appropriate grouping spaces according to the detected brand.
  static String formatNumber(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';

    final type = detectType(clean);
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

  /// Formats raw digits into "MM/YY".
  static String formatExpiry(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';
    if (clean.length <= 2) return clean;
    return '${clean.substring(0, 2)}/${clean.substring(2, clean.length.clamp(2, 4))}';
  }
}
