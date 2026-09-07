import 'package:meta/meta.dart';

/// Placement of the animation within the Dynamic Island.
enum IslandPlacement {
  /// Compact leading (small circle left of the notch).
  compactLeading,

  /// Compact trailing (small circle right of the notch).
  compactTrailing,

  /// Both compact leading and trailing.
  both,
}

/// Configuration for a sprite-based animation loop in the Dynamic Island.
@immutable
class IslandAnimationConfig {
  const IslandAnimationConfig({
    required this.animationName,
    required this.totalFrames,
    this.framesPerSecond = 10,
    this.frameWidth = 64,
    this.frameHeight = 64,
    this.placement = IslandPlacement.compactLeading,
  });

  /// Unique name identifying the animation (e.g. "retro_cat_idle").
  /// Frame files are named `{animationName}_0.png`, `{animationName}_1.png`, etc.
  final String animationName;

  /// Total number of frames in the animation loop.
  final int totalFrames;

  /// Playback speed in frames per second (default 10).
  final int framesPerSecond;

  /// Width of each individual frame in pixels.
  final int frameWidth;

  /// Height of each individual frame in pixels.
  final int frameHeight;

  /// Where to render the animation in the Dynamic Island.
  final IslandPlacement placement;

  Map<String, dynamic> toMap() => {
        'animationName': animationName,
        'totalFrames': totalFrames,
        'framesPerSecond': framesPerSecond,
        'frameWidth': frameWidth,
        'frameHeight': frameHeight,
        'placement': placement.name,
      };

  factory IslandAnimationConfig.fromMap(Map<String, dynamic> map) {
    return IslandAnimationConfig(
      animationName: map['animationName'] as String,
      totalFrames: map['totalFrames'] as int,
      framesPerSecond: (map['framesPerSecond'] as int?) ?? 10,
      frameWidth: (map['frameWidth'] as int?) ?? 64,
      frameHeight: (map['frameHeight'] as int?) ?? 64,
      placement: IslandPlacement.values.firstWhere(
        (e) => e.name == (map['placement'] as String?),
        orElse: () => IslandPlacement.compactLeading,
      ),
    );
  }

  IslandAnimationConfig copyWith({
    String? animationName,
    int? totalFrames,
    int? framesPerSecond,
    int? frameWidth,
    int? frameHeight,
    IslandPlacement? placement,
  }) {
    return IslandAnimationConfig(
      animationName: animationName ?? this.animationName,
      totalFrames: totalFrames ?? this.totalFrames,
      framesPerSecond: framesPerSecond ?? this.framesPerSecond,
      frameWidth: frameWidth ?? this.frameWidth,
      frameHeight: frameHeight ?? this.frameHeight,
      placement: placement ?? this.placement,
    );
  }

  @override
  String toString() =>
      'IslandAnimationConfig(name: $animationName, frames: $totalFrames, '
      'fps: $framesPerSecond, size: ${frameWidth}x$frameHeight, '
      'placement: ${placement.name})';
}
