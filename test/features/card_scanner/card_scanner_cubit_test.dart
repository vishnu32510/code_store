import 'package:code_store/features/card_scanner/cubit/card_scanner_cubit.dart';
import 'package:code_store/features/card_scanner/cubit/card_scanner_state.dart';
import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMockScannerService implements ICardScannerService {
  final CardScanResult resultToReturn;
  _FakeMockScannerService(this.resultToReturn);

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<CardScanResult> scanCard() async => resultToReturn;

  @override
  CardDetails parseOcrLines(List<String> lines) =>
      CardOcrParser.parseRecognizedLines(lines);

  @override
  CardType detectCardType(String cardNumber) =>
      CardValidator.detectType(cardNumber);

  @override
  bool validateCardNumber(String cardNumber) =>
      CardValidator.validateLuhn(cardNumber);

  @override
  bool validateExpiryDate(int? month, int? year) =>
      CardValidator.validateExpiry(month, year);

  @override
  bool validateCvv(String cvv, CardType type) =>
      CardValidator.validateCvv(cvv, type);

  @override
  String formatCardNumber(String cardNumber) =>
      CardValidator.formatNumber(cardNumber);
}

void main() {
  group('CardScannerCubit Tests', () {
    late CardScannerCubit cubit;

    setUp(() {
      cubit = CardScannerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default empty values', () {
      expect(cubit.state.cardNumber, isEmpty);
      expect(cubit.state.cardHolder, isEmpty);
      expect(cubit.state.expiry, isEmpty);
      expect(cubit.state.cvv, isEmpty);
      expect(cubit.state.detectedType, CardType.unknown);
      expect(cubit.state.isLuhnValid, isFalse);
      expect(cubit.state.isCardFlipped, isFalse);
      expect(cubit.state.isScanningWithCamera, isFalse);
      expect(cubit.state.isScanning, isFalse);
    });

    test('updateCardNumber detects Visa and calculates Luhn checksum', () {
      // 4012 8888 8888 1881 is a valid Luhn Visa test number
      cubit.updateCardNumber('4012 8888 8888 1881');
      expect(cubit.state.cardNumber, '4012 8888 8888 1881');
      expect(cubit.state.detectedType, CardType.visa);
      expect(cubit.state.isLuhnValid, isTrue);

      // Incomplete number -> Luhn is false
      cubit.updateCardNumber('4012');
      expect(cubit.state.cardNumber, '4012');
      expect(cubit.state.detectedType, CardType.visa);
      expect(cubit.state.isLuhnValid, isFalse);
    });

    test('updateCardNumber ignores duplicate value emission', () {
      cubit.updateCardNumber('4012');
      final stateBefore = cubit.state;
      cubit.updateCardNumber('4012');
      expect(identical(cubit.state, stateBefore), isTrue);
    });

    test(
      'updateCardHolder, updateExpiry, and updateCvv modify respective fields',
      () {
        cubit.updateCardHolder('JOHN DOE');
        expect(cubit.state.cardHolder, 'JOHN DOE');

        cubit.updateExpiry('12/28');
        expect(cubit.state.expiry, '12/28');

        cubit.updateCvv('123');
        expect(cubit.state.cvv, '123');
      },
    );

    test('card flip toggling and setting orientation works', () {
      expect(cubit.state.isCardFlipped, isFalse);
      cubit.toggleCardFlip();
      expect(cubit.state.isCardFlipped, isTrue);

      cubit.setCardFlipped(false);
      expect(cubit.state.isCardFlipped, isFalse);
    });

    test('startCameraScan and stopCameraScan manage viewfinder state', () {
      expect(cubit.state.isScanningWithCamera, isFalse);
      cubit.startCameraScan();
      expect(cubit.state.isScanningWithCamera, isTrue);

      cubit.stopCameraScan();
      expect(cubit.state.isScanningWithCamera, isFalse);
    });

    test('applyScannedDetails populates fields and detects brand', () {
      const details = CardDetails(
        cardNumber: '5500000000000004',
        cardHolderName: 'SOPHIA CHEN',
        expiryMonth: 8,
        expiryYear: 29,
        cvv: '789',
        cardType: CardType.mastercard,
      );

      cubit.applyScannedDetails(details);
      expect(cubit.state.cardNumber, '5500 0000 0000 0004');
      expect(cubit.state.cardHolder, 'SOPHIA CHEN');
      expect(cubit.state.expiry, '08/29');
      expect(cubit.state.cvv, '789');
      expect(cubit.state.detectedType, CardType.mastercard);
      expect(cubit.state.isLuhnValid, isTrue);
      expect(cubit.state.isScanningWithCamera, isFalse);
      expect(cubit.state.lastScannedMessage, contains('Mastercard'));
    });

    test('applyPreset configures details from dummy card', () {
      cubit.applyPreset(
        number: '3782 822463 10005',
        holder: 'ALEX RIVERA',
        expiry: '11/27',
        cvv: '8431',
      );

      expect(cubit.state.cardNumber, '3782 822463 10005');
      expect(cubit.state.cardHolder, 'ALEX RIVERA');
      expect(cubit.state.detectedType, CardType.americanExpress);
      expect(cubit.state.isLuhnValid, isTrue);
      expect(cubit.state.lastScannedMessage, contains('American Express'));
    });

    test('clearForm resets state to initial default', () {
      cubit.updateCardNumber('4012 8888 8888 1881');
      cubit.updateCardHolder('JANE DOE');
      cubit.clearForm();

      expect(cubit.state, const CardScannerState());
    });

    test(
      'scanWithMockService fetches card from service and applies details',
      () async {
        final mock = _FakeMockScannerService(
          const CardScanResult(
            success: true,
            cardDetails: CardDetails(
              cardNumber: '4012888888881881',
              cardHolderName: 'ELENA ROSTOVA',
              expiryMonth: 5,
              expiryYear: 28,
              cardType: CardType.visa,
            ),
          ),
        );

        final mockCubit = CardScannerCubit(scannerService: mock);
        await mockCubit.scanWithMockService();

        expect(mockCubit.state.cardHolder, 'ELENA ROSTOVA');
        expect(mockCubit.state.detectedType, CardType.visa);
        expect(mockCubit.state.isScanning, isFalse);
        mockCubit.close();
      },
    );
  });
}
