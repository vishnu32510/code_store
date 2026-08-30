import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'i_analytics_service.dart';

/// Default implementation of [IAnalyticsService] powered by Firebase Analytics.
class FirebaseAnalyticsService implements IAnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver _observer;

  FirebaseAnalyticsService({
    FirebaseAnalytics? analytics,
    FirebaseAnalyticsObserver? observer,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _observer = observer ??
            FirebaseAnalyticsObserver(
              analytics: analytics ?? FirebaseAnalytics.instance,
            );

  @override
  FirebaseAnalytics get rawAnalytics => _analytics;

  @override
  FirebaseAnalyticsObserver get observer => _observer;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    try {
      // Filter out null values for Firebase compatibility
      final cleanParams = parameters != null
          ? Map<String, Object>.fromEntries(
              parameters.entries
                  .where((e) => e.value != null)
                  .map((e) => MapEntry(e.key, e.value!)),
            )
          : null;

      await _analytics.logEvent(name: name, parameters: cleanParams);
      if (kDebugMode) {
        debugPrint('[Analytics] Event logged: $name, parameters: $cleanParams');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging event $name: $e');
    }
  }

  @override
  Future<void> logCustomEvent(
    String name, [
    Map<String, Object?>? parameters,
  ]) =>
      logEvent(name: name, parameters: parameters);

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClassOverride,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClassOverride,
      );
      if (kDebugMode) {
        debugPrint('[Analytics] Screen viewed: $screenName ($screenClassOverride)');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting current screen: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      if (kDebugMode) {
        debugPrint('[Analytics] User ID set: $userId');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting user ID: $e');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        debugPrint('[Analytics] User property set: $name = $value');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting user property $name: $e');
    }
  }

  @override
  Future<void> logLogin({String? loginMethod}) async {
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
      if (kDebugMode) {
        debugPrint('[Analytics] Login logged: $loginMethod');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging login: $e');
    }
  }

  @override
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
      if (kDebugMode) {
        debugPrint('[Analytics] Sign up logged: $signUpMethod');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging sign up: $e');
    }
  }

  @override
  Future<void> logSearch({
    required String searchTerm,
    String? destination,
    String? origin,
    String? startDate,
    String? endDate,
    int? numberOfRooms,
    int? numberOfPassengers,
    int? numberOfNights,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        destination: destination,
        origin: origin,
        startDate: startDate,
        endDate: endDate,
        numberOfRooms: numberOfRooms,
        numberOfPassengers: numberOfPassengers,
        numberOfNights: numberOfNights,
      );
      if (kDebugMode) {
        debugPrint('[Analytics] Search logged: $searchTerm');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging search: $e');
    }
  }

  @override
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
      if (kDebugMode) {
        debugPrint('[Analytics] Select content: type=$contentType, id=$itemId');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging select content: $e');
    }
  }

  @override
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
      );
      if (kDebugMode) {
        debugPrint('[Analytics] Share logged: type=$contentType, id=$itemId, method=$method');
      }
    } catch (e) {
      debugPrint('[Analytics] Error logging share: $e');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
      if (kDebugMode) {
        debugPrint('[Analytics] Analytics data reset');
      }
    } catch (e) {
      debugPrint('[Analytics] Error resetting analytics data: $e');
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      if (kDebugMode) {
        debugPrint('[Analytics] Analytics collection enabled: $enabled');
      }
    } catch (e) {
      debugPrint('[Analytics] Error toggling analytics collection: $e');
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) async {
    try {
      final cleanParams = defaultParameters != null
          ? Map<String, Object>.fromEntries(
              defaultParameters.entries
                  .where((e) => e.value != null)
                  .map((e) => MapEntry(e.key, e.value!)),
            )
          : null;
      await _analytics.setDefaultEventParameters(cleanParams);
      if (kDebugMode) {
        debugPrint('[Analytics] Default event parameters set: $cleanParams');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting default event parameters: $e');
    }
  }

  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    try {
      await _analytics.setSessionTimeoutDuration(timeout);
      if (kDebugMode) {
        debugPrint('[Analytics] Session timeout set: ${timeout.inSeconds}s');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting session timeout: $e');
    }
  }

  @override
  Future<String?> getAppInstanceId() async {
    try {
      return await _analytics.appInstanceId;
    } catch (e) {
      debugPrint('[Analytics] Error getting app instance ID: $e');
      return null;
    }
  }

  @override
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adUserDataConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
  }) async {
    try {
      await _analytics.setConsent(
        adStorageConsentGranted: adStorageConsentGranted,
        analyticsStorageConsentGranted: analyticsStorageConsentGranted,
        adUserDataConsentGranted: adUserDataConsentGranted,
        adPersonalizationSignalsConsentGranted:
            adPersonalizationSignalsConsentGranted,
      );
      if (kDebugMode) {
        debugPrint('[Analytics] Consent settings updated');
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting consent: $e');
    }
  }
}
