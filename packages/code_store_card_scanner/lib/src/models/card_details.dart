import 'package:meta/meta.dart';

import 'card_type.dart';

/// Immutable model representing credit or debit card details.
@immutable
class CardDetails {
  const CardDetails({
    required this.cardNumber,
    this.cardHolderName = '',
    this.expiryMonth,
    this.expiryYear,
    this.cvv = '',
    this.cardType = CardType.unknown,
    this.isValidNumber = false,
  });

  /// Factory constructing an empty card details model.
  factory CardDetails.empty() => const CardDetails(cardNumber: '');

  /// Factory creating from a key-value Map.
  factory CardDetails.fromMap(Map<String, dynamic> map) {
    final rawNumber = (map['cardNumber'] as String? ?? '').replaceAll(' ', '');
    final typeName = map['cardType'] as String? ?? 'unknown';
    final cardType = CardType.values.firstWhere(
      (t) => t.name.toLowerCase() == typeName.toLowerCase(),
      orElse: () => CardType.unknown,
    );

    return CardDetails(
      cardNumber: rawNumber,
      cardHolderName: map['cardHolderName'] as String? ?? '',
      expiryMonth: map['expiryMonth'] as int?,
      expiryYear: map['expiryYear'] as int?,
      cvv: map['cvv'] as String? ?? '',
      cardType: cardType,
      isValidNumber: map['isValidNumber'] as bool? ?? false,
    );
  }

  /// Raw card digits without spaces or dashes.
  final String cardNumber;

  /// Cardholder name as printed on the card.
  final String cardHolderName;

  /// Expiry month (1 - 12).
  final int? expiryMonth;

  /// Expiry year (two digits or four digits).
  final int? expiryYear;

  /// Card verification code (CVV / CVC).
  final String cvv;

  /// Detected card brand type.
  final CardType cardType;

  /// Whether the card number passes Luhn algorithm checksum.
  final bool isValidNumber;

  /// Returns expiry date formatted as "MM/YY".
  String get formattedExpiry {
    if (expiryMonth == null || expiryYear == null) return '';
    final m = expiryMonth!.toString().padLeft(2, '0');
    final y = expiryYear! % 100;
    return '$m/${y.toString().padLeft(2, '0')}';
  }

  /// Formatted card number with grouping spaces.
  String get formattedNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';

    final groupings = cardType.digitGroupings;
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

  /// Obscured card number showing only the last 4 digits (e.g., "**** **** **** 1234").
  String get maskedNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    if (cardType == CardType.americanExpress) {
      return '**** ****** *$last4';
    }
    return '**** **** **** $last4';
  }

  /// Checks if the card is expired based on current year/month.
  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    var fullYear = expiryYear!;
    if (fullYear < 100) {
      fullYear += 2000;
    }
    if (fullYear < now.year) return true;
    if (fullYear == now.year && expiryMonth! < now.month) return true;
    return false;
  }

  CardDetails copyWith({
    String? cardNumber,
    String? cardHolderName,
    int? expiryMonth,
    int? expiryYear,
    String? cvv,
    CardType? cardType,
    bool? isValidNumber,
  }) {
    return CardDetails(
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      isValidNumber: isValidNumber ?? this.isValidNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardType': cardType.name,
      'isValidNumber': isValidNumber,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardDetails &&
        other.cardNumber == cardNumber &&
        other.cardHolderName == cardHolderName &&
        other.expiryMonth == expiryMonth &&
        other.expiryYear == expiryYear &&
        other.cvv == cvv &&
        other.cardType == cardType &&
        other.isValidNumber == isValidNumber;
  }

  @override
  int get hashCode => Object.hash(
        cardNumber,
        cardHolderName,
        expiryMonth,
        expiryYear,
        cvv,
        cardType,
        isValidNumber,
      );

  @override
  String toString() {
    return 'CardDetails(cardType: ${cardType.displayName}, masked: $maskedNumber, expiry: $formattedExpiry, name: $cardHolderName, valid: $isValidNumber)';
  }
}
