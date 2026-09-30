import 'package:flutter/material.dart';

/// Renders the optional bottom branding footer logo and text.
class SplashFooterLogo extends StatelessWidget {
  const SplashFooterLogo({
    super.key,
    this.footerLogoAsset,
    this.footerLogoWidget,
    this.footerText,
    this.footerLogoHeight = 36.0,
    this.textColor,
  });

  /// Path to the branding logo asset.
  final String? footerLogoAsset;

  /// Custom footer widget override.
  final Widget? footerLogoWidget;

  /// Optional branding tagline or copyright text.
  final String? footerText;

  /// Height constraint for the branding image.
  final double footerLogoHeight;

  /// Text color for [footerText].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        (footerLogoAsset != null && footerLogoAsset!.isNotEmpty) ||
        footerLogoWidget != null;
    final hasText = footerText != null && footerText!.isNotEmpty;

    if (!hasLogo && !hasText) {
      return const SizedBox.shrink();
    }

    Widget? logoChild;
    if (footerLogoWidget != null) {
      logoChild = SizedBox(
        height: footerLogoHeight,
        child: Center(child: footerLogoWidget),
      );
    } else if (footerLogoAsset != null && footerLogoAsset!.isNotEmpty) {
      logoChild = Image.asset(
        footerLogoAsset!,
        height: footerLogoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }

    final defaultTextColor =
        textColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ?logoChild,
        if (hasLogo && hasText) const SizedBox(height: 8),
        if (hasText)
          Text(
            footerText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: defaultTextColor,
            ),
          ),
      ],
    );
  }
}
