import 'package:code_store_permissions/code_store_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockPermissionService implements IPermissionService {
  AppPermissionStatus status = AppPermissionStatus.granted;
  bool settingsOpened = false;

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async =>
      status;

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async =>
      status;

  @override
  Future<Map<AppPermissionType, AppPermissionStatus>> requestPermissions(
    List<AppPermissionType> types,
  ) async {
    return {for (var t in types) t: status};
  }

  @override
  Future<bool> isGranted(AppPermissionType type) async => status.isGranted;

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionType type) async =>
      status == AppPermissionStatus.denied;

  @override
  Future<bool> openAppSettings() async {
    settingsOpened = true;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPermissionType & Status Models', () {
    test('AppPermissionType metadata properties work', () {
      expect(AppPermissionType.camera.displayName, 'Camera');
      expect(AppPermissionType.camera.icon, Icons.camera_alt_rounded);
      expect(
        AppPermissionType.camera.defaultRationale.isNotEmpty,
        true,
      );
      expect(AppPermissionType.photos.displayName, 'Photo Library');
    });

    test('AppPermissionStatusExtension checks work correctly', () {
      expect(AppPermissionStatus.granted.isGranted, true);
      expect(AppPermissionStatus.limited.isGranted, true);
      expect(AppPermissionStatus.provisional.isGranted, true);
      expect(AppPermissionStatus.denied.isGranted, false);
      expect(AppPermissionStatus.permanentlyDenied.isPermanentlyDenied, true);
    });
  });

  group('Permissions DI Tests', () {
    final sl = GetIt.asNewInstance();

    test('setupPermissionsDI registers mock service correctly', () {
      final mock = MockPermissionService();
      setupPermissionsDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IPermissionService>(), true);
      expect(sl<IPermissionService>(), isA<MockPermissionService>());
    });

    test('MockPermissionService behaves as expected', () async {
      final mock = MockPermissionService();
      expect(await mock.isGranted(AppPermissionType.camera), true);

      mock.status = AppPermissionStatus.denied;
      expect(await mock.isGranted(AppPermissionType.camera), false);
      expect(
        await mock.shouldShowRequestRationale(AppPermissionType.camera),
        true,
      );

      await mock.openAppSettings();
      expect(mock.settingsOpened, true);
    });
  });

  group('PermissionRationaleDialog Widget Tests', () {
    testWidgets('Renders title, description, and handles confirmation',
        (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRationaleDialog(
              permissionType: AppPermissionType.camera,
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Camera Permission'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(confirmed, true);
    });
  });
}
