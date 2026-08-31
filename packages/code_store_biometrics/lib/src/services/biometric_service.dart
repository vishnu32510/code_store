import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/biometric_auth_result.dart';
import 'i_biometric_service.dart';

/// Concrete implementation of [IBiometricService] using [LocalAuthentication] and [SharedPreferences].
class BiometricService implements IBiometricService {
  BiometricService({
    LocalAuthentication? localAuth,
    SharedPreferencesAsync? prefs,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _prefs = prefs ?? SharedPreferencesAsync();

  final LocalAuthentication _localAuth;
  final SharedPreferencesAsync _prefs;

  static const String _appLockPrefKey = 'code_store_biometric_app_lock_enabled';

  final ValueNotifier<bool> _isLockedNotifier = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isLockedNotifier => _isLockedNotifier;

  @override
  bool get isLocked => _isLockedNotifier.value;

  @override
  void lock() {
    _isLockedNotifier.value = true;
  }

  @override
  void unlock() {
    _isLockedNotifier.value = false;
  }

  @override
  Future<bool> isAppLockEnabled() async {
    try {
      return await _prefs.getBool(_appLockPrefKey) ?? false;
    } catch (e) {
      debugPrint('Error reading isAppLockEnabled: $e');
      return false;
    }
  }

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_appLockPrefKey, enabled);
      if (!enabled) {
        unlock();
      }
    } catch (e) {
      debugPrint('Error saving setAppLockEnabled: $e');
    }
  }

  @override
  Future<BiometricAuthResult> promptUnlock({
    String localizedReason = 'Authenticate to unlock the application',
  }) async {
    final result = await authenticate(
      localizedReason: localizedReason,
      biometricOnly: false,
      stickyAuth: true,
      sensitiveTransaction: true,
    );

    if (result.isSuccess) {
      unlock();
    }
    return result;
  }

  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking isDeviceSupported: $e');
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking canCheckBiometrics: $e');
      return false;
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await isDeviceSupported();
      final canCheck = await canCheckBiometrics();
      return supported && canCheck;
    } catch (e) {
      debugPrint('Error checking isBiometricAvailable: $e');
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error retrieving available biometrics: $e');
      return const [];
    }
  }

  @override
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking enrolled biometrics: $e');
      return false;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
    String? cancelButtonText,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricAuthResult.notAvailable(
          'Biometrics are not supported on this device.',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failed();
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException [${e.code}]: ${e.message}');
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.passcodeNotSet:
          return BiometricAuthResult.notAvailable(e.message);
        case auth_error.notEnrolled:
          return BiometricAuthResult.notEnrolled(e.message);
        case auth_error.lockedOut:
          return BiometricAuthResult.lockedOut(e.message);
        case auth_error.permanentlyLockedOut:
          return BiometricAuthResult.permanentlyLockedOut(e.message);
        case 'UserCancel':
        case 'SystemCancel':
          return BiometricAuthResult.canceled();
        default:
          return BiometricAuthResult.error(
            e.message ?? 'Authentication error (${e.code}).',
          );
      }
    } catch (e) {
      debugPrint('Biometric unexpected error: $e');
      return BiometricAuthResult.error(e.toString());
    }
  }

  @override
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Error stopping biometric authentication: $e');
      return false;
    }
  }
}
