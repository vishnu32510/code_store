import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:equatable/equatable.dart';

/// State representation for credit card scanning, validation, and visual rendering.
class CardScannerState extends Equatable {
  /// The formatted or raw card number string.
  final String cardNumber;

  /// Name of the cardholder.
  final String cardHolder;

  /// Expiration date string formatted as MM/YY.
  final String expiry;

  /// Card verification value (CVV/CVC/CID).
  final String cvv;

  /// Auto-detected card brand according to IIN/BIN regex prefix.
  final CardType detectedType;

  /// Whether the card number satisfies the Luhn mod-10 checksum algorithm.
  final bool isLuhnValid;

  /// Whether the card's 3D flip preview is currently showing the back (magnetic stripe).
  final bool isCardFlipped;

  /// Whether the embedded in-place camera viewfinder is active.
  final bool isScanningWithCamera;

  /// Whether a scan operation is in progress.
  final bool isScanning;

  /// Optional feedback message from the latest scanning action.
  final String? lastScannedMessage;

  const CardScannerState({
    this.cardNumber = '',
    this.cardHolder = '',
    this.expiry = '',
    this.cvv = '',
    this.detectedType = CardType.unknown,
    this.isLuhnValid = false,
    this.isCardFlipped = false,
    this.isScanningWithCamera = false,
    this.isScanning = false,
    this.lastScannedMessage,
  });

  CardScannerState copyWith({
    String? cardNumber,
    String? cardHolder,
    String? expiry,
    String? cvv,
    CardType? detectedType,
    bool? isLuhnValid,
    bool? isCardFlipped,
    bool? isScanningWithCamera,
    bool? isScanning,
    String? lastScannedMessage,
  }) {
    return CardScannerState(
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      detectedType: detectedType ?? this.detectedType,
      isLuhnValid: isLuhnValid ?? this.isLuhnValid,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      isScanningWithCamera: isScanningWithCamera ?? this.isScanningWithCamera,
      isScanning: isScanning ?? this.isScanning,
      lastScannedMessage: lastScannedMessage,
    );
  }

  @override
  List<Object?> get props => [
        cardNumber,
        cardHolder,
        expiry,
        cvv,
        detectedType,
        isLuhnValid,
        isCardFlipped,
        isScanningWithCamera,
        isScanning,
        lastScannedMessage,
      ];
}
