/// Styles of animation available for the main splash screen logo.
enum SplashAnimationType {
  /// Displays the logo statically with no scale or motion (handover matches native splash 1:1).
  none('Static (No Animation)'),

  /// Smooth spring/elastic scale-in from small to normal size.
  scale('Scale In'),

  /// Subtle opacity fade-in with a gentle upward slide.
  fade('Fade In'),

  /// Rhythmic heartbeat-style scale pulse.
  pulse('Pulse'),

  /// Elegant diagonal shimmer light sweep across the logo.
  shimmer('Shimmer'),

  /// Playful downward bounce and settle.
  bounce('Bounce'),

  /// Perspective 3D card/logo flip on the Y-axis.
  flip('3D Flip'),

  /// Custom developer-defined builder animation.
  custom('Custom');

  const SplashAnimationType(this.displayName);

  final String displayName;

  /// Whether this animation type runs an animation controller.
  bool get isAnimated => this != SplashAnimationType.none;
}
