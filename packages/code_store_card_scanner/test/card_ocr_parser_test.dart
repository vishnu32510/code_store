import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardOcrParser', () {
    test(
      'extracts Visa card number, expiry date, and cardholder name correctly',
      () {
        final ocrLines = [
          'CHASE SAPPHIRE',
          '4532 0151 1283 0366',
          'VALID THRU 12/28',
          'ALEX MORGAN',
          'VISA SIGNATURE',
        ];

        final result = CardOcrParser.parseRecognizedLines(ocrLines);

        expect(result.isValidNumber, isTrue);
        expect(result.cardNumber, '4532015112830366');
        expect(result.cardType, CardType.visa);
        expect(result.expiryMonth, 12);
        expect(result.expiryYear, 28);
        expect(result.cardHolderName, 'ALEX MORGAN');
      },
    );

    test('extracts Mastercard with dashed format and ignores bank header', () {
      final ocrLines = [
        'CITIBANK REWARDS',
        '5555-5555-5555-4444',
        'EXP 05/27',
        'JOHNATHAN DOE',
        'DEBIT CARD',
        'ELECTRONIC USE ONLY',
      ];

      final result = CardOcrParser.parseRecognizedLines(ocrLines);

      expect(result.isValidNumber, isTrue);
      expect(result.cardNumber, '5555555555554444');
      expect(result.cardType, CardType.mastercard);
      expect(result.expiryMonth, 5);
      expect(result.expiryYear, 27);
      expect(result.cardHolderName, 'JOHNATHAN DOE');
    });

    test('ignores non-Luhn candidate numbers', () {
      final ocrLines = [
        'ACCOUNT NUMBER 1234567890123456', // Fails Luhn
        'CUSTOMER SERVICE 18001234567',
        'SARAH CONNOR',
      ];

      final result = CardOcrParser.parseRecognizedLines(ocrLines);

      expect(result.isValidNumber, isFalse);
      expect(result.cardNumber, isEmpty);
      expect(result.cardHolderName, 'SARAH CONNOR');
    });
  });
}
