import 'package:equatable/equatable.dart';

/// Data payload model representing information shared with native home screen widgets.
class HomeWidgetPayload extends Equatable {
  const HomeWidgetPayload({
    required this.title,
    required this.message,
    this.status,
    this.updatedAt,
    this.badgeCount = 0,
    this.actionUri,
    this.customData = const {},
  });

  final String title;
  final String message;
  final String? status;
  final DateTime? updatedAt;
  final int badgeCount;
  final String? actionUri;
  final Map<String, dynamic> customData;

  /// Creates a payload from key-value map.
  factory HomeWidgetPayload.fromMap(Map<String, dynamic> map) {
    return HomeWidgetPayload(
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
      badgeCount: (map['badgeCount'] as num?)?.toInt() ?? 0,
      actionUri: map['actionUri'] as String?,
      customData: (map['customData'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Converts payload to a key-value map suitable for [HomeWidget.saveWidgetData].
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      if (status != null) 'status': status,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'badgeCount': badgeCount,
      if (actionUri != null) 'actionUri': actionUri,
      ...customData,
    };
  }

  HomeWidgetPayload copyWith({
    String? title,
    String? message,
    String? status,
    DateTime? updatedAt,
    int? badgeCount,
    String? actionUri,
    Map<String, dynamic>? customData,
  }) {
    return HomeWidgetPayload(
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      badgeCount: badgeCount ?? this.badgeCount,
      actionUri: actionUri ?? this.actionUri,
      customData: customData ?? this.customData,
    );
  }

  @override
  List<Object?> get props => [
        title,
        message,
        status,
        updatedAt,
        badgeCount,
        actionUri,
        customData,
      ];
}
