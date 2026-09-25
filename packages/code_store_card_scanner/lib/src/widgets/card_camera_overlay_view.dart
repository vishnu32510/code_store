import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/card_details.dart';
import '../models/card_type.dart';
import '../services/card_scanner_service.dart';
import '../services/i_card_scanner_service.dart';
import 'embedded_card_camera.dart';

/// Helper and presentation controller for opening the credit card camera
/// scanner as a non-opaque overlay with a smooth Hero flight animation.
class CardCameraOverlayScanner {
  /// Default Hero tag used to animate between the trigger button and overlay.
  static const String defaultHeroTag = 'embedded_card_camera_scanner_hero';

  /// Launches the overlay camera scanner with a smooth Hero flight animation.
  /// Returns the Luhn-verified [CardDetails] if scanned, or `null` if cancelled.
  static Future<CardDetails?> show(
    BuildContext context, {
    Object heroTag = defaultHeroTag,
    Color? laserColor,
    Color? overlayColor,
    Color? barrierColor,
    String? guidanceText = 'Align card inside frame',
    IconData? guidanceIcon = Icons.document_scanner_rounded,
    bool showGuidance = true,
    bool showLaser = true,
    bool showCardDesign = true,
    bool showCloseButton = true,
    Widget? closeButton,
    Duration detectionDelay = const Duration(milliseconds: 1100),
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 320),
    ICardScannerService? scannerService,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    Widget? shuttleChild,
    IconData? shuttleIcon,
    ValueChanged<String>? onError,
  }) {
    FocusScope.of(context).unfocus();

    final effectiveScrimColor =
        overlayColor ?? barrierColor ?? Colors.black.withValues(alpha: 0.72);

    return Navigator.of(context).push<CardDetails>(
      PageRouteBuilder<CardDetails>(
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: effectiveScrimColor,
        barrierLabel: 'Dismiss Scanner',
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        pageBuilder: (overlayContext, animation, secondaryAnimation) {
          return CardCameraOverlayView(
            heroTag: heroTag,
            laserColor: laserColor ?? Theme.of(context).colorScheme.primary,
            guidanceText: guidanceText,
            guidanceIcon: guidanceIcon,
            showGuidance: showGuidance,
            showLaser: showLaser,
            showCardDesign: showCardDesign,
            showCloseButton: showCloseButton,
            closeButton: closeButton,
            detectionDelay: detectionDelay,
            scannerService: scannerService,
            onError: onError,
            flightShuttleBuilder: flightShuttleBuilder,
            shuttleChild: shuttleChild,
            shuttleIcon: shuttleIcon,
            onCardDetected: (details) {
              Navigator.of(overlayContext).pop(details);
            },
            onCancel: () {
              Navigator.of(overlayContext).pop();
            },
          );
        },
      ),
    );
  }

  /// Default morphing flight shuttle builder between source button and camera card.
  /// Smoothly animates colors, elevation, border radius, and icon size.
  ///
  /// Optionally accepts [shuttleChild] or [shuttleIcon] to customize the widget/icon
  /// flying mid-air (defaults to [Icons.camera_alt_rounded]).
  static Widget buildHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext, {
    Widget? shuttleChild,
    IconData? shuttleIcon,
  }) {
    final isPush = flightDirection == HeroFlightDirection.push;
    final primaryColor = Theme.of(flightContext).colorScheme.primary;
    final containerColor = Theme.of(flightContext).colorScheme.primaryContainer;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = isPush ? animation.value : (1.0 - animation.value);
        final curvedProgress = Curves.easeInOutCubic.transform(progress);
        final iconColor = Color.lerp(
          Theme.of(flightContext).colorScheme.onPrimaryContainer,
          primaryColor,
          curvedProgress,
        )!;

        final Widget innerWidget;
        if (shuttleChild != null) {
          innerWidget = Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: 20.0 + (12.0 * curvedProgress),
                color: iconColor,
              ),
              child: Transform.scale(
                scale: 1.0 + (0.2 * curvedProgress),
                child: shuttleChild,
              ),
            ),
          );
        } else {
          innerWidget = Center(
            child: Icon(
              shuttleIcon ?? Icons.camera_alt_rounded,
              size: 16.0 + (16.0 * curvedProgress),
              color: iconColor,
            ),
          );
        }

        return Material(
          color: Color.lerp(containerColor, Colors.black, curvedProgress)!,
          borderRadius: BorderRadius.circular(20),
          elevation: 2.0 + (18.0 * curvedProgress),
          shadowColor: Colors.black.withValues(alpha: 0.6),
          clipBehavior: Clip.antiAlias,
          child: innerWidget,
        );
      },
    );
  }

  /// Creates a [HeroFlightShuttleBuilder] configured with the specified [shuttleChild]
  /// or [shuttleIcon].
  static HeroFlightShuttleBuilder createHeroFlightShuttle({
    Widget? shuttleChild,
    IconData? shuttleIcon,
  }) {
    return (flightContext, animation, flightDirection, fromHeroContext,
        toHeroContext) {
      return buildHeroFlightShuttle(
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
        shuttleChild: shuttleChild,
        shuttleIcon: shuttleIcon,
      );
    };
  }
}

