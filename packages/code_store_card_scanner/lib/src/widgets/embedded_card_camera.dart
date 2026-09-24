import 'dart:io';

import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart'
    as apple;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/card_details.dart';
import '../utils/card_ocr_parser.dart';
import 'card_brand_icon.dart';

/// An in-place camera viewfinder sized precisely to a credit card rectangle (330x184).
/// Captures camera frames and performs on-device OCR using Apple Vision (iOS)
/// and Google ML Kit (Android) without opening a separate full-screen page.
///
/// When a card is recognized, features a smooth delay and choreographed hero
/// flight animation where the detected card number, expiry, and cardholder name
/// animate smoothly into their exact physical card positions before closing.
class EmbeddedCardCamera extends StatefulWidget {
  const EmbeddedCardCamera({
    super.key,
    required this.onCardDetected,
    required this.onCancel,
    this.onNoCamera,
    this.detectionDelay = const Duration(milliseconds: 1100),
    this.laserColor,
    this.guidanceText = 'Align card inside frame',
    this.guidanceIcon = Icons.document_scanner_rounded,
    this.showGuidance = true,
  });

  /// Called when a Luhn-verified card is detected and parsed.
  final ValueChanged<CardDetails> onCardDetected;

  /// Called when the user cancels or closes the embedded camera.
  final VoidCallback onCancel;

  /// Called if no physical camera is detected on the device (e.g. simulator).
  final VoidCallback? onNoCamera;

  /// Smooth delay between card detection and closing, allowing hero transition
  /// to animate the detected card number, expiry, and name into position.
  final Duration detectionDelay;

  /// The primary laser and viewfinder accent color.
  /// Defaults to [Colors.cyanAccent] if not specified.
  final Color? laserColor;

  /// Optional guidance text shown at the bottom of the viewfinder.
  /// Defaults to 'Align card inside frame'.
  final String? guidanceText;

  /// Optional icon displayed alongside the guidance text.
  /// Defaults to [Icons.document_scanner_rounded].
  final IconData? guidanceIcon;

  /// Whether to display the bottom guidance badge. Defaults to true.
  final bool showGuidance;

  @override
  State<EmbeddedCardCamera> createState() => _EmbeddedCardCameraState();
}

