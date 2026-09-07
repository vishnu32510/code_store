import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Pure-Dart utility that slices a grid-based sprite sheet into
/// individual PNG frames suitable for Dynamic Island animation.
///
/// Each frame is saved as `{animationName}_{index}.png` in [outputDirectory].
/// Frames are automatically resized to fit within [maxDimension] pixels
/// (default 80) to respect iOS widget memory limits.
class SpriteSlicer {
  const SpriteSlicer();

  /// Slices [spriteSheetBytes] into individual frame PNGs.
  ///
  /// - [columns]: number of sprite columns in the grid.
  /// - [rows]: total number of rows in the grid.
  /// - [startRow]: first row to extract (0-indexed, inclusive). Defaults to 0.
  /// - [endRow]: last row to extract (0-indexed, inclusive). Defaults to [rows]-1.
  /// - [maxDimension]: maximum width or height of each output frame (default 80px).
  ///
  /// Returns the total number of frames extracted.
  Future<int> slice({
    required Uint8List spriteSheetBytes,
    required String outputDirectory,
    required String animationName,
    required int columns,
    required int rows,
    int? startRow,
    int? endRow,
    int maxDimension = 80,
  }) async {
    final decoded = img.decodePng(spriteSheetBytes);
    if (decoded == null) {
      throw ArgumentError('Failed to decode PNG sprite sheet');
    }

    final frameWidth = decoded.width ~/ columns;
    final frameHeight = decoded.height ~/ rows;
    final effectiveStartRow = startRow ?? 0;
    final effectiveEndRow = endRow ?? (rows - 1);

    // Ensure output directory exists
    final dir = Directory(outputDirectory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    int frameIndex = 0;

    for (int row = effectiveStartRow; row <= effectiveEndRow; row++) {
      for (int col = 0; col < columns; col++) {
        final x = col * frameWidth;
        final y = row * frameHeight;

        // Crop this frame from the sheet
        var frame = img.copyCrop(
          decoded,
          x: x,
          y: y,
          width: frameWidth,
          height: frameHeight,
        );

        // Resize to fit within maxDimension while preserving aspect ratio
        if (frame.width > maxDimension || frame.height > maxDimension) {
          if (frame.width >= frame.height) {
            frame = img.copyResize(frame, width: maxDimension);
          } else {
            frame = img.copyResize(frame, height: maxDimension);
          }
        }

        // Encode to PNG and write to disk
        final pngBytes = img.encodePng(frame);
        final filePath = '$outputDirectory/${animationName}_$frameIndex.png';
        await File(filePath).writeAsBytes(pngBytes);

        frameIndex++;
      }
    }

    return frameIndex;
  }

  /// Analyzes a sprite sheet and returns estimated grid dimensions.
  ///
  /// Returns `{width, height, estimatedColumns, estimatedRows}` based on
  /// common sprite sheet conventions.
  Map<String, int> analyze(Uint8List spriteSheetBytes) {
    final decoded = img.decodePng(spriteSheetBytes);
    if (decoded == null) {
      throw ArgumentError('Failed to decode PNG sprite sheet');
    }

    return {
      'width': decoded.width,
      'height': decoded.height,
    };
  }
}
