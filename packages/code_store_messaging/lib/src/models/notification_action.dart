import 'push_notification_payload.dart';

/// Represents an interactive action button attached to a notification banner.
class NotificationAction {
  const NotificationAction({
    required this.id,
    required this.title,
    this.isDestructive = false,
    this.showsUserInterface = true,
    this.allowFreeFormInput = false,
    this.inputPlaceholder,
  });

  /// Unique identifier for this action (e.g. 'accept_invitation', 'reply').
  final String id;

  /// Display text on the button.
  final String title;

  /// Indicates if this action is destructive (e.g. Delete, Decline - red on iOS).
  final bool isDestructive;

  /// Whether tapping this action opens the app in foreground.
  final bool showsUserInterface;

  /// Whether to show a text input field on the notification (e.g. Quick Reply).
  final bool allowFreeFormInput;

  /// Placeholder text for the quick reply input box.
  final String? inputPlaceholder;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDestructive': isDestructive,
        'showsUserInterface': showsUserInterface,
        'allowFreeFormInput': allowFreeFormInput,
        'inputPlaceholder': inputPlaceholder,
      };
}

/// Represents the event fired when a user taps an action button or enters text reply.
class NotificationActionResponse {
  const NotificationActionResponse({
    required this.actionId,
    this.userText,
    this.payload,
    this.rawPayload,
  });

  /// The ID of the action button tapped.
  final String actionId;

  /// The text entered by the user if this was a quick reply action.
  final String? userText;

  /// Parsed push notification payload.
  final PushNotificationPayload? payload;

  /// Raw JSON payload string.
  final String? rawPayload;

  @override
  String toString() =>
      'NotificationActionResponse(actionId: $actionId, userText: $userText, payload: $payload)';
}
