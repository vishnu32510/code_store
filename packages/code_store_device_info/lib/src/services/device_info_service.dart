import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_device_info.dart';
import 'i_device_info_service.dart';

/// Concrete implementation of [IDeviceInfoService] wrapping `package_info_plus` and `device_info_plus`.
class DeviceInfoService implements IDeviceInfoService {
  DeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfoPlugin;
  PackageInfo? _cachedPackageInfo;

  Future<PackageInfo> _getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  @override
  Future<AppDeviceInfo> getDeviceInfo() async {
    final pkg = await _getPackageInfo();

    String deviceModel = 'Unknown Device';
    String osName = 'Unknown OS';
    String osVersion = '';
    bool isPhysicalDevice = true;

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        deviceModel = webInfo.browserName.name;
        osName = 'Web (${webInfo.platform})';
        osVersion = webInfo.userAgent ?? '';
        isPhysicalDevice = true;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        osName = 'iOS';
        osVersion = iosInfo.systemVersion;
        isPhysicalDevice = iosInfo.isPhysicalDevice;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osName = 'Android';
        osVersion =
            'SDK ${androidInfo.version.sdkInt} (${androidInfo.version.release})';
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        deviceModel = macInfo.model;
        osName = 'macOS';
        osVersion = macInfo.osRelease;
        isPhysicalDevice = true;
      }
    } catch (e) {
      debugPrint('Error retrieving hardware device info: $e');
    }

    return AppDeviceInfo(
      appName: pkg.appName.isNotEmpty ? pkg.appName : 'CodeStore',
      packageName: pkg.packageName,
      version: pkg.version,
      buildNumber: pkg.buildNumber,
      deviceModel: deviceModel,
      osName: osName,
      osVersion: osVersion,
      isPhysicalDevice: isPhysicalDevice,
    );
  }

  @override
  Future<String> getAppVersion() async {
    final pkg = await _getPackageInfo();
    return pkg.version;
  }

  @override
  Future<String> getBuildNumber() async {
    final pkg = await _getPackageInfo();
    return pkg.buildNumber;
  }

  @override
  Future<String> getPackageName() async {
    final pkg = await _getPackageInfo();
    return pkg.packageName;
  }

  @override
  Future<bool> isUpdateRequired(String minimumRequiredVersion) async {
    final current = await getAppVersion();
    return _compareSemver(current, minimumRequiredVersion) < 0;
  }

  int _compareSemver(String current, String target) {
    final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final tParts = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (cParts.length < 3) {
      cParts.add(0);
    }
    while (tParts.length < 3) {
      tParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (cParts[i] < tParts[i]) return -1;
      if (cParts[i] > tParts[i]) return 1;
    }
    return 0;
  }
}
