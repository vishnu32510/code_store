library;

// Re-export local_auth types for consuming apps
export 'package:local_auth/local_auth.dart'
    show LocalAuthentication, BiometricType, AuthenticationOptions;

// DI
export 'src/di/biometrics_injection.dart';

// Models
export 'src/models/biometric_auth_result.dart';

// Services
export 'src/services/biometric_service.dart';
export 'src/services/i_biometric_service.dart';

// Widgets
export 'src/widgets/biometric_lock_gate.dart';
