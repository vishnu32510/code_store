import '../models/card_details.dart';
import '../models/card_scan_result.dart';
import '../models/card_type.dart';

/// Abstract service contract for card scanning, brand detection, and validation.
abstract interface class ICardScannerService {
  /// Checks whether hardware camera and card scanning capabilities are available.
  Future<bool> isAvailable();

  /// Launches the camera card scanner and extracts card details.
  /// If [mockFallbackIfUnavailable] is true and running on an emulator/simulator,
  /// returns a simulated successful scan for development testing.
  Future<CardScanResult> scanCard({bool mockFallbackIfUnavailable = false});

  /// Parses raw OCR recognized lines of text into structured card details using Luhn checks.
  CardDetails parseOcrLines(List<String> lines);

  /// Detects the card brand using regex patterns matching issuer prefixes.
  CardType detectCardType(String cardNumber);

  /// Validates a card number using Luhn algorithm checksum.
  bool validateCardNumber(String cardNumber);

  /// Validates expiration month and year.
  bool validateExpiryDate(int? month, int? year);

  /// Validates card verification value (CVV).
  bool validateCvv(String cvv, CardType type);

  /// Formats raw card digits with brand-specific grouping spaces.
  String formatCardNumber(String cardNumber);
}
