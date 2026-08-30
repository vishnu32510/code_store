/// Standard analytical event name constants for common user actions.
abstract final class AppAnalyticsEvents {
  // Navigation / Screen
  static const String screenView = 'screen_view';

  // Authentication
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';

  // Interaction
  static const String buttonClick = 'button_click';
  static const String linkClick = 'link_click';
  static const String featureUsed = 'feature_used';
  static const String search = 'search';
  static const String share = 'share';
  static const String selectContent = 'select_content';

  // Theme / Preferences
  static const String themeChanged = 'theme_changed';

  // Errors
  static const String appError = 'app_error';
}

/// Standard user property keys for user segmentation and filtering.
abstract final class AppAnalyticsUserProperties {
  static const String themeMode = 'theme_mode';
  static const String userType = 'user_type';
  static const String loginMethod = 'login_method';
  static const String appVersion = 'app_version';
}

/// Standard parameter keys for analytics events.
abstract final class AppAnalyticsParams {
  static const String buttonName = 'button_name';
  static const String featureName = 'feature_name';
  static const String errorMessage = 'error_message';
  static const String source = 'source';
  static const String value = 'value';
  static const String screenName = 'screen_name';
}
