import 'package:firebase_analytics/firebase_analytics.dart';

/// Abstract interface for application analytics.
///
/// Designed to be registered in `GetIt` via `setupAnalyticsDI()`.
abstract interface class IAnalyticsService {
  /// The underlying [FirebaseAnalytics] instance for advanced operations.
  FirebaseAnalytics get rawAnalytics;

  /// The [FirebaseAnalyticsObserver] for route/navigation tracking.
  FirebaseAnalyticsObserver get observer;

  /// Logs a custom event with [name] and optional [parameters].
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  });

  /// Logs a custom event with [name] and optional [parameters] (convenience shorthand).
  Future<void> logCustomEvent(String name, [Map<String, Object?>? parameters]);

  /// Sets the current active screen name for analytics tracking.
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  });

  /// Sets the user identifier for analytics tracking.
  Future<void> setUserId(String? userId);

  /// Sets a user property [name] to [value].
  Future<void> setUserProperty({required String name, required String? value});

  /// Logs a user sign-in event with an optional [loginMethod] (e.g. 'google', 'apple', 'email').
  Future<void> logLogin({String? loginMethod});

  /// Logs a user sign-up event with [signUpMethod] (e.g. 'google', 'apple', 'email').
  Future<void> logSignUp({required String signUpMethod});

  /// Logs a search event with query [searchTerm].
  Future<void> logSearch({
    required String searchTerm,
    String? destination,
    String? origin,
    String? startDate,
    String? endDate,
    int? numberOfRooms,
    int? numberOfPassengers,
    int? numberOfNights,
  });

  /// Logs a content selection event.
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  });

  /// Logs a share event.
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  });

  /// Resets all analytics data for the current session/user.
  Future<void> resetAnalyticsData();

  /// Enables or disables analytics collection (e.g. for GDPR / consent settings).
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Sets default parameters that will be included with every logged event.
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  );

  /// Sets the duration of inactivity that terminates the current session.
  Future<void> setSessionTimeoutDuration(Duration timeout);

  /// Retrieves the app instance ID from Firebase Analytics.
  Future<String?> getAppInstanceId();

  /// Sets consent settings for analytics and ad storage (GDPR / Privacy compliance).
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adUserDataConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
  });
}
