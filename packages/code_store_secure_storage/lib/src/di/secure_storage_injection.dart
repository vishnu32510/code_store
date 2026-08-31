import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../services/i_secure_storage_service.dart';
import '../services/secure_storage_service.dart';

/// Registers [ISecureStorageService] into the dependency injection locator.
void setupSecureStorageDI({
  GetIt? locator,
  FlutterSecureStorage? storage,
  ISecureStorageService? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<ISecureStorageService>()) {
      di.registerSingleton<ISecureStorageService>(customService);
    }
    return;
  }

  if (!di.isRegistered<ISecureStorageService>()) {
    final service = SecureStorageService(storage: storage);
    di.registerLazySingleton<ISecureStorageService>(() => service);

    if (!di.isRegistered<SecureStorageService>()) {
      di.registerLazySingleton<SecureStorageService>(() => service);
    }
  }
}
