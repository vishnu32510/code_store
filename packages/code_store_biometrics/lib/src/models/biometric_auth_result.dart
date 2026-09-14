import 'package:flutter/foundation.dart';

/// Status outcomes of a biometric authentication request.
enum BiometricAuthStatus {
  /// The user successfully authenticated with biometrics or passcode.
  success,

  /// Biometric verification failed (e.g. unrecognized face/fingerprint).
  failed,

  /// The user dismissed or canceled the biometric prompt.
  userCanceled,

  /// Biometric hardware is not available on this device.
  notAvailable,

  /// No biometrics (face, fingerprint) are enrolled/registered on the device.
  notEnrolled,

  /// Biometric sensor is temporarily locked due to too many failed attempts.
  lockedOut,

  /// Biometric sensor is permanently locked (requires device passcode unlock).
  permanentlyLockedOut,

  /// An unexpected platform error occurred.
  error,
}

/// Normalized result of a biometric authentication attempt.
@immutable
class BiometricAuthResult {
  const BiometricAuthResult({required this.status, this.errorMessage});

  /// The outcome status of the authentication attempt.
  final BiometricAuthStatus status;

  /// Optional error or diagnostic message if authentication did not succeed.
  final String? errorMessage;

  /// Convenience getter indicating whether the user was authenticated.
  bool get isSuccess => status == BiometricAuthStatus.success;

  /// Convenience factory for a successful outcome.
  factory BiometricAuthResult.success() =>
      const BiometricAuthResult(status: BiometricAuthStatus.success);

  /// Convenience factory for a failed outcome.
  factory BiometricAuthResult.failed([String? message]) => BiometricAuthResult(
    status: BiometricAuthStatus.failed,
    errorMessage: message ?? 'Biometric verification failed.',
  );

  /// Convenience factory for user cancellation.
  factory BiometricAuthResult.canceled() =>
      const BiometricAuthResult(status: BiometricAuthStatus.userCanceled);

  /// Convenience factory for unavailable hardware.
  factory BiometricAuthResult.notAvailable([String? message]) =>
      BiometricAuthResult(
        status: BiometricAuthStatus.notAvailable,
        errorMessage: message ?? 'Biometrics are not available on this device.',
      );

  /// Convenience factory for no enrolled biometrics.
  factory BiometricAuthResult.notEnrolled([String? message]) =>
      BiometricAuthResult(
        status: BiometricAuthStatus.notEnrolled,
        errorMessage: message ?? 'No biometrics are enrolled. Please set up Face ID or Fingerprint in Settings.',
      );

  /// Convenience factory for temporary lockout.
  factory BiometricAuthResult.lockedOut([String? message]) =>
      BiometricAuthResult(
        status: BiometricAuthStatus.lockedOut,
        errorMessage:
            message ??
            'Too many failed attempts. Biometric sensor temporarily locked.',
      );

  /// Convenience factory for permanent lockout.
  factory BiometricAuthResult.permanentlyLockedOut([String? message]) =>
      BiometricAuthResult(
        status: BiometricAuthStatus.permanentlyLockedOut,
        errorMessage: message ?? 'Biometrics permanently locked out. Please unlock with device passcode.',
      );

  /// Convenience factory for unexpected errors.
  factory BiometricAuthResult.error(String message) => BiometricAuthResult(
    status: BiometricAuthStatus.error,
    errorMessage: message,
  );

  @override
  String toString() =>
      'BiometricAuthResult(status: $status, message: $errorMessage)';
}