/// The visual overlay content showing the [EmbeddedCardCamera] wrapped in a [Hero].
class CardCameraOverlayView extends StatelessWidget {
  /// Hero tag matching the trigger button's tag.
  final Object heroTag;

  /// Laser beam and viewfinder accent color.
  final Color laserColor;

  /// Bottom guidance text shown inside the viewfinder.
  final String? guidanceText;

  /// Icon displayed next to bottom guidance text.
  final IconData? guidanceIcon;

  /// Whether to show the bottom guidance badge inside the viewfinder.
  final bool showGuidance;

  /// Whether to display and animate the laser sweep line. Defaults to true.
  final bool showLaser;

  /// Whether to display decorative credit card graphics upon detection. Defaults to true.
  final bool showCardDesign;

  /// Whether to show the close overlay button below the viewfinder. Defaults to true.
  final bool showCloseButton;

  /// Optional custom widget for the close button. If provided, wrapped with dismiss handler.
  final Widget? closeButton;

  /// Delay duration between Luhn verification and dismiss handoff.
  final Duration detectionDelay;

  /// Optional scanner service instance (used for test mock simulation).
  final ICardScannerService? scannerService;

  /// Custom flight shuttle builder.
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  /// Optional custom child widget shown during the Hero transition flight.
  final Widget? shuttleChild;

  /// Optional custom icon displayed during the Hero transition flight.
  final IconData? shuttleIcon;

  /// Optional callback invoked when camera error or no camera is detected.
  final ValueChanged<String>? onError;

  /// Callback when a card is detected.
  final ValueChanged<CardDetails> onCardDetected;

  /// Callback when the overlay is dismissed/cancelled.
  final VoidCallback onCancel;

  const CardCameraOverlayView({
    super.key,
    required this.heroTag,
    required this.laserColor,
    this.guidanceText = 'Align card inside frame',
    this.guidanceIcon = Icons.document_scanner_rounded,
    this.showGuidance = true,
    this.showLaser = true,
    this.showCardDesign = true,
    this.showCloseButton = true,
    this.closeButton,
    this.detectionDelay = const Duration(milliseconds: 1100),
    this.scannerService,
    this.flightShuttleBuilder,
    this.shuttleChild,
    this.shuttleIcon,
    this.onError,
    required this.onCardDetected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss when tapping outside the viewfinder card
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCancel,
              child: const SizedBox.expand(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hero-wrapped Embedded Card Camera Viewfinder
                  Hero(
                    tag: heroTag,
                    flightShuttleBuilder: flightShuttleBuilder ??
                        CardCameraOverlayScanner.createHeroFlightShuttle(
                          shuttleChild: shuttleChild,
                          shuttleIcon: shuttleIcon,
                        ),
                    child: Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      elevation: 20,
                      shadowColor: Colors.black.withValues(alpha: 0.65),
                      child: Container(
                        width: 340,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: laserColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: EmbeddedCardCamera(
                          key: const ValueKey('overlay_embedded_card_camera'),
                          laserColor: laserColor,
                          guidanceText: guidanceText,
                          guidanceIcon: guidanceIcon,
                          showGuidance: showGuidance,
                          showLaser: showLaser,
                          showCardDesign: showCardDesign,
                          detectionDelay: detectionDelay,
                          onCardDetected: onCardDetected,
                          onCancel: onCancel,
                          onNoCamera: () {
                            onError?.call(
                              'No camera found on this device or permission denied',
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (showCloseButton) const SizedBox(height: 20),

                  // Close button
                  if (showCloseButton)
                    closeButton != null
                        ? InkResponse(
                            key: const ValueKey('close_camera_overlay_button'),
                            onTap: onCancel,
                            child: closeButton,
                          )
                        : IconButton(
                            key: const ValueKey('close_camera_overlay_button'),
                            onPressed: onCancel,
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.14),
                            ),
                          ),

                  // Mock simulator or Web demo button
                  if (kIsWeb ||
                      (scannerService != null &&
                          scannerService is! CardScannerService))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: FilledButton.tonalIcon(
                        key: const ValueKey('mock_detect_overlay_card_button'),
                        onPressed: () async {
                          if (scannerService != null &&
                              scannerService is! CardScannerService) {
                            final res = await scannerService!.scanCard();
                            if (res.success && res.cardDetails != null) {
                              onCardDetected(res.cardDetails!);
                            }
                          } else {
                            onCardDetected(
                              const CardDetails(
                                cardNumber: '4532015112830366',
                                cardHolderName: 'WEB CAMERA USER',
                                expiryMonth: 12,
                                expiryYear: 28,
                                cvv: '999',
                                cardType: CardType.visa,
                                isValidNumber: true,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: Text(
                          kIsWeb
                              ? 'Capture & Apply Card (Web Demo)'
                              : 'Simulate Card Detection (Mock)',
                        ),
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
