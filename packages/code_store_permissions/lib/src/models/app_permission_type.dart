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
        return 'Camera access is required to take photos, scan codes, or use flashlight tools.';
      case AppPermissionType.photos:
        return 'Photo Library access is required to select, preview, and save media.';
      case AppPermissionType.locationWhenInUse:
        return 'Location access is required to deliver localized features and services.';
      case AppPermissionType.locationAlways:
        return 'Background location access is required for real-time tracking and geofencing.';
      case AppPermissionType.microphone:
        return 'Microphone access is required to record audio and voice messages.';
      case AppPermissionType.storage:
        return 'Storage access is required to read and write application files.';
      case AppPermissionType.notification:
        return 'Notification permissions are required to receive important alerts and updates.';
      case AppPermissionType.bluetooth:
        return 'Bluetooth access is required to discover and connect with nearby devices.';
      case AppPermissionType.appTrackingTransparency:
        return 'Tracking permission helps provide a more personalized app experience.';
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
