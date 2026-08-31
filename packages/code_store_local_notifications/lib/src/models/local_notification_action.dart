import 'package:flutter/foundation.dart';
import 'local_notification_payload.dart';

/// Represents an interactive button displayed on a local notification banner.
@immutable
class LocalNotificationAction {
  const LocalNotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.isDestructive = false,
    this.showsUserInterface = true,
    this.allowFreeFormInput = false,
    this.inputPlaceholder,
  });

  final String id;
  final String title;
  final String? icon;
  final bool isDestructive;
  final bool showsUserInterface;
  final bool allowFreeFormInput;
  final String? inputPlaceholder;

  factory LocalNotificationAction.fromMap(Map<String, dynamic> map) {
    return LocalNotificationAction(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      icon: map['icon']?.toString(),
      isDestructive: map['isDestructive'] == true,
      showsUserInterface: map['showsUserInterface'] ?? true,
      allowFreeFormInput: map['allowFreeFormInput'] == true,
      inputPlaceholder: map['inputPlaceholder']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'icon': icon,
    'isDestructive': isDestructive,
    'showsUserInterface': showsUserInterface,
    'allowFreeFormInput': allowFreeFormInput,
    'inputPlaceholder': inputPlaceholder,
  };
}

/// Represents the event fired when a user interacts with a notification or action button.
@immutable
class LocalNotificationActionResponse {
  const LocalNotificationActionResponse({
    required this.actionId,
    this.userText,
    this.payload,
    this.rawPayload,
  });

  final String actionId;
  final String? userText;
  final LocalNotificationPayload? payload;
  final String? rawPayload;

  factory LocalNotificationActionResponse.fromMap(Map<String, dynamic> map) {
    return LocalNotificationActionResponse(
      actionId: map['actionId']?.toString() ?? '',
      userText: map['userText']?.toString(),
      payload: map['payload'] != null && map['payload'] is Map
          ? LocalNotificationPayload.fromMap(
              Map<String, dynamic>.from(map['payload'] as Map),
            )
          : null,
      rawPayload: map['rawPayload']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'actionId': actionId,
    'userText': userText,
    'payload': payload?.toMap(),
    'rawPayload': rawPayload,
  };
}