class _EmbeddedCardCameraState extends State<EmbeddedCardCamera>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  final _appleVision = apple.AppleVisionRecognizeTextController();
  final _mlTextRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  late final AnimationController _successController;
  late final Animation<double> _borderGlowAnimation;
  late final Animation<double> _overlayFadeAnimation;
  late final Animation<double> _numberScaleAnimation;
  late final Animation<Offset> _numberSlideAnimation;
  late final Animation<double> _cardDetailsFadeAnimation;
  late final Animation<Offset> _bottomElementsSlideAnimation;

  CardDetails? _detectedDetails;
  bool _isSuccessTransition = false;
  bool _isInitializing = true;
  bool _isProcessingFrame = false;
  bool _hasDetectedCard = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Futuristic laser sweep animation
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOutSine),
    );

    // 2. Choreographed Hero Detection & Transition Animation
    _successController = AnimationController(
      vsync: this,
      duration: widget.detectionDelay,
    );

    _borderGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _overlayFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _numberScaleAnimation = Tween<double>(begin: 1.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.12, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _numberSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.32), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _successController,
            curve: const Interval(0.12, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _cardDetailsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _bottomElementsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.38), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _successController,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _laserController.dispose();
    _successController.dispose();
    _cameraController?.dispose();
    _mlTextRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          widget.onNoCamera?.call();
        }
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      _cameraController = controller;
      await controller.initialize();

      if (!mounted) return;

      setState(() => _isInitializing = false);

      await controller.startImageStream((CameraImage image) {
        _processCameraImage(image, backCamera);
      });
    } catch (e) {
      debugPrint('EmbeddedCardCamera: initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
        widget.onNoCamera?.call();
      }
    }
  }

  Future<void> _processCameraImage(
    CameraImage image,
    CameraDescription description,
  ) async {
    if (_isProcessingFrame || _hasDetectedCard) return;
    _isProcessingFrame = true;

    try {
      final InputImageRotation rotation =
          InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final List<String> rawLines = [];

      // Extract image bytes efficiently: zero-copy if single plane (iOS BGRA8888),
      // or fast contiguous buffer fill if multiple planes (Android NV21/YUV420).
      final Uint8List imageBytes;
      if (image.planes.length == 1) {
        imageBytes = image.planes[0].bytes;
      } else {
        final int totalLength = image.planes.fold(
          0,
          (sum, plane) => sum + plane.bytes.length,
        );
        final Uint8List combined = Uint8List(totalLength);
        int offset = 0;
        for (final plane in image.planes) {
          combined.setRange(offset, offset + plane.bytes.length, plane.bytes);
          offset += plane.bytes.length;
        }
        imageBytes = combined;
      }

      if (Platform.isIOS) {
        final ImageOrientation appleOrient;
        switch (rotation) {
          case InputImageRotation.rotation0deg:
            appleOrient = ImageOrientation.up;
            break;
          case InputImageRotation.rotation90deg:
            appleOrient = ImageOrientation.right;
            break;
          case InputImageRotation.rotation180deg:
            appleOrient = ImageOrientation.down;
            break;
          case InputImageRotation.rotation270deg:
            appleOrient = ImageOrientation.left;
            break;
        }

        final results = await _appleVision.processImage(
          apple.RecognizeTextData(
            automaticallyDetectsLanguage: false,
            languages: [const Locale('en', 'US')],
            recognitionLevel: apple.RecognitionLevel.accurate,
            image: imageBytes,
            orientation: appleOrient,
            imageSize: Size(image.width.toDouble(), image.height.toDouble()),
          ),
        );

        if (results != null) {
          for (final item in results) {
            for (final line in item.listText) {
              if (line.trim().isNotEmpty) rawLines.add(line.trim());
            }
          }
        }
      } else {
        final inputImage = InputImage.fromBytes(
          bytes: imageBytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final textR = await _mlTextRecognizer.processImage(inputImage);
        for (final block in textR.blocks) {
          for (final line in block.lines) {
            if (line.text.trim().isNotEmpty) rawLines.add(line.text.trim());
          }
        }
      }

      if (rawLines.isNotEmpty) {
        final parsed = CardOcrParser.parseRecognizedLines(rawLines);
        if (parsed.isValidNumber && !_hasDetectedCard) {
          _hasDetectedCard = true;
          _detectedDetails = parsed;
          _isSuccessTransition = true;
          _laserController.stop();
          HapticFeedback.heavyImpact();

          if (mounted) {
            setState(() {});
            // 1. Play the choreographed flight animation (1100ms)
            await _successController.forward();
            // 2. Intentional satisfying settling pause (200ms)
            await Future.delayed(const Duration(milliseconds: 200));
            // 3. Complete and hand off to main card screen
            if (mounted) {
              widget.onCardDetected(parsed);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('EmbeddedCardCamera: frame processing error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLaserColor = widget.laserColor ?? Colors.cyanAccent;

    return AnimatedBuilder(
      animation: _successController,
      builder: (context, _) {
        final borderColor = Color.lerp(
          effectiveLaserColor.withValues(alpha: 0.6),
          const Color(0xFF00E676),
          _borderGlowAnimation.value,
        )!;

        final glowColor = Color.lerp(
          effectiveLaserColor.withValues(alpha: 0.25),
          const Color(0xFF00E676).withValues(alpha: 0.55),
          _borderGlowAnimation.value,
        )!;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5 + (0.5 * _borderGlowAnimation.value),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 16 + (8 * _borderGlowAnimation.value),
                spreadRadius: 1 + (1.5 * _borderGlowAnimation.value),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Live Camera Feed scaled nicely to fill the credit card rectangle
                if (!_isInitializing &&
                    _cameraController != null &&
                    _cameraController!.value.isInitialized)
                  RepaintBoundary(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width:
                            _cameraController!.value.previewSize?.height ?? 330,
                        height:
                            _cameraController!.value.previewSize?.width ?? 184,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                else if (_isInitializing)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: effectiveLaserColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Starting Camera...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _errorMessage ?? 'Camera Unavailable',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // 2. Card Brand Morph Scrim (Fades in over camera upon detection)
                if (_isSuccessTransition && _detectedDetails != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (_detectedDetails!.cardType.gradientColors.first)
                                .withValues(
                                  alpha: 0.82 * _overlayFadeAnimation.value,
                                ),
                            (_detectedDetails!.cardType.gradientColors.last)
                                .withValues(
                                  alpha: 0.90 * _overlayFadeAnimation.value,
                                ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                // 3. Normal Scanning Overlays (viewfinder corners, laser, cancel button, helper)
                if (!_isSuccessTransition) ...[
                  // Corner Viewfinder Brackets
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CardViewfinderCornerPainter(
                            color: effectiveLaserColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Futuristic Laser Scanner Sweep Line
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, _) {
                            return Align(
                              alignment: Alignment(
                                0,
                                (_laserAnimation.value * 2) - 1,
                              ),
                              child: Container(
                                height: 3,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      effectiveLaserColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      effectiveLaserColor,
                                      Colors.white,
                                      effectiveLaserColor,
                                      effectiveLaserColor.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: effectiveLaserColor.withValues(
                                        alpha: 0.9,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Cancel / Close Camera Button (Top Right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onCancel,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Guidance Label at Bottom
                  if (widget.showGuidance &&
                      widget.guidanceText != null &&
                      widget.guidanceText!.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.guidanceIcon != null) ...[
                                  Icon(
                                    widget.guidanceIcon,
                                    color: effectiveLaserColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  widget.guidanceText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // 4. Success State Overlays & Hero Transitions
                if (_isSuccessTransition && _detectedDetails != null) ...[
                  // Top Pill: Card Verified Badge
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FadeTransition(
                        opacity: _borderGlowAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676)
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF00E676),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF00E676),
                                size: 12,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'CARD VERIFIED (LUHN PASSED)',
                                style: TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top Left: EMV Chip & Contactless (fading in at physical card position)
                  Positioned(
                    top: 15,
                    left: 18,
                    child: FadeTransition(
                      opacity: _cardDetailsFadeAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 26,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 26,
                                height: 17,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.brown.withValues(alpha: 0.5),
                                    width: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.contactless_rounded,
                            color: Colors.white70,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Right: Detected Card Brand Badge
                  Positioned(
                    top: 15,
                    right: 18,
                    child: FadeTransition(
                      opacity: _cardDetailsFadeAnimation,
                      child: CardBrandIcon(
                        cardType: _detectedDetails!.cardType,
                        width: 46,
                        height: 28,
                      ),
                    ),
                  ),

                  // Center: HERO Animation for Detected Card Number
                  Align(
                    alignment: Alignment.center,
                    child: SlideTransition(
                      position: _numberSlideAnimation,
                      child: ScaleTransition(
                        scale: _numberScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: 0.45 * (1.0 - _borderGlowAnimation.value),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E676).withValues(
                                alpha: 0.7 * (1.0 - _borderGlowAnimation.value),
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _detectedDetails!.formattedNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              shadows: [
                                Shadow(
                                  color: Color(0xFF00E676),
                                  blurRadius: 10,
                                ),
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Row: HERO Animation for Cardholder Name and Expiry
                  Positioned(
                    bottom: 15,
                    left: 18,
                    right: 18,
                    child: SlideTransition(
                      position: _bottomElementsSlideAnimation,
                      child: FadeTransition(
                        opacity: _cardDetailsFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'CARDHOLDER',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 8,
                                      letterSpacing: 1.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 1.5),
                                  Text(
                                    _detectedDetails!.cardHolderName.isEmpty
                                        ? 'CARDHOLDER NAME'
                                        : _detectedDetails!.cardHolderName
                                              .toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'EXPIRES',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 8,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1.5),
                                Text(
                                  _detectedDetails!.formattedExpiry.isEmpty
                                      ? 'MM/YY'
                                      : _detectedDetails!.formattedExpiry,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardViewfinderCornerPainter extends CustomPainter {
  const _CardViewfinderCornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;
    const padding = 10.0;

    // Top-left
    canvas.drawLine(
      const Offset(padding, padding + cornerLength),
      const Offset(padding, padding),
      paint,
    );
    canvas.drawLine(
      const Offset(padding, padding),
      const Offset(padding + cornerLength, padding),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - padding - cornerLength, padding),
      Offset(size.width - padding, padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding, padding + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(padding, size.height - padding - cornerLength),
      Offset(padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding + cornerLength, size.height - padding),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - padding - cornerLength, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding, size.height - padding - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CardViewfinderCornerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
