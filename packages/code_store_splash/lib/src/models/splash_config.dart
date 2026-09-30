import 'package:flutter/material.dart';

import 'splash_animation_type.dart';
import 'splash_audio_config.dart';

/// Comprehensive configuration for the native and animated splash screen.
@immutable
class SplashConfig {
  const SplashConfig({
    required this.logoAsset,
    this.darkLogoAsset,
    this.logoWidget,
    this.logoSize = 120.0,
    this.animationType = SplashAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.stayDuration = const Duration(milliseconds: 1800),
    this.backgroundColor = Colors.white,
    this.darkBackgroundColor,
    this.footerLogoAsset,
    this.darkFooterLogoAsset,
    this.footerLogoWidget,
    this.footerText,
    this.footerTextColor,
    this.darkFooterTextColor,
    this.footerLogoHeight = 36.0,
    this.footerBottomPadding = 32.0,
    this.audioConfig,
    this.onInit,
    this.onFinished,
    this.nextRoute,
    this.removeNativeSplashOnMount = true,
  });

  /// Path to the main logo image asset (e.g. 'assets/icon/app_icon.png').
  final String logoAsset;

  /// Optional path to dark theme main logo image asset.
  final String? darkLogoAsset;

  /// Optional custom widget to display instead of [logoAsset].
  final Widget? logoWidget;

  /// Width and height dimension for the centered logo.
  final double logoSize;

  /// Animation style applied to the logo (set to [SplashAnimationType.none] for a static splash).
  final SplashAnimationType animationType;

  /// Duration of the logo entrance animation.
  final Duration animationDuration;

  /// Minimum duration the splash screen remains visible before transitioning.
  final Duration stayDuration;

  /// Light theme background color matching the native launch background.
  final Color backgroundColor;

  /// Optional dark theme background color matching the native dark launch background.
  final Color? darkBackgroundColor;

  /// Optional path to the bottom footer/branding logo image asset (e.g. 'assets/icon/branding.png').
  final String? footerLogoAsset;

  /// Optional path to dark theme footer/branding logo image asset.
  final String? darkFooterLogoAsset;

  /// Optional custom footer widget (e.g. custom text, icon, or row).
  final Widget? footerLogoWidget;

  /// Optional secondary footer text displayed beneath or next to the footer logo.
  final String? footerText;

  /// Optional explicit text color for [footerText] in light theme or default.
  final Color? footerTextColor;

  /// Optional explicit text color for [footerText] in dark theme.
  final Color? darkFooterTextColor;

  /// Height constraint for the footer logo.
  final double footerLogoHeight;

  /// Distance between the bottom edge (or safe area) and the footer.
  final double footerBottomPadding;

  /// Optional audio chime/tune configuration.
  final SplashAudioConfig? audioConfig;

  /// Optional asynchronous startup task (e.g. loading cache, auth checks, remote config).
  final Future<void> Function()? onInit;

  /// Callback invoked after splash animation, stay duration, and [onInit] have completed.
  final VoidCallback? onFinished;

  /// Target route string to navigate to (e.g. '/' or '/dashboard') when splash finishes.
  final String? nextRoute;

  /// Whether to automatically call `FlutterNativeSplash.remove()` when the Flutter view mounts.
  final bool removeNativeSplashOnMount;

  /// Whether a footer logo or text is configured.
  bool get hasFooter =>
      (footerLogoAsset != null && footerLogoAsset!.isNotEmpty) ||
      (darkFooterLogoAsset != null && darkFooterLogoAsset!.isNotEmpty) ||
      footerLogoWidget != null ||
      (footerText != null && footerText!.isNotEmpty);

