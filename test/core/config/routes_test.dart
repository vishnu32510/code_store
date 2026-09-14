import 'package:flutter_test/flutter_test.dart';
import 'package:code_store/core/config/routes.dart';

void main() {
  group('AppRoutes', () {
    test('constants have correct values', () {
      expect(AppRoutes.dashboard, '/dashboard');
      expect(AppRoutes.flashlight, '/flashlight');
      expect(AppRoutes.homeWidget, '/home-widget');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.notifications, '/notifications');
      expect(AppRoutes.biometrics, '/biometrics');
      expect(AppRoutes.permissions, '/permissions');
      expect(AppRoutes.secureStorage, '/secure-storage');
      expect(AppRoutes.connectivity, '/connectivity');
      expect(AppRoutes.purchases, '/purchases');
      expect(AppRoutes.deviceInfo, '/device-info');
      expect(AppRoutes.share, '/share');
      expect(AppRoutes.dynamicIsland, '/dynamic-island');
    });
  });
}
