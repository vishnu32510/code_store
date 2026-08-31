import '../models/app_device_info.dart';

/// Abstract contract for querying application version and hardware diagnostics.
abstract interface class IDeviceInfoService {
  /// Fetches aggregate device and app info.
  Future<AppDeviceInfo> getDeviceInfo();

  /// Gets the current app semantic version (e.g. '1.0.0').
  Future<String> getAppVersion();

  /// Gets the current build number (e.g. '1').
  Future<String> getBuildNumber();

  /// Gets the package bundle identifier (e.g. 'com.nungu.codestore').
  Future<String> getPackageName();

  /// Checks if the current version meets a minimum required version (e.g. for Force Update).
  Future<bool> isUpdateRequired(String minimumRequiredVersion);
}
