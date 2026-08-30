library;

// Re-export firebase_analytics types commonly needed by consuming apps
export 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalytics, FirebaseAnalyticsObserver;

// Constants & Events
export 'src/constants/analytics_events.dart';

// DI
export 'src/di/analytics_injection.dart';

// Services
export 'src/services/firebase_analytics_service.dart';
export 'src/services/i_analytics_service.dart';

// Utilities & Extensions
export 'src/utils/analytics_extensions.dart';
