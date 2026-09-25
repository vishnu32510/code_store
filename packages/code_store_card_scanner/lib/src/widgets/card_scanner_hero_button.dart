import 'package:flutter/material.dart';

import '../models/card_details.dart';
import '../services/i_card_scanner_service.dart';
import 'card_camera_overlay_view.dart';

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

  /// Guidance text displayed at the bottom of the camera viewfinder.
  final String? guidanceText;

  /// Guidance icon displayed at the bottom of the camera viewfinder.
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

  /// Optional scanner service instance (used for mock testing simulation).
  final ICardScannerService? scannerService;

  /// Custom hero flight shuttle builder. Defaults to [CardCameraOverlayScanner.createHeroFlightShuttle].
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  /// Optional custom child widget shown during the Hero transition flight.
  /// If null and [flightShuttleBuilder] is null, defaults to [child].
  final Widget? shuttleChild;

  /// Optional custom icon displayed during the Hero transition flight.
  final IconData? shuttleIcon;

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
    this.onCancel,
    this.onError,
  });

  Future<void> _handleTap(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final effectiveShuttleChild = shuttleChild ?? child;
    final result = await CardCameraOverlayScanner.show(
      context,
      heroTag: heroTag,
      laserColor: laserColor ?? colors.primary,
      overlayColor: overlayColor,
      barrierColor: barrierColor,
      guidanceText: guidanceText,
      guidanceIcon: guidanceIcon,
      showGuidance: showGuidance,
      showLaser: showLaser,
      showCardDesign: showCardDesign,
      showCloseButton: showCloseButton,
      closeButton: closeButton,
      detectionDelay: detectionDelay,
      scannerService: scannerService,
      flightShuttleBuilder: flightShuttleBuilder,
      shuttleChild: effectiveShuttleChild,
      shuttleIcon: shuttleIcon,
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

    final effectiveFlightShuttleBuilder = flightShuttleBuilder ??
        CardCameraOverlayScanner.createHeroFlightShuttle(
          shuttleChild: shuttleChild ?? child,
          shuttleIcon: shuttleIcon,
        );

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: effectiveFlightShuttleBuilder,
      child: buttonWidget,
    );
  }
}
