import 'package:get_it/get_it.dart';

import '../services/card_scanner_service.dart';
import '../services/i_card_scanner_service.dart';

/// Idempotently registers card scanner services into GetIt.
void setupCardScannerDI({GetIt? locator, ICardScannerService? customService}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<ICardScannerService>()) {
      di.registerSingleton<ICardScannerService>(customService);
    }
    return;
  }

  if (!di.isRegistered<ICardScannerService>()) {
    const service = CardScannerService();
    di.registerLazySingleton<ICardScannerService>(() => service);

    if (!di.isRegistered<CardScannerService>()) {
      di.registerLazySingleton<CardScannerService>(() => service);
    }
  }
}
