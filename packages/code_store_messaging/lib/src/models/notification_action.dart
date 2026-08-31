import 'package:code_store_local_notifications/code_store_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Interactive action button attached to a notification banner.
@immutable
class NotificationAction extends LocalNotificationAction {
  const NotificationAction({
    required super.id,
    required super.title,
    super.icon,
    super.isDestructive,
    super.showsUserInterface,
    super.allowFreeFormInput,
    super.inputPlaceholder,
  });

  factory NotificationAction.fromMap(Map<String, dynamic> map) {
    final action = LocalNotificationAction.fromMap(map);
    return NotificationAction(
      id: action.id,
      title: action.title,
      icon: action.icon,
      isDestructive: action.isDestructive,
      showsUserInterface: action.showsUserInterface,
      allowFreeFormInput: action.allowFreeFormInput,
      inputPlaceholder: action.inputPlaceholder,
    );
  }
}

/// Event fired when a user taps an action button or enters quick reply text.
@immutable
class NotificationActionResponse extends LocalNotificationActionResponse {
  const NotificationActionResponse({
    required super.actionId,
    super.userText,
    super.payload,
    super.rawPayload,
  });

  factory NotificationActionResponse.fromMap(Map<String, dynamic> map) {
    final res = LocalNotificationActionResponse.fromMap(map);
    return NotificationActionResponse(
      actionId: res.actionId,
      userText: res.userText,
      payload: res.payload,
      rawPayload: res.rawPayload,
    );
  }
}
