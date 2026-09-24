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
    String? bannerTitle = 'Align Card Inside Viewfinder',
    IconData? bannerIcon = Icons.document_scanner_rounded,
    Color? bannerBackgroundColor,
    Color? bannerTextColor,
    String? guidanceText = 'Align card inside frame',
    IconData? guidanceIcon = Icons.document_scanner_rounded,
    bool showGuidance = true,
    bool showCloseButton = true,
    String closeButtonText = 'Close Overlay',
    IconData closeButtonIcon = Icons.close_rounded,
    Color? closeButtonColor,
    Color? closeButtonTextColor,
    Duration detectionDelay = const Duration(milliseconds: 1100),
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 380),
    Duration reverseTransitionDuration = const Duration(milliseconds: 320),
    ICardScannerService? scannerService,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
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
            bannerTitle: bannerTitle,
            bannerIcon: bannerIcon,
            bannerBackgroundColor: bannerBackgroundColor,
            bannerTextColor: bannerTextColor,
            guidanceText: guidanceText,
            guidanceIcon: guidanceIcon,
            showGuidance: showGuidance,
            showCloseButton: showCloseButton,
            closeButtonText: closeButtonText,
            closeButtonIcon: closeButtonIcon,
            closeButtonColor: closeButtonColor,
            closeButtonTextColor: closeButtonTextColor,
            detectionDelay: detectionDelay,
            scannerService: scannerService,
            onError: onError,
            flightShuttleBuilder:
                flightShuttleBuilder ?? buildHeroFlightShuttle,
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
  static Widget buildHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final isPush = flightDirection == HeroFlightDirection.push;
    final primaryColor = Theme.of(flightContext).colorScheme.primary;
    final containerColor = Theme.of(flightContext).colorScheme.primaryContainer;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = isPush ? animation.value : (1.0 - animation.value);
        final curvedProgress = Curves.easeInOutCubic.transform(progress);

        return Material(
          color: Color.lerp(containerColor, Colors.black, curvedProgress)!,
          borderRadius: BorderRadius.circular(20),
          elevation: 2.0 + (18.0 * curvedProgress),
          shadowColor: Colors.black.withValues(alpha: 0.6),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: Icon(
              Icons.camera_alt_rounded,
              size: 16.0 + (16.0 * curvedProgress),
              color: Color.lerp(
                Theme.of(flightContext).colorScheme.onPrimaryContainer,
                primaryColor,
                curvedProgress,
              )!,
            ),
          ),
        );
      },
    );
  }
}

/// A compact, Hero-animated camera button that triggers [CardCameraOverlayScanner].
class CardScannerHeroButton extends StatelessWidget {
  /// Hero tag linking this button to the overlay viewfinder.
  final Object heroTag;

  /// Callback fired when card details are scanned and Luhn-verified.
  final ValueChanged<CardDetails>? onCardDetected;

  /// Laser and viewfinder accent color.
  final Color? laserColor;

  /// Optional custom child widget (e.g. [Icon], [Text], or custom button widget).
  /// When provided, this widget is wrapped with the scanner tap handler, allowing full
  /// styling freedom from the consuming application. If null, defaults to a standard camera [IconButton].
  final Widget? child;

  /// Custom backdrop scrim color for the overlay. Defaults to black with 72% opacity.
  final Color? overlayColor;

  /// Custom backdrop scrim color (alias for [overlayColor]).
  final Color? barrierColor;

  /// Title displayed in the banner above the camera viewfinder.
  final String? bannerTitle;

  /// Icon displayed in the banner above the camera viewfinder.
  final IconData? bannerIcon;

  /// Guidance text displayed at the bottom of the camera viewfinder.
  final String? guidanceText;

  /// Guidance icon displayed at the bottom of the camera viewfinder.
  final IconData? guidanceIcon;

  /// Whether to show the bottom guidance badge inside the viewfinder.
  final bool showGuidance;

  /// Whether to show the close overlay button below the viewfinder. Defaults to true.
  final bool showCloseButton;

  /// Custom background color for the overlay banner badge.
  final Color? bannerBackgroundColor;

  /// Custom text and icon color for the overlay banner badge.
  final Color? bannerTextColor;

  /// Label text for the overlay close button.
  final String closeButtonText;

  /// Icon for the overlay close button.
  final IconData closeButtonIcon;

  /// Background color for the overlay close button.
  final Color? closeButtonColor;

  /// Text and icon color for the overlay close button.
  final Color? closeButtonTextColor;

  /// Delay duration between Luhn verification and dismiss handoff.
  final Duration detectionDelay;

  /// Optional scanner service instance (used for mock testing simulation).
  final ICardScannerService? scannerService;

  /// Custom hero flight shuttle builder. Defaults to [CardCameraOverlayScanner.buildHeroFlightShuttle].
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  /// Optional callback invoked when the user cancels or closes the overlay.
  final VoidCallback? onCancel;

  /// Optional callback invoked when camera error or no camera is detected.
  final ValueChanged<String>? onError;

