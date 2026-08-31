import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../models/biometric_auth_result.dart';

/// Abstract contract for biometric hardware verification, authentication, and app lock management.
abstract interface class IBiometricService {
  /// Whether the device hardware supports biometrics (Face ID, Touch ID, Fingerprint, Iris).
  Future<bool> isDeviceSupported();

  /// Whether the device has biometric hardware AND is capable of checking biometrics.
  Future<bool> canCheckBiometrics();

  /// Whether biometrics are both supported AND currently enrolled by the user.
  Future<bool> isBiometricAvailable();

  /// Retrieves the list of enrolled biometric types on the device (e.g. `face`, `fingerprint`, `iris`).
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Returns true if at least one biometric method (Face ID, Fingerprint, etc.) is enrolled.
  Future<bool> hasEnrolledBiometrics();

  /// Prompts the user for biometric authentication with customizable options.
  ///
  /// [localizedReason]: Message displayed to the user explaining why authentication is needed.
  /// [biometricOnly]: If true, prevents falling back to the device passcode/PIN.
  /// [stickyAuth]: If true, keeps the auth dialog active if the app transitions to background momentarily.
  /// [sensitiveTransaction]: True if authentication confirms a high-value or sensitive action.
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
    String? cancelButtonText,
  });

  /// Cancels any currently active biometric prompt.
  Future<bool> stopAuthentication();

  /// Returns whether Biometric App Lock on app reopen/resume is enabled by the user.
  Future<bool> isAppLockEnabled();

  /// Persists the Biometric App Lock preference.
  Future<void> setAppLockEnabled(bool enabled);

  /// ValueNotifier that emits `true` when the app is currently in a locked state requiring biometric unlock.
  ValueNotifier<bool> get isLockedNotifier;

  /// Convenience getter for whether the app is currently locked.
  bool get isLocked;

  /// Sets the app state to locked (triggering the Biometric Lock Gate UI).
  void lock();

  /// Manually marks the app as unlocked.
  void unlock();

  /// Triggers a biometric prompt specifically to unlock the app gate.
  Future<BiometricAuthResult> promptUnlock({
    String localizedReason = 'Authenticate to unlock the application',
  });
}
