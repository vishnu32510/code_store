import '../models/app_connectivity_status.dart';

/// Abstract contract for monitoring real-time network connectivity changes.
abstract interface class IConnectivityService {
  /// Checks current network connectivity status once.
  Future<AppConnectivityStatus> checkConnectivity();

  /// Stream of real-time network connectivity updates.
  Stream<AppConnectivityStatus> get onConnectivityChanged;

  /// Returns true if device currently has active network connectivity.
  Future<bool> get isConnected;
}
