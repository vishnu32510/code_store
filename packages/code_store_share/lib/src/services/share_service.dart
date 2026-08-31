import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_share_content.dart';
import 'i_share_service.dart';

/// Concrete implementation of [IShareService] using `share_plus`.
class ShareService implements IShareService {
  const ShareService();

  @override
  Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing text: $e');
    }
  }

  @override
  Future<void> shareUri({
    required Uri uri,
    String? text,
  }) async {
    try {
      await Share.shareUri(
        uri,
      );
    } catch (e) {
      debugPrint('Error sharing URI: $e');
    }
  }

  @override
  Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
  }) async {
    try {
      final xfiles = filePaths.map((p) => XFile(p)).toList();
      await Share.shareXFiles(
        xfiles,
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing files: $e');
    }
  }

  @override
  Future<void> shareContent(AppShareContent content) async {
    if (content.filePaths.isNotEmpty) {
      await shareFiles(
        filePaths: content.filePaths,
        text: content.fullMessageText,
        subject: content.subject,
      );
    } else {
      await shareText(
        text: content.fullMessageText,
        subject: content.subject,
      );
    }
  }
}
