import 'package:get_it/get_it.dart';

import '../services/home_widget_service.dart';

/// Registers [HomeWidgetService] into [GetIt].
///
/// Call this once at app startup (e.g., inside your root `setupDI()`).
///
/// Parameters:
/// - [locator] — optional custom GetIt instance (defaults to `GetIt.instance`).
/// - [appGroupId] — iOS App Group ID shared between the app and WidgetKit extension.
/// - [defaultAndroidName] — the Android AppWidget class / provider name.
/// - [defaultIOSName] — the iOS WidgetKit widget kind string.
///
/// After calling this, remember to await `getIt<HomeWidgetService>().initialize()`
/// during your async startup phase so the native platform is configured.
void setupHomeWidgetDI({
  GetIt? locator,
  String? appGroupId,
  String? defaultAndroidName,
  String? defaultIOSName,
}) {
  final di = locator ?? GetIt.instance;

  if (!di.isRegistered<HomeWidgetService>()) {
    di.registerLazySingleton<HomeWidgetService>(
      () => HomeWidgetService(
        appGroupId: appGroupId,
        defaultAndroidName: defaultAndroidName,
        defaultIOSName: defaultIOSName,
      ),
    );
  }
}
