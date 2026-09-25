import 'package:flutter/material.dart';

/// Supported card brand types detected via issuer Identification Number (IIN / BIN) regex.
enum CardType {
  visa,
  mastercard,
  americanExpress,
  discover,
  jcb,
  dinersClub,
  unionPay,
  maestro,
  elo,
  unknown;

  /// Human-readable brand name.
  String get displayName {
    switch (this) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.americanExpress:
        return 'American Express';
      case CardType.discover:
        return 'Discover';
      case CardType.jcb:
        return 'JCB';
      case CardType.dinersClub:
        return 'Diners Club';
      case CardType.unionPay:
        return 'UnionPay';
      case CardType.maestro:
        return 'Maestro';
      case CardType.elo:
        return 'Elo';
      case CardType.unknown:
        return 'Credit / Debit';
    }
  }

  /// Expected CVV / CVC length (Amex has 4 digits, others usually 3).
  int get cvvLength {
    switch (this) {
      case CardType.americanExpress:
        return 4;
      default:
        return 3;
    }
  }

  /// Allowed card number lengths for this brand according to ISO/IEC 7812 network specifications.
  List<int> get validLengths {
    switch (this) {
      case CardType.americanExpress:
        return const [15];
      case CardType.dinersClub:
        return const [14, 16, 19];
      case CardType.discover:
        return const [16, 19];
      case CardType.jcb:
        return const [15, 16, 17, 18, 19];
      case CardType.unionPay:
        return const [14, 15, 16, 17, 18, 19];
      case CardType.maestro:
        return const [12, 13, 14, 15, 16, 17, 18, 19];
      case CardType.visa:
        return const [13, 16, 18, 19];
      case CardType.mastercard:
        return const [16];
      case CardType.elo:
        return const [16];
      case CardType.unknown:
        return const [12, 13, 14, 15, 16, 17, 18, 19];
    }
  }

  /// Minimum allowable digit length for this card brand.
  int get minLength => validLengths.first;

  /// Maximum allowable digit length for this card brand.
  int get maxLength => validLengths.last;

  /// Whether a given raw digit length is valid for this card brand.
  bool isValidLength(int length) => validLengths.contains(length);

  /// Standard card number length without spaces.
  int get standardNumberLength {
    switch (this) {
      case CardType.americanExpress:
        return 15;
      case CardType.dinersClub:
        return 14;
      case CardType.maestro:
        return 19;
      default:
        return 16;
    }
  }

  /// Standard grouping pattern for formatting spaces.
  /// American Express is 4-6-5, Diners Club is 4-6-4, Maestro is 4-4-4-4-3, others are 4-4-4-4.
  List<int> get digitGroupings {
    switch (this) {
      case CardType.americanExpress:
        return const [4, 6, 5];
      case CardType.dinersClub:
        return const [4, 6, 4];
      case CardType.maestro:
        return const [4, 4, 4, 4, 3];
      default:
        return const [4, 4, 4, 4];
    }
  }

  /// Primary brand theme gradient colors for card display.
  List<Color> get gradientColors {
    switch (this) {
      case CardType.visa:
        return const [Color(0xFF1A1F71), Color(0xFF00579F)];
      case CardType.mastercard:
        return const [Color(0xFF222222), Color(0xFFEB001B)];
      case CardType.americanExpress:
        return const [Color(0xFF007BC1), Color(0xFF002663)];
      case CardType.discover:
        return const [Color(0xFFFF6000), Color(0xFF1E2838)];
      case CardType.jcb:
        return const [Color(0xFF003780), Color(0xFF006837)];
      case CardType.dinersClub:
        return const [Color(0xFF004A7F), Color(0xFF38618C)];
      case CardType.unionPay:
        return const [Color(0xFF006670), Color(0xFFB31B1B)];
      case CardType.maestro:
        return const [Color(0xFF0061A8), Color(0xFFEB001B)];
      case CardType.elo:
        return const [Color(0xFF00A4E0), Color(0xFF000000)];
      case CardType.unknown:
        return const [Color(0xFF2C3E50), Color(0xFF000000)];
    }
  }
}
