import 'package:flutter/material.dart';

/// Normalized connectivity state.
enum AppConnectivityType {
  /// Connected via Wi-Fi.
  wifi,

  /// Connected via Mobile Cellular data (5G/4G/LTE).
  cellular,

  /// Connected via Ethernet cable.
  ethernet,

  /// Connected via Bluetooth tethering or VPN.
  other,

  /// No active internet connectivity detected.
  none,
}

/// Normalized connectivity status object.
@immutable
class AppConnectivityStatus {
  const AppConnectivityStatus({required this.types, required this.isConnected});

  /// The active network interfaces.
  final List<AppConnectivityType> types;

  /// Whether the device has an active internet-capable network connection.
  final bool isConnected;

  /// Returns true if connected via Wi-Fi.
  bool get isWifi => types.contains(AppConnectivityType.wifi);

  /// Returns true if connected via Cellular data.
  bool get isCellular => types.contains(AppConnectivityType.cellular);

  /// Primary network interface name.
  String get primaryTypeName {
    if (!isConnected ||
        types.isEmpty ||
        types.contains(AppConnectivityType.none)) {
      return 'Offline';
    }
    if (types.contains(AppConnectivityType.wifi)) {
      return 'Wi-Fi';
    }
    if (types.contains(AppConnectivityType.cellular)) {
      return 'Cellular';
    }
    if (types.contains(AppConnectivityType.ethernet)) {
      return 'Ethernet';
    }
    return 'Connected';
  }

  /// Primary network Material Icon.
  IconData get icon {
    if (!isConnected || types.contains(AppConnectivityType.none)) {
      return Icons.wifi_off_rounded;
    }
    if (types.contains(AppConnectivityType.wifi)) {
      return Icons.wifi_rounded;
    }
    if (types.contains(AppConnectivityType.cellular)) {
      return Icons.signal_cellular_alt_rounded;
    }
    if (types.contains(AppConnectivityType.ethernet)) {
      return Icons.lan_rounded;
    }
    return Icons.cloud_done_rounded;
  }

  /// Factory for disconnected offline status.
  factory AppConnectivityStatus.offline() => const AppConnectivityStatus(
    types: [AppConnectivityType.none],
    isConnected: false,
  );

  /// Factory for connected status.
  factory AppConnectivityStatus.online(List<AppConnectivityType> types) =>
      AppConnectivityStatus(
        types: types,
        isConnected:
            types.isNotEmpty && !types.contains(AppConnectivityType.none),
      );

  @override
  String toString() =>
      'AppConnectivityStatus(connected: $isConnected, types: $types)';
}
