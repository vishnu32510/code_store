library;

// Re-export connectivity_plus types for consuming apps
export 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;

// DI
export 'src/di/connectivity_injection.dart';

// Models
export 'src/models/app_connectivity_status.dart';

// Services
export 'src/services/connectivity_service.dart';
export 'src/services/i_connectivity_service.dart';

// Widgets
export 'src/widgets/offline_banner_wrapper.dart';