  const CardScannerHeroButton({
    super.key,
    this.child,
    this.heroTag = CardCameraOverlayScanner.defaultHeroTag,
    this.onCardDetected,
    this.laserColor,
    this.overlayColor,
    this.barrierColor,
    this.bannerTitle = 'Align Card Inside Viewfinder',
    this.bannerIcon = Icons.document_scanner_rounded,
    this.bannerBackgroundColor,
    this.bannerTextColor,
    this.guidanceText = 'Align card inside frame',
    this.guidanceIcon = Icons.document_scanner_rounded,
    this.showGuidance = true,
    this.showCloseButton = true,
    this.closeButtonText = 'Close Overlay',
    this.closeButtonIcon = Icons.close_rounded,
    this.closeButtonColor,
    this.closeButtonTextColor,
    this.detectionDelay = const Duration(milliseconds: 1100),
    this.scannerService,
    this.flightShuttleBuilder,
    this.onCancel,
    this.onError,
  });

  Future<void> _handleTap(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final result = await CardCameraOverlayScanner.show(
      context,
      heroTag: heroTag,
      laserColor: laserColor ?? colors.primary,
      overlayColor: overlayColor,
      barrierColor: barrierColor,
      bannerTitle: bannerTitle,
      bannerIcon: bannerIcon,
      bannerBackgroundColor: bannerBackgroundColor,
      bannerTextColor: bannerTextColor,
      guidanceText: guidanceText,
      guidanceIcon: guidanceIcon,
      showGuidance: showGuidance,
      showCloseButton: showCloseButton,
      closeButtonText: closeButtonText,
      closeButtonIcon: closeButtonIcon,
      closeButtonColor: closeButtonColor,
      closeButtonTextColor: closeButtonTextColor,
      detectionDelay: detectionDelay,
      scannerService: scannerService,
      flightShuttleBuilder: flightShuttleBuilder,
      onError: onError,
    );
    if (result != null) {
      onCardDetected?.call(result);
    } else {
      onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final Widget buttonWidget = child != null
        ? InkResponse(
            onTap: () => _handleTap(context),
            highlightShape: BoxShape.circle,
            child: child,
          )
        : IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            color: colors.primary,
            onPressed: () => _handleTap(context),
          );

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: flightShuttleBuilder ??
          CardCameraOverlayScanner.buildHeroFlightShuttle,
      child: buttonWidget,
    );
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

  /// Whether to show the close overlay button below the viewfinder. Defaults to true.
  final bool showCloseButton;

  /// Optional banner text shown above the viewfinder.
  final String? bannerTitle;

  /// Icon displayed inside the top banner badge.
  final IconData? bannerIcon;

  /// Custom background color for the banner badge.
  final Color? bannerBackgroundColor;

  /// Custom text and icon color for the banner badge.
  final Color? bannerTextColor;

  /// Label text for the overlay close button.
  final String closeButtonText;

  /// Icon for the overlay close button.
  final IconData closeButtonIcon;

  /// Custom background color for the close button.
  final Color? closeButtonColor;

  /// Custom text and icon color for the close button.
  final Color? closeButtonTextColor;

  /// Delay duration between Luhn verification and dismiss handoff.
  final Duration detectionDelay;

  /// Optional scanner service instance (used for test mock simulation).
  final ICardScannerService? scannerService;

  /// Custom flight shuttle builder.
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

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
    this.showCloseButton = true,
    this.bannerTitle = 'Align Card Inside Viewfinder',
    this.bannerIcon = Icons.document_scanner_rounded,
    this.bannerBackgroundColor,
    this.bannerTextColor,
    this.closeButtonText = 'Close Overlay',
    this.closeButtonIcon = Icons.close_rounded,
    this.closeButtonColor,
    this.closeButtonTextColor,
    this.detectionDelay = const Duration(milliseconds: 1100),
    this.scannerService,
    this.flightShuttleBuilder,
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
                  // Top Guidance Badge
                  if (bannerTitle != null && bannerTitle!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bannerBackgroundColor ??
                            Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (bannerTextColor ?? Colors.white).withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            bannerIcon ?? Icons.document_scanner_rounded,
                            size: 16,
                            color: laserColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bannerTitle!,
                            style: TextStyle(
                              color: bannerTextColor ?? Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (bannerTitle != null && bannerTitle!.isNotEmpty)
                    const SizedBox(height: 18),

                  // Hero-wrapped Embedded Card Camera Viewfinder
                  Hero(
                    tag: heroTag,
                    flightShuttleBuilder: flightShuttleBuilder ??
                        CardCameraOverlayScanner.buildHeroFlightShuttle,
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
                          detectionDelay: detectionDelay,
                          onCardDetected: onCardDetected,
                          onCancel: onCancel,
                          onNoCamera: () {
                            onCancel();
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
                    TextButton.icon(
                      key: const ValueKey('close_camera_overlay_button'),
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: closeButtonTextColor ?? Colors.white,
                        backgroundColor: closeButtonColor ??
                            Colors.white.withValues(alpha: 0.14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      icon: Icon(closeButtonIcon, size: 18),
                      label: Text(
                        closeButtonText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
