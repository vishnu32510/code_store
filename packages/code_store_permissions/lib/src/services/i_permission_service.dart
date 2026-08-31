import '../models/app_permission_status.dart';
import '../models/app_permission_type.dart';

/// Abstract contract for managing, querying, and requesting device permissions.
abstract interface class IPermissionService {
  /// Checks the current status of a specific permission without triggering an OS prompt.
  Future<AppPermissionStatus> checkPermission(AppPermissionType type);

  /// Requests a specific permission from the user.
  Future<AppPermissionStatus> requestPermission(AppPermissionType type);

  /// Requests multiple permissions sequentially or in a batch.
  Future<Map<AppPermissionType, AppPermissionStatus>> requestPermissions(
    List<AppPermissionType> types,
  );

  /// Returns whether a permission is currently granted and ready to use.
  Future<bool> isGranted(AppPermissionType type);

  /// Returns whether the UI should show an educational rationale before requesting permission (Android).
  Future<bool> shouldShowRequestRationale(AppPermissionType type);

  /// Opens the device App Settings page so the user can re-enable permanently denied permissions.
  Future<bool> openAppSettings();
}
