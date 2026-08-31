import '../models/app_share_content.dart';

/// Abstract contract for triggering native system share sheets.
abstract interface class IShareService {
  /// Shares plain text or URL link via native system share dialog.
  Future<void> shareText({
    required String text,
    String? subject,
  });

  /// Shares a website URL with optional description text.
  Future<void> shareUri({
    required Uri uri,
    String? text,
  });

  /// Shares files or images from local disk.
  Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
  });

  /// Shares structured content payload.
  Future<void> shareContent(AppShareContent content);
}
