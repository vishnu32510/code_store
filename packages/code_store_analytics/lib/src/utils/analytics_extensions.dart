import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../services/i_analytics_service.dart';

/// Extension on [BuildContext] for ergonomic access to [IAnalyticsService].
extension AnalyticsContextExtension on BuildContext {
  /// Resolves the registered [IAnalyticsService] from [GetIt].
  IAnalyticsService get analytics => GetIt.instance<IAnalyticsService>();

  /// Logs a custom event shorthand.
  void logAnalyticsEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) {
    analytics.logEvent(name: name, parameters: parameters);
  }
}
