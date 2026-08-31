/// Normalized permission status outcome.
enum AppPermissionStatus {
  /// Permission has been granted by the user.
  granted,

  /// Permission was denied by the user, but can be requested again.
  denied,

  /// Permission is restricted by parental controls or OS policy.
  restricted,

  /// Permission was permanently denied (requires navigating to App Settings).
  permanentlyDenied,

  /// Permission is limited (e.g. iOS select photos only).
  limited,

  /// Permission is provisional (e.g. iOS quiet notifications).
  provisional,
}

/// Convenience extensions for [AppPermissionStatus].
extension AppPermissionStatusExtension on AppPermissionStatus {
  /// Whether the permission is usable (either fully granted, limited, or provisional).
  bool get isGranted =>
      this == AppPermissionStatus.granted ||
      this == AppPermissionStatus.limited ||
      this == AppPermissionStatus.provisional;

  /// Whether the user permanently rejected the permission and must go to Settings.
  bool get isPermanentlyDenied => this == AppPermissionStatus.permanentlyDenied;

  /// Whether the permission was denied.
  bool get isDenied => this == AppPermissionStatus.denied;

  /// Friendly display label.
  String get label {
    switch (this) {
      case AppPermissionStatus.granted:
        return 'Granted';
      case AppPermissionStatus.denied:
        return 'Denied';
      case AppPermissionStatus.restricted:
        return 'Restricted';
      case AppPermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case AppPermissionStatus.limited:
        return 'Limited';
      case AppPermissionStatus.provisional:
        return 'Provisional';
    }
  }
}
