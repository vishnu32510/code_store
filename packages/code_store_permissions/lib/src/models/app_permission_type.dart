import 'package:flutter/material.dart';

/// Normalized supported app permission types across iOS, Android, and Web.
enum AppPermissionType {
  /// Access to device camera.
  camera,

  /// Access to photo library / gallery images.
  photos,

  /// Foreground location access (while app is in use).
  locationWhenInUse,

  /// Background / Always location access.
  locationAlways,

  /// Access to device microphone for audio recording.
  microphone,

  /// Access to external storage (Android legacy / media).
  storage,

  /// System notification delivery.
  notification,

  /// Bluetooth communication and peripheral scanning.
  bluetooth,

  /// Apple AppTrackingTransparency (IDFA) for cross-app analytics/attribution.
  appTrackingTransparency,
}

/// Helpful UI and metadata extensions for [AppPermissionType].
extension AppPermissionTypeExtension on AppPermissionType {
  /// Friendly display title.
  String get displayName {
    switch (this) {
      case AppPermissionType.camera:
        return 'Camera';
      case AppPermissionType.photos:
        return 'Photo Library';
      case AppPermissionType.locationWhenInUse:
        return 'Location (In Use)';
      case AppPermissionType.locationAlways:
        return 'Location (Always)';
      case AppPermissionType.microphone:
        return 'Microphone';
      case AppPermissionType.storage:
        return 'Storage Access';
      case AppPermissionType.notification:
        return 'Notifications';
      case AppPermissionType.bluetooth:
        return 'Bluetooth';
      case AppPermissionType.appTrackingTransparency:
        return 'App Tracking';
    }
  }

  /// Default user-facing explanation for permission rationale modals.
  String get defaultRationale {
    switch (this) {
      case AppPermissionType.camera:
        return 'We need access to your camera so you can take photos, scan codes, or use the flashlight.';
      case AppPermissionType.photos:
        return 'We need access to your photo library so you can select and save images.';
      case AppPermissionType.locationWhenInUse:
        return 'We need your location while you use the app to show you relevant local features.';
      case AppPermissionType.locationAlways:
        return 'We need your background location to provide real-time tracking and location-based updates.';
      case AppPermissionType.microphone:
        return 'We need access to your microphone so you can record audio and voice messages.';
      case AppPermissionType.storage:
        return 'We need storage access to save and read files on your device.';
      case AppPermissionType.notification:
        return 'Enable notifications to receive important alerts and updates.';
      case AppPermissionType.bluetooth:
        return 'We need Bluetooth access to connect with nearby devices.';
      case AppPermissionType.appTrackingTransparency:
        return 'Allowing tracking helps us provide a more personalized experience for you.';
    }
  }

  /// Corresponding Material Icon.
  IconData get icon {
    switch (this) {
      case AppPermissionType.camera:
        return Icons.camera_alt_rounded;
      case AppPermissionType.photos:
        return Icons.photo_library_rounded;
      case AppPermissionType.locationWhenInUse:
      case AppPermissionType.locationAlways:
        return Icons.location_on_rounded;
      case AppPermissionType.microphone:
        return Icons.mic_rounded;
      case AppPermissionType.storage:
        return Icons.folder_rounded;
      case AppPermissionType.notification:
        return Icons.notifications_rounded;
      case AppPermissionType.bluetooth:
        return Icons.bluetooth_rounded;
      case AppPermissionType.appTrackingTransparency:
        return Icons.track_changes_rounded;
    }
  }
}
