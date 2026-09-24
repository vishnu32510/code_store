import 'package:meta/meta.dart';

import 'card_details.dart';

/// Result emitted when a card scanning session completes or fails.
@immutable
class CardScanResult {
  const CardScanResult({
    required this.success,
    this.cardDetails,
    this.errorMessage,
    this.isCancelled = false,
  });

  /// Constructor for a successful scan result.
  const CardScanResult.success(CardDetails details)
      : success = true,
        cardDetails = details,
        errorMessage = null,
        isCancelled = false;

  /// Constructor for a cancelled scan result.
  const CardScanResult.cancelled()
      : success = false,
        cardDetails = null,
        errorMessage = null,
        isCancelled = true;

  /// Constructor for an error scan result.
  const CardScanResult.failure(String message)
      : success = false,
        cardDetails = null,
        errorMessage = message,
        isCancelled = false;

  /// Whether the card details were scanned successfully.
  final bool success;

  /// The extracted card details if successful.
  final CardDetails? cardDetails;

  /// Human-readable error message if unsuccessful.
  final String? errorMessage;

  /// Whether the user dismissed or cancelled the scanner camera.
  final bool isCancelled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardScanResult &&
        other.success == success &&
        other.cardDetails == cardDetails &&
        other.errorMessage == errorMessage &&
        other.isCancelled == isCancelled;
  }

  @override
  int get hashCode =>
      Object.hash(success, cardDetails, errorMessage, isCancelled);

  @override
  String toString() {
    if (success) return 'CardScanResult.success($cardDetails)';
    if (isCancelled) return 'CardScanResult.cancelled()';
    return 'CardScanResult.failure($errorMessage)';
  }
}
