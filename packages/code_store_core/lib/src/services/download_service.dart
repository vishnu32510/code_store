import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

import 'services.dart';

class DownloadService extends Services {
  /// Saves [bytes] as an image to the device gallery/photos app.
  /// Returns null on success and an error message on failure.
  static Future<String?> saveToGallery(
    Uint8List bytes, {
    String prefix = 'app',
  }) async {
    if (kIsWeb) {
      return 'Saving to gallery is not supported on web.';
    }

    try {
      final name = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(bytes, name: name);
      return null;
    } catch (_) {
      return 'Could not save. Please try again.';
    }
  }
}
