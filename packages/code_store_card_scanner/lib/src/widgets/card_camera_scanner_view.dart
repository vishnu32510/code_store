import 'package:flutter/material.dart';

import '../models/card_details.dart';
import 'embedded_card_camera.dart';

/// Full-screen live camera view for scanning credit and debit cards using
/// Google ML Kit (Android) and Apple Vision (iOS) via EmbeddedCardCamera.
class CardCameraScannerView extends StatelessWidget {
  /// Optional callback invoked when a card is successfully scanned.
  final void Function(CardDetails details)? onCardScanned;

  /// Custom laser scanline and accent color (defaults to cyan accent or app primary).
  final Color? laserColor;

  /// App bar title text. Defaults to 'Scan Card'.
  final String title;

  /// Bottom guidance prompt text. Defaults to 'Align card within the frame'.
  final String? guidanceText;

  /// Icon displayed next to the bottom guidance text.
  final IconData? guidanceIcon;

  /// Whether to show the bottom guidance badge. Defaults to true.
  final bool showGuidance;

  const CardCameraScannerView({
    super.key,
    this.onCardScanned,
    this.laserColor,
    this.title = 'Scan Card',
    this.guidanceText = 'Align card within the frame',
    this.guidanceIcon = Icons.crop_free_rounded,
    this.showGuidance = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = laserColor ?? Colors.cyanAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Scanner Viewfinder with Laser & Hologram
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340, maxHeight: 200),
              child: EmbeddedCardCamera(
                key: const ValueKey('full_screen_embedded_camera_viewfinder'),
                laserColor: laserColor,
                showGuidance: false, // Full screen view renders its own prominent bottom guidance
                onCardDetected: (CardDetails details) {
                  onCardScanned?.call(details);
                  Navigator.of(context).pop(details);
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onNoCamera: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No camera detected or permission denied'),
                    ),
                  );
                },
              ),
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
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
          if (showGuidance && guidanceText != null && guidanceText!.isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              bottom: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (guidanceIcon != null) ...[
                      Icon(guidanceIcon, color: effectiveColor, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      guidanceText!,
                      style: const TextStyle(
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
