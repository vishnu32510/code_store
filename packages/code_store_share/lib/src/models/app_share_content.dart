import 'package:flutter/material.dart';

/// Normalized share payload content.
@immutable
class AppShareContent {
  const AppShareContent({
    required this.text,
    this.subject,
    this.url,
    this.filePaths = const [],
  });

  /// The main message / text content to share.
  final String text;

  /// Optional email / message subject line.
  final String? subject;

  /// Optional URL link.
  final String? url;

  /// List of absolute file paths to share.
  final List<String> filePaths;

  /// Formats combined text + URL.
  String get fullMessageText {
    if (url != null && url!.isNotEmpty) {
      return '$text\n$url';
    }
    return text;
  }
}
