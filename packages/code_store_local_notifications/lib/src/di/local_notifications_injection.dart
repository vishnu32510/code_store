import 'package:get_it/get_it.dart';
import '../services/flutter_local_notification_service.dart';
import '../services/i_local_notification_service.dart';

/// Registers the [ILocalNotificationService] lazy singleton into [GetIt].
void setupLocalNotificationsDI({GetIt? sl}) {
  final getIt = sl ?? GetIt.instance;
  if (!getIt.isRegistered<ILocalNotificationService>()) {
    getIt.registerLazySingleton<ILocalNotificationService>(
      () => FlutterLocalNotificationService(),
    );
  }
}
