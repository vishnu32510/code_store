import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime app configuration loaded from `.env` (see `.env.example`).
abstract class AppConstants {
  static String get appDisplayName =>
      dotenv.get('APP_DISPLAY_NAME', fallback: 'My App');

  /// [MaterialApp] title.
  static String get appTitle => appDisplayName;

  static String get baseUrl =>
      dotenv.get('BASE_URL', fallback: 'https://api.example.com/');

  static String get privacyPolicyUrl =>
      dotenv.get('PRIVACY_POLICY_URL', fallback: '');

  static String get termsUrl => dotenv.get('TERMS_URL', fallback: '');

  static String get supportUrl => dotenv.get('SUPPORT_URL', fallback: '');

  /// App Group identifier for iOS WidgetKit and shared storage.
  static String get appGroupId =>
      dotenv.get('APP_GROUP_ID', fallback: 'group.com.nungu.codestore');

  /// Android AppWidget provider class name.
  static String get homeWidgetAndroidName =>
      'AppStatusWidgetHomeWidgetReceiver';

  /// iOS Widget Extension bundle / kind name.
  static String get homeWidgetIOSName => 'AppStatusWidgetHomeWidget';

  /// Filename prefix for gallery downloads (derived from display name).
  static String get downloadFilePrefix {
    final slug = appDisplayName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
    return slug.isEmpty ? 'app' : slug;
  }
}
