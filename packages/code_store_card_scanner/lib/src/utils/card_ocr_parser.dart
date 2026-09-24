import '../models/card_details.dart';
import '../models/card_type.dart';
import 'card_validator.dart';

/// Unified OCR text parser for extracting card number, expiry date,
/// and cardholder name from text recognized by any OCR engine (Google ML Kit, Apple Vision, etc.).
class CardOcrParser {
  CardOcrParser._();

  static final RegExp _expiryRegex = RegExp(
    r'(?:EXP(?:IRES)?|VALID\s+THRU|GOOD\s+THRU)?[:\s\.]*\s*([0-1]?[0-9])\s*[\/\.\-\s]+\s*([2-3][0-9]|20[2-3][0-9])\b',
    caseSensitive: false,
  );

  /// Normalizes common OCR misread characters in candidate card number sequences:
  /// - 'L', 'l', 'I', '|' are commonly misread for '1'
  /// - 'O' and 'D' are commonly misread for '0'
  static String normalizeOcrNumericCharacters(String text) {
    return text
        .replaceAll(RegExp(r'[LlI|]'), '1')
        .replaceAll(RegExp(r'[OD]'), '0');
  }

  static final Set<String> _blacklistWords = {
    'VISA',
    'MASTERCARD',
    'MASTER',
    'CARD',
    'AMEX',
    'AMERICAN',
    'EXPRESS',
    'DISCOVER',
    'JCB',
    'DINERS',
    'CLUB',
    'DEBIT',
    'CREDIT',
    'BANK',
    'CHASE',
    'SAPPHIRE',
    'FREEDOM',
    'WELLS',
    'FARGO',
    'CITI',
    'CITIBANK',
    'CAPITAL',
    'ONE',
    'BARCLAYS',
    'FIDELITY',
    'USAA',
    'VALID',
    'THRU',
    'GOOD',
    'UNTIL',
    'EXPIRES',
    'EXP',
    'MONTH',
    'YEAR',
    'MEMBER',
    'SINCE',
    'PLATINUM',
    'GOLD',
    'BUSINESS',
    'PREMIER',
    'REWARDS',
    'SIGNATURE',
    'WORLD',
    'ELECTRONIC',
    'USE',
    'ONLY',
    'CUSTOMER',
    'SERVICE',
    'ACCOUNT',
    'NUMBER',
  };

  /// Parses recognized lines of text into structured [CardDetails].
  static CardDetails parseRecognizedLines(List<String> rawLines) {
    String? foundCardNumber;
    int? foundExpiryMonth;
    int? foundExpiryYear;
    String? foundHolderName;
    int cardNumberLineIndex = -1;

    final cleanedLines =
        rawLines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // 1. Extract Card Number using Luhn Check
    for (var i = 0; i < cleanedLines.length; i++) {
      final line = cleanedLines[i];
      final digitsOnly = line.replaceAll(RegExp(r'\D'), '');

      // Check if line contains a potential card sequence (13 to 19 digits)
      if (digitsOnly.length >= 13 && digitsOnly.length <= 19) {
        if (CardValidator.validateLuhn(digitsOnly)) {
          foundCardNumber = digitsOnly;
          cardNumberLineIndex = i;
          break;
        }
      }

      // Check with OCR normalization (substituting L, l, I, | -> 1, and O, D -> 0)
      final normalizedLine = normalizeOcrNumericCharacters(line);
      final normalizedDigits = normalizedLine.replaceAll(RegExp(r'\D'), '');
      if (normalizedDigits.length >= 13 && normalizedDigits.length <= 19) {
        if (CardValidator.validateLuhn(normalizedDigits)) {
          foundCardNumber = normalizedDigits;
          cardNumberLineIndex = i;
          break;
        }
      }

      // If text has spaces between chunks e.g. "4532 0151 1283 0366" or "4532 0L5I 1283 0366"
      final chunkMatches =
          RegExp(r'\b(?:\S[ -]*?){13,19}\b').allMatches(normalizedLine);
      for (final match in chunkMatches) {
        final candidate = match.group(0)!.replaceAll(RegExp(r'\D'), '');
        if (candidate.length >= 13 && candidate.length <= 19) {
          if (CardValidator.validateLuhn(candidate)) {
            foundCardNumber = candidate;
            cardNumberLineIndex = i;
            break;
          }
        }
      }
      if (foundCardNumber != null) break;
    }

    // 2. Extract Expiry Date (supports MM/YY, MM/YYYY, MM-YY, MM-YYYY, MM.YY)
    for (final line in cleanedLines) {
      final match = _expiryRegex.firstMatch(line) ??
          _expiryRegex.firstMatch(normalizeOcrNumericCharacters(line));
      if (match != null) {
        final monthStr = match.group(1);
        final yearStr = match.group(2);
        if (monthStr != null && yearStr != null) {
          final m = int.tryParse(monthStr);
          int? y = int.tryParse(yearStr);
          if (y != null && y >= 2000) {
            y = y % 100;
          }
          if (m != null && y != null && CardValidator.validateExpiry(m, y)) {
            foundExpiryMonth = m;
            foundExpiryYear = y;
            break;
          }
        }
      }
    }

    // 3. Extract Cardholder Name (Uppercase words excluding blacklist)
    // On physical cards, name is usually below card number; search lines after card number first
    final candidateLines = <String>[];
    if (cardNumberLineIndex != -1 &&
        cardNumberLineIndex + 1 < cleanedLines.length) {
      candidateLines.addAll(cleanedLines.sublist(cardNumberLineIndex + 1));
    }
    candidateLines.addAll(cleanedLines);

    for (final line in candidateLines) {
      // Must not contain digits
      if (RegExp(r'\d').hasMatch(line)) continue;

      final words = line
          .toUpperCase()
          .split(RegExp(r'\s+'))
          .where((w) => RegExp(r'^[A-Z]{2,}$').hasMatch(w))
          .toList();

      if (words.length >= 2 && words.length <= 4) {
        final hasBlacklist = words.any((w) => _blacklistWords.contains(w));
        if (!hasBlacklist) {
          foundHolderName = words.join(' ');
          break;
        }
      }
    }

    final cardType = foundCardNumber != null
        ? CardValidator.detectType(foundCardNumber)
        : CardType.unknown;

    return CardDetails(
      cardNumber: foundCardNumber ?? '',
      expiryMonth: foundExpiryMonth,
      expiryYear: foundExpiryYear,
      cardHolderName: foundHolderName ?? '',
      cardType: cardType,
      isValidNumber: foundCardNumber != null,
    );
  }
}
