import 'package:bloc/bloc.dart';
import 'package:code_store_card_scanner/code_store_card_scanner.dart';

import 'card_scanner_state.dart';

/// Cubit managing card form state, real-time Luhn/brand validation, and scanner visibility.
class CardScannerCubit extends Cubit<CardScannerState> {
  final ICardScannerService _scannerService;

  CardScannerCubit({ICardScannerService? scannerService})
      : _scannerService = scannerService ?? CardScannerService(),
        super(const CardScannerState());

  ICardScannerService get scannerService => _scannerService;

  /// Updates card number and immediately evaluates IIN brand detection and Luhn checksum.
  void updateCardNumber(String rawNumber) {
    if (rawNumber == state.cardNumber) return;
    final cleanDigits = rawNumber.replaceAll(RegExp(r'\D'), '');
    final detected = CardValidator.detectType(cleanDigits);
    final isValid =
        cleanDigits.length >= 13 && CardValidator.validateLuhn(cleanDigits);

    emit(state.copyWith(
      cardNumber: rawNumber,
      detectedType: detected,
      isLuhnValid: isValid,
    ));
  }

  /// Updates the cardholder name on the card preview.
  void updateCardHolder(String holder) {
    if (holder == state.cardHolder) return;
    emit(state.copyWith(cardHolder: holder));
  }

  /// Updates the card expiration date on the card preview.
  void updateExpiry(String expiry) {
    if (expiry == state.expiry) return;
    emit(state.copyWith(expiry: expiry));
  }

  /// Updates the CVV code on the card preview back.
  void updateCvv(String cvv) {
    if (cvv == state.cvv) return;
    emit(state.copyWith(cvv: cvv));
  }

  /// Sets the 3D card flipped orientation.
  void setCardFlipped(bool isFlipped) {
    if (state.isCardFlipped != isFlipped) {
      emit(state.copyWith(isCardFlipped: isFlipped));
    }
  }

  /// Toggles between front and back of the 3D card preview.
  void toggleCardFlip() {
    emit(state.copyWith(isCardFlipped: !state.isCardFlipped));
  }

  /// Shows the in-place embedded camera viewfinder inside the card.
  void startCameraScan() {
    emit(state.copyWith(isScanningWithCamera: true));
  }

  /// Closes the in-place embedded camera viewfinder.
  void stopCameraScan() {
    emit(state.copyWith(isScanningWithCamera: false));
  }

  /// Populates state from scanned or verified card details.
  void applyScannedDetails(CardDetails details) {
    final rawNumber = details.formattedNumber;
    final cleanDigits = rawNumber.replaceAll(RegExp(r'\D'), '');
    final detected = details.cardType != CardType.unknown
        ? details.cardType
        : CardValidator.detectType(cleanDigits);
    final isValid =
        cleanDigits.length >= 13 && CardValidator.validateLuhn(cleanDigits);

    emit(state.copyWith(
      cardNumber: rawNumber,
      cardHolder: details.cardHolderName.isNotEmpty
          ? details.cardHolderName
          : state.cardHolder,
      expiry: details.formattedExpiry.isNotEmpty
          ? details.formattedExpiry
          : state.expiry,
      cvv: details.cvv.isNotEmpty ? details.cvv : state.cvv,
      detectedType: detected,
      isLuhnValid: isValid,
      isScanningWithCamera: false,
      lastScannedMessage:
          'Card details extracted successfully (${detected.displayName})',
    ));
  }

  /// Applies preset dummy card data for testing.
  void applyPreset({
    required String number,
    required String holder,
    required String expiry,
    required String cvv,
  }) {
    final cleanDigits = number.replaceAll(RegExp(r'\D'), '');
    final detected = CardValidator.detectType(cleanDigits);
    final isValid = CardValidator.validateLuhn(cleanDigits);

    emit(state.copyWith(
      cardNumber: number,
      cardHolder: holder,
      expiry: expiry,
      cvv: cvv,
      detectedType: detected,
      isLuhnValid: isValid,
      isScanningWithCamera: false,
      lastScannedMessage: 'Filled preset: ${detected.displayName}',
    ));
  }

  /// Executes scanning through the registered scanner service.
  Future<void> scanWithMockService() async {
    emit(state.copyWith(isScanning: true));
    try {
      final result = await _scannerService.scanCard();
      if (result.success && result.cardDetails != null) {
        applyScannedDetails(result.cardDetails!);
      }
    } finally {
      emit(state.copyWith(isScanning: false));
    }
  }

  /// Resets card details and returns 3D card preview to the front.
  void clearForm() {
    emit(const CardScannerState());
  }
}