  SplashConfig copyWith({
    String? logoAsset,
    String? darkLogoAsset,
    Widget? logoWidget,
    double? logoSize,
    SplashAnimationType? animationType,
    Duration? animationDuration,
    Duration? stayDuration,
    Color? backgroundColor,
    Color? darkBackgroundColor,
    String? footerLogoAsset,
    String? darkFooterLogoAsset,
    Widget? footerLogoWidget,
    String? footerText,
    Color? footerTextColor,
    Color? darkFooterTextColor,
    double? footerLogoHeight,
    double? footerBottomPadding,
    SplashAudioConfig? audioConfig,
    Future<void> Function()? onInit,
    VoidCallback? onFinished,
    String? nextRoute,
    bool? removeNativeSplashOnMount,
  }) {
    return SplashConfig(
      logoAsset: logoAsset ?? this.logoAsset,
      darkLogoAsset: darkLogoAsset ?? this.darkLogoAsset,
      logoWidget: logoWidget ?? this.logoWidget,
      logoSize: logoSize ?? this.logoSize,
      animationType: animationType ?? this.animationType,
      animationDuration: animationDuration ?? this.animationDuration,
      stayDuration: stayDuration ?? this.stayDuration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      footerLogoAsset: footerLogoAsset ?? this.footerLogoAsset,
      darkFooterLogoAsset: darkFooterLogoAsset ?? this.darkFooterLogoAsset,
      footerLogoWidget: footerLogoWidget ?? this.footerLogoWidget,
      footerText: footerText ?? this.footerText,
      footerTextColor: footerTextColor ?? this.footerTextColor,
      darkFooterTextColor: darkFooterTextColor ?? this.darkFooterTextColor,
      footerLogoHeight: footerLogoHeight ?? this.footerLogoHeight,
      footerBottomPadding: footerBottomPadding ?? this.footerBottomPadding,
      audioConfig: audioConfig ?? this.audioConfig,
      onInit: onInit ?? this.onInit,
      onFinished: onFinished ?? this.onFinished,
      nextRoute: nextRoute ?? this.nextRoute,
      removeNativeSplashOnMount:
          removeNativeSplashOnMount ?? this.removeNativeSplashOnMount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logoAsset': logoAsset,
      'darkLogoAsset': darkLogoAsset,
      'logoSize': logoSize,
      'animationType': animationType.name,
      'animationDurationMs': animationDuration.inMilliseconds,
      'stayDurationMs': stayDuration.inMilliseconds,
      'backgroundColor': backgroundColor.toARGB32(),
      'darkBackgroundColor': darkBackgroundColor?.toARGB32(),
      'footerLogoAsset': footerLogoAsset,
      'darkFooterLogoAsset': darkFooterLogoAsset,
      'footerText': footerText,
      'footerTextColor': footerTextColor?.toARGB32(),
      'darkFooterTextColor': darkFooterTextColor?.toARGB32(),
      'footerLogoHeight': footerLogoHeight,
      'footerBottomPadding': footerBottomPadding,
      'audioConfig': audioConfig?.toMap(),
      'nextRoute': nextRoute,
      'removeNativeSplashOnMount': removeNativeSplashOnMount,
    };
  }

  factory SplashConfig.fromMap(Map<String, dynamic> map) {
    return SplashConfig(
      logoAsset: map['logoAsset'] as String? ?? '',
      darkLogoAsset: map['darkLogoAsset'] as String?,
      logoSize: (map['logoSize'] as num?)?.toDouble() ?? 120.0,
      animationType: SplashAnimationType.values.firstWhere(
        (e) => e.name == map['animationType'],
        orElse: () => SplashAnimationType.scale,
      ),
      animationDuration: Duration(
        milliseconds: map['animationDurationMs'] as int? ?? 1200,
      ),
      stayDuration: Duration(
        milliseconds: map['stayDurationMs'] as int? ?? 1800,
      ),
      backgroundColor: Color(map['backgroundColor'] as int? ?? 0xFFFFFFFF),
      darkBackgroundColor: map['darkBackgroundColor'] != null
          ? Color(map['darkBackgroundColor'] as int)
          : null,
      footerLogoAsset: map['footerLogoAsset'] as String?,
      darkFooterLogoAsset: map['darkFooterLogoAsset'] as String?,
      footerText: map['footerText'] as String?,
      footerTextColor: map['footerTextColor'] != null
          ? Color(map['footerTextColor'] as int)
          : null,
      darkFooterTextColor: map['darkFooterTextColor'] != null
          ? Color(map['darkFooterTextColor'] as int)
          : null,
      footerLogoHeight: (map['footerLogoHeight'] as num?)?.toDouble() ?? 36.0,
      footerBottomPadding:
          (map['footerBottomPadding'] as num?)?.toDouble() ?? 32.0,
      audioConfig: map['audioConfig'] != null
          ? SplashAudioConfig.fromMap(
              Map<String, dynamic>.from(map['audioConfig'] as Map),
            )
          : null,
      nextRoute: map['nextRoute'] as String?,
      removeNativeSplashOnMount:
          map['removeNativeSplashOnMount'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'SplashConfig(logoAsset: $logoAsset, animation: ${animationType.name}, footer: $footerLogoAsset, audio: ${audioConfig != null})';
}
