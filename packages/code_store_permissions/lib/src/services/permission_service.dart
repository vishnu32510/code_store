import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../models/app_permission_status.dart';
import '../models/app_permission_type.dart';
import 'i_permission_service.dart';

/// Concrete implementation of [IPermissionService] wrapping `permission_handler`.
class PermissionService implements IPermissionService {
  const PermissionService();

  ph.Permission _toNativePermission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.camera:
        return ph.Permission.camera;
      case AppPermissionType.photos:
        return ph.Permission.photos;
      case AppPermissionType.locationWhenInUse:
        return ph.Permission.locationWhenInUse;
      case AppPermissionType.locationAlways:
        return ph.Permission.locationAlways;
      case AppPermissionType.microphone:
        return ph.Permission.microphone;
      case AppPermissionType.storage:
        return ph.Permission.storage;
      case AppPermissionType.notification:
        return ph.Permission.notification;
      case AppPermissionType.bluetooth:
        return ph.Permission.bluetooth;
      case AppPermissionType.appTrackingTransparency:
        return ph.Permission.appTrackingTransparency;
    }
  }

  AppPermissionStatus _toAppStatus(ph.PermissionStatus status) {
    if (status.isGranted) {
      return AppPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) {
      return AppPermissionStatus.restricted;
    }
    if (status.isLimited) {
      return AppPermissionStatus.limited;
    }
    if (status.isProvisional) {
      return AppPermissionStatus.provisional;
    }
    return AppPermissionStatus.denied;
  }

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    if (kIsWeb) {
      return AppPermissionStatus.granted;
    }
    try {
      final nativePerm = _toNativePermission(type);
      final status = await nativePerm.status;
      return _toAppStatus(status);
    } catch (e) {
      debugPrint('Error checking permission $type: $e');
      return AppPermissionStatus.denied;
    }
  }

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    if (kIsWeb) {
      return AppPermissionStatus.granted;
    }
    try {
      final nativePerm = _toNativePermission(type);
      final status = await nativePerm.request();
      return _toAppStatus(status);
    } catch (e) {
      debugPrint('Error requesting permission $type: $e');
      return AppPermissionStatus.denied;
    }
  }

  @override
  Future<Map<AppPermissionType, AppPermissionStatus>> requestPermissions(
    List<AppPermissionType> types,
  ) async {
    final Map<AppPermissionType, AppPermissionStatus> results = {};
    for (final type in types) {
      results[type] = await requestPermission(type);
    }
    return results;
  }

  @override
  Future<bool> isGranted(AppPermissionType type) async {
    final status = await checkPermission(type);
    return status.isGranted;
  }

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionType type) async {
    if (kIsWeb) return false;
    try {
      final nativePerm = _toNativePermission(type);
      return await nativePerm.shouldShowRequestRationale;
    } catch (e) {
      debugPrint('Error checking shouldShowRequestRationale for $type: $e');
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    if (kIsWeb) return false;
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }
}
