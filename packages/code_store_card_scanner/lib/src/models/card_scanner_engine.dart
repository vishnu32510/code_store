/// Supported scanning engines for debit and credit card scanning.
enum CardScannerEngine {
  mlKitVision(
    id: 'ml_kit_vision',
    displayName: 'Google ML Kit / Vision',
    subtitle: 'Character OCR + Luhn checksum parser',
    badge: 'Real OCR',
  ),
  flutterCreditCardScanner(
    id: 'flutter_credit_card_scanner',
    displayName: 'Card Scanner Overlay',
    subtitle: 'Framed viewfinder & bounding detector',
    badge: 'Card Scanner',
  ),
  systemAutofill(
    id: 'system_autofill',
    displayName: 'OS Autofill & Camera',
    subtitle: 'iOS Keychain & QuickType keyboard OCR',
    badge: 'Native OS',
  ),
  simulated(
    id: 'simulated',
    displayName: 'Simulated Laser',
    subtitle: 'Smooth 3D viewfinder laser sweep test',
    badge: 'Simulator',
  );

  final String id;
  final String displayName;
  final String subtitle;
  final String badge;

  const CardScannerEngine({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.badge,
  });
}
