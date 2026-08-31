import 'dart:async';

import 'package:code_store_connectivity/code_store_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockConnectivityService implements IConnectivityService {
  AppConnectivityStatus _current = AppConnectivityStatus.online([
    AppConnectivityType.wifi,
  ]);
  final _controller = StreamController<AppConnectivityStatus>.broadcast();

  void emit(AppConnectivityStatus status) {
    _current = status;
    _controller.add(status);
  }

  @override
  Future<AppConnectivityStatus> checkConnectivity() async => _current;

  @override
  Stream<AppConnectivityStatus> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async => _current.isConnected;

  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity Models & DI', () {
    final sl = GetIt.asNewInstance();

    test('AppConnectivityStatus properties work', () {
      final online = AppConnectivityStatus.online([AppConnectivityType.wifi]);
      expect(online.isConnected, true);
      expect(online.isWifi, true);
      expect(online.primaryTypeName, 'Wi-Fi');

      final offline = AppConnectivityStatus.offline();
      expect(offline.isConnected, false);
      expect(offline.primaryTypeName, 'Offline');
      expect(offline.icon, Icons.wifi_off_rounded);
    });

    test('setupConnectivityDI registers mock correctly', () {
      final mock = MockConnectivityService();
      setupConnectivityDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IConnectivityService>(), true);
      expect(sl<IConnectivityService>(), isA<MockConnectivityService>());
    });
  });

  group('OfflineBannerWrapper Widget Tests', () {
    late MockConnectivityService mockService;

    setUp(() {
      mockService = MockConnectivityService();
    });

    tearDown(() {
      mockService.dispose();
    });

    testWidgets('Displays child when online and banner when offline', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineBannerWrapper(
              connectivityService: mockService,
              child: const Text('Main Screen Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Screen Content'), findsOneWidget);
      expect(find.text('No Internet Connection (Offline)'), findsNothing);

      // Simulate offline drop
      mockService.emit(AppConnectivityStatus.offline());
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection (Offline)'), findsOneWidget);
    });
  });
}
