import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/app_connectivity_status.dart';
import 'i_connectivity_service.dart';

/// Concrete implementation of [IConnectivityService] using [Connectivity].
class ConnectivityService implements IConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  AppConnectivityType _toAppType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return AppConnectivityType.wifi;
      case ConnectivityResult.mobile:
        return AppConnectivityType.cellular;
      case ConnectivityResult.ethernet:
        return AppConnectivityType.ethernet;
      case ConnectivityResult.none:
        return AppConnectivityType.none;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
      default:
        return AppConnectivityType.other;
    }
  }

  AppConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    final types = results.map(_toAppType).toList();
    return AppConnectivityStatus.online(types);
  }

  @override
  Future<AppConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapResults(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return AppConnectivityStatus.offline();
    }
  }

  @override
  Stream<AppConnectivityStatus> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_mapResults);

  @override
  Future<bool> get isConnected async {
    final status = await checkConnectivity();
    return status.isConnected;
  }
}
