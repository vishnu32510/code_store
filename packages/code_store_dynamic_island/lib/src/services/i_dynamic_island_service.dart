import '../models/island_animation_config.dart';
import '../models/island_status.dart';

/// Abstract service interface for Dynamic Island Live Activities.
///
/// Provides two modes:
/// 1. **Simple status** — display text and SF Symbol icons.
/// 2. **Sprite animation** — loop through pre-sliced PNG frames using
///    SwiftUI `TimelineView` on the native iOS side.
abstract interface class IDynamicIslandService {
  /// Returns `true` if the device supports Dynamic Island
  /// (iPhone 14 Pro+, iOS 16.1+).
  Future<bool> isSupported();

  /// Start a simple text/icon status in the Dynamic Island.
  Future<bool> startStatus(IslandStatus status);

  /// Start a sprite animation loop from pre-sliced frames saved
  /// in the App Group shared container.
  Future<bool> startAnimation(IslandAnimationConfig config);

  /// Update the running Live Activity's content state.
  Future<bool> updateStatus(IslandStatus status);

  /// End the current Live Activity.
  Future<bool> endActivity();

  /// Slice a sprite sheet PNG into individual frame PNGs saved
  /// to the App Group shared container directory.
  ///
  /// Returns the total number of frames extracted.
  Future<int> sliceSpriteSheet({
    required String assetPath,
    required String animationName,
    required int columns,
    required int rows,
    int? startRow,
    int? endRow,
  });
}
