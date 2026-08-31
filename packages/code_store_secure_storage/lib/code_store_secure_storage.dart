library;

// Re-export flutter_secure_storage types for consuming apps
export 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show
        FlutterSecureStorage,
        IOSOptions,
        AndroidOptions,
        MacOsOptions,
        WebOptions,
        KeychainAccessibility;

// DI
export 'src/di/secure_storage_injection.dart';

// Services
export 'src/services/i_secure_storage_service.dart';
export 'src/services/secure_storage_service.dart';
