library;

// Re-export permission_handler types for consuming apps
export 'package:permission_handler/permission_handler.dart'
    show
        Permission,
        PermissionStatus,
        openAppSettings;

// DI
export 'src/di/permissions_injection.dart';

// Models
export 'src/models/app_permission_status.dart';
export 'src/models/app_permission_type.dart';

// Services
export 'src/services/i_permission_service.dart';
export 'src/services/permission_service.dart';

// Widgets
export 'src/widgets/permission_rationale_dialog.dart';
