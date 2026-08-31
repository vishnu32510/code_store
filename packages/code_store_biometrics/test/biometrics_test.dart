import 'package:code_store_biometrics/code_store_biometrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockBiometricService implements IBiometricService {
  bool supported = true;
  bool canCheck = true;
  List<BiometricType> available = [
    BiometricType.face,
    BiometricType.fingerprint,
  ];
  BiometricAuthResult authResult = BiometricAuthResult.success();

  bool _appLockEnabled = false;
  final ValueNotifier<bool> _isLockedNotifier = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isLockedNotifier => _isLockedNotifier;

  @override
  bool get isLocked => _isLockedNotifier.value;

  @override
  void lock() => _isLockedNotifier.value = true;

  @override
  void unlock() => _isLockedNotifier.value = false;

  @override
  Future<bool> isAppLockEnabled() async => _appLockEnabled;

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    _appLockEnabled = enabled;
    if (!enabled) unlock();
  }

  @override
  Future<BiometricAuthResult> promptUnlock({
    String localizedReason = 'Authenticate to unlock the application',
  }) async {
    final res = await authenticate(localizedReason: localizedReason);
    if (res.isSuccess) unlock();
    return res;
  }

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> canCheckBiometrics() async => canCheck;

  @override
  Future<bool> isBiometricAvailable() async => supported && canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => available;

  @override
  Future<bool> hasEnrolledBiometrics() async => available.isNotEmpty;

  @override
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
    String? cancelButtonText,
  }) async {
    return authResult;
  }

  @override
  Future<bool> stopAuthentication() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricAuthResult Model Tests', () {
    test('Success factory generates isSuccess = true', () {
      final res = BiometricAuthResult.success();
      expect(res.isSuccess, true);
      expect(res.status, BiometricAuthStatus.success);
      expect(res.errorMessage, isNull);
    });

    test(
      'Failed, Canceled, and Lockout factories generate appropriate status',
      () {
        final failed = BiometricAuthResult.failed('Wrong fingerprint');
        expect(failed.isSuccess, false);
        expect(failed.status, BiometricAuthStatus.failed);
        expect(failed.errorMessage, 'Wrong fingerprint');

        final canceled = BiometricAuthResult.canceled();
        expect(canceled.isSuccess, false);
        expect(canceled.status, BiometricAuthStatus.userCanceled);

        final notEnrolled = BiometricAuthResult.notEnrolled();
        expect(notEnrolled.status, BiometricAuthStatus.notEnrolled);

        final lockedOut = BiometricAuthResult.lockedOut();
        expect(lockedOut.status, BiometricAuthStatus.lockedOut);

        final permLocked = BiometricAuthResult.permanentlyLockedOut();
        expect(permLocked.status, BiometricAuthStatus.permanentlyLockedOut);
      },
    );
  });

  group('Biometrics DI & App Lock Tests', () {
    final sl = GetIt.asNewInstance();

    test('setupBiometricsDI registers custom mock service', () {
      final mock = MockBiometricService();
      setupBiometricsDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IBiometricService>(), true);
      expect(sl<IBiometricService>(), isA<MockBiometricService>());
    });

    test('App lock toggle updates state and persists correctly', () async {
      final service = MockBiometricService();
      expect(await service.isAppLockEnabled(), false);

      await service.setAppLockEnabled(true);
      expect(await service.isAppLockEnabled(), true);

      service.lock();
      expect(service.isLocked, true);

      await service.promptUnlock();
      expect(service.isLocked, false);
    });
  });

  group('BiometricLockGate Widget Tests', () {
    testWidgets('Renders child directly when not locked', (tester) async {
      final mock = MockBiometricService();

      await tester.pumpWidget(
        MaterialApp(
          home: BiometricLockGate(
            biometricService: mock,
            child: const Text('Secret App Content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Secret App Content'), findsOneWidget);
      expect(find.text('App Locked'), findsNothing);
    });

    testWidgets('Renders lock screen when locked and unlocks upon prompt', (
      tester,
    ) async {
      final mock = MockBiometricService();
      mock._appLockEnabled = true;
      mock.lock();

      await tester.pumpWidget(
        MaterialApp(
          home: BiometricLockGate(
            biometricService: mock,
            child: const Text('Secret App Content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('App Locked'), findsOneWidget);
      expect(find.text('Secret App Content'), findsNothing);

      // Tap Unlock button
      await tester.tap(find.text('Unlock with Biometrics'));
      await tester.pumpAndSettle();

      expect(find.text('Secret App Content'), findsOneWidget);
      expect(find.text('App Locked'), findsNothing);
    });
  });
}
