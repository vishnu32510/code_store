import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card_scanner/credit_card.dart';
import 'package:flutter_credit_card_scanner/credit_card_scanner.dart';

import '../models/card_details.dart';
import '../models/card_type.dart';
import '../utils/card_validator.dart';

/// Full-screen live camera view for scanning credit and debit cards using
/// Google ML Kit (Android) and Apple Vision (iOS) via flutter_credit_card_scanner.
class CardCameraScannerView extends StatefulWidget {
  const CardCameraScannerView({super.key});

  @override
  State<CardCameraScannerView> createState() => _CardCameraScannerViewState();
}

class _CardCameraScannerViewState extends State<CardCameraScannerView> {
  bool _hasScanned = false;

  void _handleScan(BuildContext context, CreditCardModel? cardModel) {
    if (_hasScanned || cardModel == null) return;
    if (cardModel.number.trim().isEmpty) return;

    _hasScanned = true;
    HapticFeedback.mediumImpact();

    final cleanNumber = cardModel.number.replaceAll(RegExp(r'\D'), '');
    final expMonth = int.tryParse(cardModel.expirationMonth.trim());
    final expYear = int.tryParse(cardModel.expirationYear.trim());
    final detectedType = CardValidator.detectType(cleanNumber);
    final isValid = CardValidator.validateLuhn(cleanNumber);

    final details = CardDetails(
      cardNumber: cleanNumber,
      cardHolderName: cardModel.holderName.trim(),
      expiryMonth: expMonth,
      expiryYear: expYear,
      cardType: detectedType,
      isValidNumber: isValid,
    );

    Navigator.of(context).pop(details);
  }

  void _handleNoCamera() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.videocam_off_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Camera Unavailable'),
          ],
        ),
        content: const Text(
          'No camera was detected, or camera permission was not granted. '
          'On an iOS Simulator, a physical camera device is unavailable.\n\n'
          'Would you like to populate a simulated test card instead?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              const testCard = CardDetails(
                cardNumber: '4532015112830366',
                cardHolderName: 'ALEX MORGAN',
                expiryMonth: 12,
                expiryYear: 28,
                cvv: '842',
                cardType: CardType.visa,
                isValidNumber: true,
              );
              Navigator.of(context).pop(testCard);
            },
            child: const Text('Use Test Card'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Scanner Preview
          Positioned.fill(
            child: CameraScannerWidget(
              onScan: (ctx, model) => _handleScan(ctx, model),
              loadingHolder: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Starting Camera...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              onNoCamera: _handleNoCamera,
              useLuhnValidation: true,
              cardNumber: true,
              cardHolder: true,
              cardExpiryDate: true,
              colorOverlay: Colors.black.withValues(alpha: 0.65),
            ),
          ),

          // 2. Top Navigation Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Scan Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Guide Label
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.crop_free_rounded,
                    color: Colors.cyanAccent,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Align card within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
