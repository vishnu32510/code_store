import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  group('CardValidator & Regex Brand Detection', () {
    test('detects Visa brand correctly', () {
      expect(CardValidator.detectType('4111222233334444'), CardType.visa);
      expect(CardValidator.detectType('4000 0000 0000 0000'), CardType.visa);
    });

    test('detects Mastercard brand correctly (5-series and 2-series)', () {
      expect(CardValidator.detectType('5105105105105100'), CardType.mastercard);
      expect(CardValidator.detectType('5500000000000004'), CardType.mastercard);
      expect(CardValidator.detectType('2221000000000000'), CardType.mastercard);
      expect(CardValidator.detectType('2720000000000000'), CardType.mastercard);
    });

    test('detects American Express brand correctly', () {
      expect(
        CardValidator.detectType('340000000000000'),
        CardType.americanExpress,
      );
      expect(
        CardValidator.detectType('378282246310005'),
        CardType.americanExpress,
      );
    });

    test('detects Discover brand correctly', () {
      expect(CardValidator.detectType('6011000000000000'), CardType.discover);
      expect(CardValidator.detectType('6500000000000000'), CardType.discover);
    });

    test('detects JCB brand correctly', () {
      expect(CardValidator.detectType('3528000000000000'), CardType.jcb);
      expect(CardValidator.detectType('213100000000000'), CardType.jcb);
    });

    test('detects Diners Club brand correctly', () {
      expect(CardValidator.detectType('30000000000000'), CardType.dinersClub);
      expect(CardValidator.detectType('36000000000000'), CardType.dinersClub);
    });

    test('detects UnionPay brand correctly', () {
      expect(CardValidator.detectType('6200000000000000'), CardType.unionPay);
      expect(CardValidator.detectType('8100000000000000'), CardType.unionPay);
    });

    test('detects Maestro brand correctly', () {
      expect(CardValidator.detectType('5018000000000000'), CardType.maestro);
      expect(CardValidator.detectType('6759000000000000'), CardType.maestro);
    });

    test('detects Elo brand correctly', () {
      expect(CardValidator.detectType('4011780000000000'), CardType.elo);
      expect(CardValidator.detectType('5066990000000000'), CardType.elo);
    });

    test('returns unknown for unrecognized prefix or empty string', () {
      expect(CardValidator.detectType(''), CardType.unknown);
      expect(CardValidator.detectType('9999000000000000'), CardType.unknown);
    });
  });

  group('Luhn Checksum Validation', () {
    test('validates valid credit card numbers', () {
      // Known valid Luhn numbers
      expect(CardValidator.validateLuhn('4532015112830366'), isTrue);
      expect(CardValidator.validateLuhn('49927398716'), isTrue);
      expect(CardValidator.validateLuhn('4532 0151 1283 0366'), isTrue);
    });

    test('rejects invalid numbers or numbers corrupted by 1 digit', () {
      expect(CardValidator.validateLuhn('4532015112830367'), isFalse);
      expect(CardValidator.validateLuhn('49927398717'), isFalse);
      expect(CardValidator.validateLuhn('12345'), isFalse); // too short
      expect(CardValidator.validateLuhn(''), isFalse);
    });
  });

  group('Expiry Date & CVV Validation', () {
    test('validates valid future expiry dates', () {
      final futureYear = DateTime.now().year + 2;
      expect(CardValidator.validateExpiry(12, futureYear), isTrue);
      expect(CardValidator.validateExpiry(6, futureYear % 100), isTrue);
    });

    test('rejects past or invalid expiry dates', () {
      expect(CardValidator.validateExpiry(1, 2020), isFalse);
      expect(CardValidator.validateExpiry(13, 2028), isFalse);
      expect(CardValidator.validateExpiry(0, 2028), isFalse);
      expect(CardValidator.validateExpiry(null, 2028), isFalse);
    });

    test('validates CVV lengths according to brand', () {
      expect(CardValidator.validateCvv('123', CardType.visa), isTrue);
      expect(CardValidator.validateCvv('1234', CardType.visa), isFalse);
      expect(
        CardValidator.validateCvv('1234', CardType.americanExpress),
        isTrue,
      );
      expect(
        CardValidator.validateCvv('123', CardType.americanExpress),
        isFalse,
      );
    });
  });

  group('Number and Expiry Formatting', () {
    test('formats 16-digit cards with 4-4-4-4 spacing', () {
      expect(
        CardValidator.formatNumber('4111222233334444'),
        '4111 2222 3333 4444',
      );
    });

    test('formats American Express cards with 4-6-5 spacing', () {
      expect(
        CardValidator.formatNumber('378282246310005'),
        '3782 822463 10005',
      );
    });

    test('formats expiry as MM/YY', () {
      expect(CardValidator.formatExpiry('1228'), '12/28');
      expect(CardValidator.formatExpiry('05'), '05');
      expect(CardValidator.formatExpiry(''), '');
    });
  });

  group('CardDetails Model Serialization & Immutability', () {
    test('serializes to and from map cleanly', () {
      const details = CardDetails(
        cardNumber: '4532758923481234',
        cardHolderName: 'JANE DOE',
        expiryMonth: 10,
        expiryYear: 27,
        cvv: '999',
        cardType: CardType.visa,
        isValidNumber: true,
      );

      final map = details.toMap();
      final reconstructed = CardDetails.fromMap(map);

      expect(reconstructed, equals(details));
      expect(reconstructed.formattedExpiry, '10/27');
      expect(reconstructed.maskedNumber, '**** **** **** 1234');
      expect(reconstructed.isExpired, isFalse);
    });

    test('copyWith updates fields as expected', () {
      const original = CardDetails(cardNumber: '4111');
      final updated = original.copyWith(
        cardHolderName: 'ALICE',
        cardType: CardType.visa,
      );

      expect(updated.cardNumber, '4111');
      expect(updated.cardHolderName, 'ALICE');
      expect(updated.cardType, CardType.visa);
    });
  });

  group('Dependency Injection', () {
    setUp(() {
      GetIt.instance.reset();
    });

    test('setupCardScannerDI registers ICardScannerService', () {
      setupCardScannerDI();

      expect(GetIt.instance.isRegistered<ICardScannerService>(), isTrue);
      expect(GetIt.instance<ICardScannerService>(), isA<CardScannerService>());
    });

    test('setupCardScannerDI accepts custom service', () {
      final custom = CardScannerService();
      setupCardScannerDI(customService: custom);

      expect(GetIt.instance<ICardScannerService>(), same(custom));
    });
  });
}
