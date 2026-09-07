import 'package:meta/meta.dart';

/// Simple text/icon status to display in the Dynamic Island.
@immutable
class IslandStatus {
  const IslandStatus({
    required this.title,
    this.subtitle,
    this.iconSystemName,
    this.isActive = true,
  });

  /// Primary title text shown in the Dynamic Island.
  final String title;

  /// Optional subtitle shown in expanded or lock screen view.
  final String? subtitle;

  /// SF Symbol name for the status icon (e.g. "pawprint.fill").
  final String? iconSystemName;

  /// Whether this status represents an active state.
  final bool isActive;

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'iconSystemName': iconSystemName,
        'isActive': isActive,
      };

  factory IslandStatus.fromMap(Map<String, dynamic> map) {
    return IslandStatus(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      iconSystemName: map['iconSystemName'] as String?,
      isActive: (map['isActive'] as bool?) ?? true,
    );
  }

  IslandStatus copyWith({
    String? title,
    String? subtitle,
    String? iconSystemName,
    bool? isActive,
  }) {
    return IslandStatus(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconSystemName: iconSystemName ?? this.iconSystemName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'IslandStatus(title: $title, subtitle: $subtitle, '
      'icon: $iconSystemName, active: $isActive)';
}
