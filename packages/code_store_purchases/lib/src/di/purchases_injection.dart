import 'package:get_it/get_it.dart';

import '../services/i_purchase_service.dart';
import '../services/purchases_service.dart';

/// Registers [IPurchaseService] into the dependency injection locator.
void setupPurchasesDI({
  GetIt? locator,
  IPurchaseService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<IPurchaseService>()) {
      di.registerSingleton<IPurchaseService>(customService);
    }
    return;
  }

  if (!di.isRegistered<IPurchaseService>()) {
    final service = PurchasesService();
    di.registerLazySingleton<IPurchaseService>(() => service);

    if (!di.isRegistered<PurchasesService>()) {
      di.registerLazySingleton<PurchasesService>(() => service);
    }
  }
}
