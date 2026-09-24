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

/// An in-place camera viewfinder sized precisely to a credit card rectangle (330x184).
/// Captures camera frames and performs on-device OCR using Apple Vision (iOS)
/// and Google ML Kit (Android) without opening a separate full-screen page.
class EmbeddedCardCamera extends StatefulWidget {
  const EmbeddedCardCamera({
    super.key,
    required this.onCardDetected,
    required this.onCancel,
    this.onNoCamera,
  });

  /// Called when a Luhn-verified card is detected and parsed.
  final ValueChanged<CardDetails> onCardDetected;

  /// Called when the user cancels or closes the embedded camera.
  final VoidCallback onCancel;

  /// Called if no physical camera is detected on the device (e.g. simulator).
  final VoidCallback? onNoCamera;

  @override
  State<EmbeddedCardCamera> createState() => _EmbeddedCardCameraState();
}

class _EmbeddedCardCameraState extends State<EmbeddedCardCamera>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  final _appleVision = apple.AppleVisionRecognizeTextController();
  final _mlTextRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isInitializing = true;
  bool _isProcessingFrame = false;
  bool _hasDetectedCard = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOutSine),
    );

    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _laserController.dispose();
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

      if (Platform.isIOS) {
        final List<int> bytes = image.planes
            .expand((plane) => plane.bytes)
            .toList();

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
            image: Uint8List.fromList(bytes),
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
        final List<int> bytes = image.planes
            .expand((plane) => plane.bytes)
            .toList();

        final inputImage = InputImage.fromBytes(
          bytes: Uint8List.fromList(bytes),
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
          HapticFeedback.mediumImpact();
          if (mounted) {
            widget.onCardDetected(parsed);
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
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
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 330,
                  height: _cameraController!.value.previewSize?.width ?? 184,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else if (_isInitializing)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // 2. Corner Viewfinder Brackets
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CardViewfinderCornerPainter(
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            ),

            // 3. Futuristic Laser Scanner Sweep Line
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _laserAnimation,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment(0, (_laserAnimation.value * 2) - 1),
                      child: Container(
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0.1),
                              Colors.cyanAccent,
                              Colors.white,
                              Colors.cyanAccent,
                              Colors.cyanAccent.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.9),
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

            // 4. Cancel / Close Camera Button (Top Right)
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

            // 5. Guidance Label at Bottom
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.cyanAccent,
                          size: 12,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Align card inside frame',
                          style: TextStyle(
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
        ),
      ),
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
  bool shouldRepaint(covariant _CardViewfinderCornerPainter oldDelegate) =>
      color != oldDelegate.color;
}
