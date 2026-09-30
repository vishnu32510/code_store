import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/splash_config.dart';
import '../models/splash_result.dart';
import '../services/i_splash_service.dart';
import '../services/splash_service.dart';
import 'animated_splash_logo.dart';
import 'splash_footer_logo.dart';

/// Full-screen splash view seamlessly bridging native launch screen to Flutter,
/// coordinating logo animation, footer branding, and audio playback.
class NativeSplashView extends StatefulWidget {
  const NativeSplashView({
    super.key,
    required this.config,
    this.service,
    this.onResult,
  });

  /// Splash configuration governing assets, animations, timings, and audio.
  final SplashConfig config;

  /// Optional splash service instance. Defaults to registered DI singleton or [SplashService].
  final ISplashService? service;

  /// Optional callback receiving diagnostic metrics upon completion.
  final ValueChanged<SplashResult>? onResult;

  @override
  State<NativeSplashView> createState() => _NativeSplashViewState();
}

class _NativeSplashViewState extends State<NativeSplashView> {
  late final Stopwatch _stopwatch;
  Timer? _stayTimer;
  bool _isFinished = false;

  ISplashService? _localService;

  ISplashService get _service {
    if (widget.service != null) return widget.service!;
    if (GetIt.instance.isRegistered<ISplashService>()) {
      return GetIt.instance<ISplashService>();
    }
    // Seamless fallback for apps not using GetIt
    return _localService ??= SplashService();
  }

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _initializeSequence();
  }

  @override
  void dispose() {
    _stayTimer?.cancel();
    _localService?.dispose();
    super.dispose();
  }

  bool _audioTriggered = false;

  void _triggerAudioChime() {
    if (_audioTriggered) return;
    if (widget.config.audioConfig != null &&
        widget.config.audioConfig!.enabled) {
      _audioTriggered = true;
      unawaited(_service.playChime(config: widget.config.audioConfig!));
    }
  }

  Future<void> _initializeSequence() async {
    // 1. Remove native OS splash screen once Flutter mounts:
    if (widget.config.removeNativeSplashOnMount) {
      _service.remove();
    }

    // 2. Trigger audio chime if configured:
    _triggerAudioChime();

    // 3. Run parallel async initialization and minimum stay timer:
    String? initializationError;
    final stayCompleter = Completer<void>();
    _stayTimer = Timer(widget.config.stayDuration, () {
      if (!stayCompleter.isCompleted) stayCompleter.complete();
    });

    final futures = <Future<void>>[stayCompleter.future];

    if (widget.config.onInit != null) {
      futures.add(
        widget.config.onInit!().catchError((Object e) {
          initializationError = e.toString();
        }),
      );
    }

    try {
      await Future.wait(futures);
    } catch (_) {
      // Handled in initializationError
    }

    if (!mounted || _isFinished) return;
    _isFinished = true;
    _stopwatch.stop();

    final result = initializationError == null
        ? SplashResult.success(_stopwatch.elapsed)
        : SplashResult.failure(initializationError!, _stopwatch.elapsed);

    widget.onResult?.call(result);
    widget.config.onFinished?.call();

    // 4. Navigate to next route if provided:
    if (widget.config.nextRoute != null && mounted) {
      try {
        Navigator.of(context).pushReplacementNamed(widget.config.nextRoute!);
      } catch (e) {
        debugPrint(
          'NativeSplashView: Navigation via pushReplacementNamed skipped ($e)',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark && widget.config.darkBackgroundColor != null
        ? widget.config.darkBackgroundColor!
        : widget.config.backgroundColor;

    final isBgDark = bgColor.computeLuminance() < 0.5;

    final effectiveLogoAsset = (isDark && widget.config.darkLogoAsset != null)
        ? widget.config.darkLogoAsset!
        : widget.config.logoAsset;

    final effectiveFooterLogoAsset =
        (isDark && widget.config.darkFooterLogoAsset != null)
        ? widget.config.darkFooterLogoAsset!
        : widget.config.footerLogoAsset;

    final effectiveFooterTextColor =
        (isDark && widget.config.darkFooterTextColor != null)
        ? widget.config.darkFooterTextColor
        : (widget.config.footerTextColor ??
              (isBgDark ? Colors.white70 : Colors.black54));

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _triggerAudioChime(),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Centered Main Logo (with or without animation):
            Center(
              child: AnimatedSplashLogo(
                logoAsset: effectiveLogoAsset,
                logoWidget: widget.config.logoWidget,
                size: widget.config.logoSize,
                animationType: widget.config.animationType,
                duration: widget.config.animationDuration,
              ),
            ),

            // Optional Footer Logo / Branding:
            if (widget.config.hasFooter)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.config.footerBottomPadding,
                    ),
                    child: SplashFooterLogo(
                      footerLogoAsset: effectiveFooterLogoAsset,
                      footerLogoWidget: widget.config.footerLogoWidget,
                      footerText: widget.config.footerText,
                      footerLogoHeight: widget.config.footerLogoHeight,
                      textColor: effectiveFooterTextColor,
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
