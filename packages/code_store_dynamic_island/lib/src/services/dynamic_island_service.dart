import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/island_animation_config.dart';
import '../models/island_status.dart';
import '../utils/sprite_slicer.dart';
import 'i_dynamic_island_service.dart';

/// Concrete implementation of [IDynamicIslandService].
///
/// Communicates with iOS ActivityKit via native MethodChannel and uses
/// [SpriteSlicer] for pure Dart image processing and slicing.
///
/// On Android and Web, all methods return safe no-op defaults.
class DynamicIslandService implements IDynamicIslandService {
  DynamicIslandService({
    MethodChannel? channel,
    SpriteSlicer? spriteSlicer,
    this._appGroupId = 'group.com.nungu.codestore',
  })  : _channel = channel ??
            const MethodChannel('com.nungu.codestore/dynamic_island'),
        _spriteSlicer = spriteSlicer ?? const SpriteSlicer();

  final MethodChannel _channel;
  final SpriteSlicer _spriteSlicer;
  final String _appGroupId;

  String? _currentActivityId;

  bool get _isUnsupported => kIsWeb || (!kIsWeb && Platform.isAndroid);

  @override
  Future<bool> isSupported() async {
    if (_isUnsupported) {
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('isSupported');
      return res ?? false;
    } catch (e) {
      debugPrint('DynamicIslandService: isSupported check failed: $e');
      return false;
    }
  }

  @override
  Future<bool> startStatus(IslandStatus status) async {
    if (_isUnsupported) {
      debugPrint(
        'DynamicIslandService: Dynamic Island not supported on this platform.',
      );
      return false;
    }

    try {
      if (_currentActivityId != null) {
        await endActivity();
      }

      final activityId = await _channel.invokeMethod<String>('startActivity', {
        'title': status.title,
        'subtitle': status.subtitle ?? '',
        'iconSystemName': status.iconSystemName ?? 'star.fill',
        'isActive': status.isActive,
        'isAnimating': false,
        'totalFrames': 0,
        'framesPerSecond': 0,
        'animationName': '',
        'placement': 'compactLeading',
        'appGroupId': _appGroupId,
      });

      _currentActivityId = activityId;
      return activityId != null;
    } catch (e) {
      debugPrint('DynamicIslandService: startStatus failed: $e');
      return false;
    }
  }

  @override
  Future<bool> startAnimation(IslandAnimationConfig config) async {
    if (_isUnsupported) {
      debugPrint(
        'DynamicIslandService: Dynamic Island not supported on this platform.',
      );
      return false;
    }

    try {
      if (_currentActivityId != null) {
        await endActivity();
      }

      final activityId = await _channel.invokeMethod<String>('startActivity', {
        'title': config.animationName,
        'subtitle': '',
        'iconSystemName': 'pawprint.fill',
        'isActive': true,
        'isAnimating': true,
        'totalFrames': config.totalFrames,
        'framesPerSecond': config.framesPerSecond,
        'animationName': config.animationName,
        'placement': config.placement.name,
        'appGroupId': _appGroupId,
      });

      _currentActivityId = activityId;
      return activityId != null;
    } catch (e) {
      debugPrint('DynamicIslandService: startAnimation failed: $e');
      return false;
    }
  }

  @override
  Future<bool> updateStatus(IslandStatus status) async {
    if (_isUnsupported || _currentActivityId == null) {
      return false;
    }

    try {
      final success = await _channel.invokeMethod<bool>('updateActivity', {
        'activityId': _currentActivityId,
        'title': status.title,
        'subtitle': status.subtitle ?? '',
        'iconSystemName': status.iconSystemName ?? 'star.fill',
        'isActive': status.isActive,
        'isAnimating': false,
        'totalFrames': 0,
        'framesPerSecond': 0,
        'animationName': '',
        'placement': 'compactLeading',
      });
      return success ?? false;
    } catch (e) {
      debugPrint('DynamicIslandService: updateStatus failed: $e');
      return false;
    }
  }

  @override
  Future<bool> endActivity() async {
    if (_isUnsupported) {
      return false;
    }

    try {
      final success = await _channel.invokeMethod<bool>('endActivity', {
        'activityId': _currentActivityId,
      });
      _currentActivityId = null;
      return success ?? true;
    } catch (e) {
      debugPrint('DynamicIslandService: endActivity failed: $e');
      return false;
    }
  }

  @override
  Future<int> sliceSpriteSheet({
    required String assetPath,
    required String animationName,
    required int columns,
    required int rows,
    int? startRow,
    int? endRow,
  }) async {
    try {
      // Load the asset bytes
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final appSupportDir = await getApplicationSupportDirectory();
      final outputDir = '${appSupportDir.path}/island_frames';

      final frameCount = await _spriteSlicer.slice(
        spriteSheetBytes: bytes,
        outputDirectory: outputDir,
        animationName: animationName,
        columns: columns,
        rows: rows,
        startRow: startRow,
        endRow: endRow,
        maxDimension: 80,
      );

      // Transfer frame files directly to the App Group container via MethodChannel
      if (!kIsWeb && Platform.isIOS) {
        for (int i = 0; i < frameCount; i++) {
          final framePath = '$outputDir/${animationName}_$i.png';
          final frameFile = File(framePath);
          if (frameFile.existsSync()) {
            final frameBytes = await frameFile.readAsBytes();
            await _channel.invokeMethod('saveFrame', {
              'fileName': '${animationName}_$i.png',
              'bytes': Uint8List.fromList(frameBytes),
              'appGroupId': _appGroupId,
            });
          }
        }
      }

      debugPrint(
        'DynamicIslandService: Sliced $frameCount frames for "$animationName"',
      );
      return frameCount;
    } catch (e) {
      debugPrint('DynamicIslandService: sliceSpriteSheet failed: $e');
      return 0;
    }
  }
}
