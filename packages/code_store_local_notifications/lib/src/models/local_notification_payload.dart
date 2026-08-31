import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Normalized data representation of a local or scheduled notification.
@immutable
class LocalNotificationPayload {
  const LocalNotificationPayload({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.data = const {},
    this.sentTime,
    this.category,
  });

  /// Unique identifier of the notification.
  final String? id;

  /// Title text of the notification.
  final String? title;

  /// Main message text of the notification.
  final String? body;

  /// Big Picture or media attachment URL/path.
  final String? imageUrl;

  /// Custom key-value dictionary attached to the notification.
  final Map<String, dynamic> data;

  /// Timestamp when created or received.
  final DateTime? sentTime;

  /// Channel or category identifier.
  final String? category;

  /// Computes and normalizes a routable path from the notification data.
  String? get routePath {
    final raw = data['route'] ?? data['payload'] ?? data['click_action'];
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    return str.startsWith('/') ? str : '/$str';
  }

  factory LocalNotificationPayload.fromMap(Map<String, dynamic> map) {
    return LocalNotificationPayload(
      id: map['id']?.toString(),
      title: map['title']?.toString(),
      body: map['body']?.toString(),
      imageUrl: map['imageUrl']?.toString() ?? map['image']?.toString(),
      data: map['data'] != null && map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{},
      sentTime: map['sentTime'] != null
          ? DateTime.tryParse(map['sentTime'].toString())
          : null,
      category: map['category']?.toString(),
    );
  }

  factory LocalNotificationPayload.fromJson(String jsonStr) {
    return LocalNotificationPayload.fromMap(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'data': data,
    'sentTime': sentTime?.toIso8601String(),
    'category': category,
  };

  String toJson() => jsonEncode(toMap());
}
