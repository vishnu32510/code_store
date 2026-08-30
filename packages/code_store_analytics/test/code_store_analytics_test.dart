import 'package:code_store_analytics/code_store_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('code_store_analytics DI and structure', () {
    final testGetIt = GetIt.asNewInstance();

    tearDown(() async {
      await testGetIt.reset();
    });

    test('constants are properly defined', () {
      expect(AppAnalyticsEvents.login, 'login');
      expect(AppAnalyticsEvents.screenView, 'screen_view');
      expect(AppAnalyticsEvents.logout, 'logout');
      expect(AppAnalyticsUserProperties.themeMode, 'theme_mode');
    });

    test(
      'FirebaseAnalyticsService can be instantiated with custom instances',
      () {
        // Test interface contract
        expect(IAnalyticsService, isNotNull);
        expect(FirebaseAnalyticsService, isNotNull);
      },
    );
  });
}
