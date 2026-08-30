import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';

import '../services/firebase_analytics_service.dart';
import '../services/i_analytics_service.dart';

/// Registers Firebase Analytics services and navigation observer into [GetIt].
///
/// If [locator] is omitted, [GetIt.instance] is used.
/// You can pass a custom [analyticsInstance] or [observer] for unit tests.
void setupAnalyticsDI({
  GetIt? locator,
  FirebaseAnalytics? analyticsInstance,
  FirebaseAnalyticsObserver? observer,
}) {
  final di = locator ?? GetIt.instance;

  final analytics = analyticsInstance ?? FirebaseAnalytics.instance;
  final navObserver =
      observer ?? FirebaseAnalyticsObserver(analytics: analytics);

  if (!di.isRegistered<FirebaseAnalytics>()) {
    di.registerSingleton<FirebaseAnalytics>(analytics);
  }

  if (!di.isRegistered<FirebaseAnalyticsObserver>()) {
    di.registerSingleton<FirebaseAnalyticsObserver>(navObserver);
  }

  if (!di.isRegistered<IAnalyticsService>()) {
    final service = FirebaseAnalyticsService(
      analytics: di<FirebaseAnalytics>(),
      observer: di<FirebaseAnalyticsObserver>(),
    );
    di.registerSingleton<IAnalyticsService>(service);
    if (!di.isRegistered<FirebaseAnalyticsService>()) {
      di.registerSingleton<FirebaseAnalyticsService>(service);
    }
  }
}
