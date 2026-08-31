import 'package:firebase_messaging/firebase_messaging.dart';

/// Normalized data representation of an incoming or tapped push notification.
class PushNotificationPayload {
  const PushNotificationPayload({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.data = const {},
    this.sentTime,
    this.category,
    this.from,
    this.collapseKey,
  });

  /// Unique message ID assigned by FCM or local notification ID.
  final String? id;

  /// Notification title text.
  final String? title;

  /// Notification body text.
  final String? body;

  /// Associated rich media image URL (if present in notification payload or data).
  final String? imageUrl;

  /// Key-value payload map attached to the notification.
  final Map<String, dynamic> data;

  /// Time when the message was sent or received.
  final DateTime? sentTime;

  /// iOS category or Android notification channel identifier.
  final String? category;

  /// Topic name or sender ID.
  final String? from;

  /// Collapse key used by FCM for message consolidation.
  final String? collapseKey;

  /// Extracts and normalizes any routing path embedded in the notification payload (e.g. `data['route']`, `data['payload']`, `data['click_action']`).
  String? get routePath {
    final raw = data['route'] ?? data['payload'] ?? data['click_action'];
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    return str.startsWith('/') ? str : '/$str';
  }

  /// Creates a [PushNotificationPayload] from a Firebase [RemoteMessage].
  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = Map<String, dynamic>.from(message.data);

    // Extract image URL from either the standard notification payload or data field
    final imageUrl =
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        data['image']?.toString() ??
        data['imageUrl']?.toString() ??
        data['image_url']?.toString();

    return PushNotificationPayload(
      id: message.messageId,
      title: notification?.title ?? data['title']?.toString(),
      body: notification?.body ?? data['body']?.toString(),
      imageUrl: imageUrl,
      data: data,
      sentTime: message.sentTime ?? DateTime.now(),
      category:
          notification?.android?.channelId ??
          notification?.apple?.subtitleLocKey,
      from: message.from,
      collapseKey: message.collapseKey,
    );
  }

  /// Creates a [PushNotificationPayload] from a Map.
  factory PushNotificationPayload.fromMap(Map<String, dynamic> map) {
    return PushNotificationPayload(
      id: map['id']?.toString(),
      title: map['title']?.toString(),
      body: map['body']?.toString(),
      imageUrl: map['imageUrl']?.toString() ?? map['image']?.toString(),
      data: map['data'] is Map<String, dynamic>
          ? map['data'] as Map<String, dynamic>
          : (map['data'] is Map
                ? Map<String, dynamic>.from(map['data'] as Map)
                : {}),
      sentTime: map['sentTime'] != null
          ? DateTime.tryParse(map['sentTime'].toString())
          : null,
      category: map['category']?.toString(),
      from: map['from']?.toString(),
      collapseKey: map['collapseKey']?.toString(),
    );
  }

  /// Converts the payload into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'sentTime': sentTime?.toIso8601String(),
      'category': category,
      'from': from,
      'collapseKey': collapseKey,
    };
  }

  @override
  String toString() =>
      'PushNotificationPayload(id: $id, title: $title, body: $body, data: $data)';
}
