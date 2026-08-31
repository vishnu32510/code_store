library;

// Re-export purchases_flutter types
export 'package:purchases_flutter/purchases_flutter.dart'
    show Purchases, CustomerInfo, Package, StoreProduct, LogLevel;

// DI
export 'src/di/purchases_injection.dart';

// Models
export 'src/models/app_subscription_package.dart';
export 'src/models/customer_entitlement_info.dart';
export 'src/models/purchase_result.dart';

// Services
export 'src/services/i_purchase_service.dart';
export 'src/services/purchases_service.dart';

// Widgets
export 'src/widgets/paywall_view.dart';
