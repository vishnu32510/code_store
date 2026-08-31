import 'package:code_store_device_info/code_store_device_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockDeviceInfoService implements IDeviceInfoService {
  @override
  Future<AppDeviceInfo> getDeviceInfo() async => const AppDeviceInfo(
    appName: 'CodeStore Demo',
    packageName: 'com.nungu.codestore',
    version: '1.2.0',
    buildNumber: '42',
    deviceModel: 'Test Device',
    osName: 'iOS',
    osVersion: '17.4',
    isPhysicalDevice: false,
  );

  @override
  Future<String> getAppVersion() async => '1.2.0';

  @override
  Future<String> getBuildNumber() async => '42';

  @override
  Future<String> getPackageName() async => 'com.nungu.codestore';

  @override
  Future<bool> isUpdateRequired(String minimumRequiredVersion) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfo Models & DI', () {
    final sl = GetIt.asNewInstance();

    test('AppDeviceInfo properties and formatted version work', () {
      const info = AppDeviceInfo(
        appName: 'CodeStore',
        packageName: 'com.nungu.codestore',
        version: '1.0.0',
        buildNumber: '1',
        deviceModel: 'iPhone 15',
        osName: 'iOS',
        osVersion: '17.0',
        isPhysicalDevice: true,
      );

      expect(info.formattedVersion, 'v1.0.0 (1)');
      expect(info.isPhysicalDevice, true);
    });

    test('setupDeviceInfoDI registers mock service correctly', () {
      final mock = MockDeviceInfoService();
      setupDeviceInfoDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IDeviceInfoService>(), true);
      expect(sl<IDeviceInfoService>(), isA<MockDeviceInfoService>());
    });

    test('MockDeviceInfoService returns expected values', () async {
      final service = MockDeviceInfoService();
      final info = await service.getDeviceInfo();

      expect(info.appName, 'CodeStore Demo');
      expect(info.version, '1.2.0');
      expect(await service.getPackageName(), 'com.nungu.codestore');
    });
  });
}
