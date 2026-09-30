import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/splash_animation_type.dart';

/// Renders the main splash logo either statically or with customizable entrance animations.
class AnimatedSplashLogo extends StatefulWidget {
  const AnimatedSplashLogo({
    super.key,
    required this.logoAsset,
    this.logoWidget,
    this.size = 120.0,
    this.animationType = SplashAnimationType.scale,
    this.duration = const Duration(milliseconds: 1200),
    this.customBuilder,
  });

  /// Path to the logo asset.
  final String logoAsset;

  /// Optional custom widget to render instead of [logoAsset].
  final Widget? logoWidget;

  /// Size of the logo square bounding box.
  final double size;

  /// Animation type to apply.
  final SplashAnimationType animationType;

  /// Duration of the logo animation.
  final Duration duration;

  /// Custom animation builder if [animationType] is [SplashAnimationType.custom].
  final Widget Function(
    BuildContext context,
    AnimationController controller,
    Widget child,
  )?
  customBuilder;

  @override
  State<AnimatedSplashLogo> createState() => _AnimatedSplashLogoState();
}

class _AnimatedSplashLogoState extends State<AnimatedSplashLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    switch (widget.animationType) {
      case SplashAnimationType.none:
        _animation = const AlwaysStoppedAnimation(1.0);
      case SplashAnimationType.scale:
        _animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        );
        _controller.forward();
      case SplashAnimationType.fade:
        _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
        _controller.forward();
      case SplashAnimationType.pulse:
        _animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        );
        _controller.repeat(reverse: true);
      case SplashAnimationType.shimmer:
        _animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        );
        _controller.repeat();
      case SplashAnimationType.bounce:
        _animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.bounceOut,
        );
        _controller.forward();
      case SplashAnimationType.flip:
        _animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutCubic,
        );
        _controller.forward();
      case SplashAnimationType.custom:
        _animation = _controller;
        _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogoWidget() {
    if (widget.logoWidget != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: widget.logoWidget),
      );
    }

    if (widget.logoAsset.isEmpty) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.rocket_launch_rounded,
          size: widget.size * 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Image.asset(
      widget.logoAsset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: widget.size * 0.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawLogo = _buildLogoWidget();

    switch (widget.animationType) {
      case SplashAnimationType.none:
        return rawLogo;

      case SplashAnimationType.scale:
        return ScaleTransition(scale: _animation, child: rawLogo);

      case SplashAnimationType.fade:
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: rawLogo,
          ),
        );

      case SplashAnimationType.pulse:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final scale = 1.0 + (_animation.value * 0.12);
            return Transform.scale(scale: scale, child: child);
          },
          child: rawLogo,
        );

      case SplashAnimationType.shimmer:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                final progress = _animation.value;
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [Colors.white, Colors.white70, Colors.white],
                  stops: [
                    (progress - 0.2).clamp(0.0, 1.0),
                    progress.clamp(0.0, 1.0),
                    (progress + 0.2).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: rawLogo,
        );

      case SplashAnimationType.bounce:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1.0 - _animation.value) * -100),
              child: child,
            );
          },
          child: rawLogo,
        );

      case SplashAnimationType.flip:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = (1.0 - _animation.value) * math.pi;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: rawLogo,
        );

      case SplashAnimationType.custom:
        if (widget.customBuilder != null) {
          return widget.customBuilder!(context, _controller, rawLogo);
        }
        return rawLogo;
    }
  }
}
