import 'package:flutter/material.dart';

/// Normalized aggregate device and application metadata.
@immutable
class AppDeviceInfo {
  const AppDeviceInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.deviceModel,
    required this.osName,
    required this.osVersion,
    required this.isPhysicalDevice,
  });

  /// The customer-facing app name.
  final String appName;

  /// The bundle ID / package name (e.g. 'com.nungu.codestore').
  final String packageName;

  /// Semantic version string (e.g. '1.0.0').
  final String version;

  /// Build number (e.g. '1').
  final String buildNumber;

  /// Hardware device model (e.g. 'iPhone 15 Pro', 'Pixel 8').
  final String deviceModel;

  /// Operating system name (e.g. 'iOS', 'Android', 'macOS', 'Web').
  final String osName;

  /// Operating system version (e.g. '17.4', '14.0').
  final String osVersion;

  /// Whether running on physical hardware vs simulator/emulator.
  final bool isPhysicalDevice;

  /// Formatted full version string (e.g. 'v1.0.0 (1)').
  String get formattedVersion => 'v$version ($buildNumber)';

  @override
  String toString() =>
      'AppDeviceInfo(app: $appName, version: $formattedVersion, device: $deviceModel, os: $osName $osVersion)';
}
