import '../utils/app_constants.dart';
import 'services.dart';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

class DownloadService extends Services {
  /// Saves [bytes] as an image to the device gallery/photos app.
  /// Returns null on success and an error message on failure.
  static Future<String?> saveToGallery(
    Uint8List bytes, {
    String? prefix,
  }) async {
    if (kIsWeb) {
      return 'Saving to gallery is not supported on web.';
    }

    try {
      final filePrefix = prefix ?? AppConstants.downloadFilePrefix;
      final name = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(bytes, name: name);
      return null;
    } catch (_) {
      return 'Could not save. Please try again.';
    }
  }
}
