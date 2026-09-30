/// Utility generating native configuration snippets and YAML specifications
/// for Android (launch_background.xml, Android 12 Splash API) and iOS (LaunchScreen.storyboard).
class NativeSplashConfigHelper {
  NativeSplashConfigHelper._();

  /// Generates a complete `flutter_native_splash.yaml` string from parameters.
  static String generateYaml({
    required String colorHex,
    String? colorDarkHex,
    required String imagePath,
    String? imageDarkPath,
    String? brandingPath,
    String? brandingDarkPath,
    bool enableAndroid12 = true,
    bool enableIos = true,
    bool enableWeb = true,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('flutter_native_splash:');
    buffer.writeln('  color: "$colorHex"');
    if (colorDarkHex != null && colorDarkHex.isNotEmpty) {
      buffer.writeln('  color_dark: "$colorDarkHex"');
    }
    buffer.writeln('  image: $imagePath');
    if (imageDarkPath != null && imageDarkPath.isNotEmpty) {
      buffer.writeln('  image_dark: $imageDarkPath');
    }
    if (brandingPath != null && brandingPath.isNotEmpty) {
      buffer.writeln('  branding: $brandingPath');
    }
    if (brandingDarkPath != null && brandingDarkPath.isNotEmpty) {
      buffer.writeln('  branding_dark: $brandingDarkPath');
    }

    if (enableAndroid12) {
      buffer.writeln('  android_12:');
      buffer.writeln('    image: $imagePath');
      buffer.writeln('    icon_background_color: "$colorHex"');
      if (imageDarkPath != null && imageDarkPath.isNotEmpty) {
        buffer.writeln('    image_dark: $imageDarkPath');
      }
      if (colorDarkHex != null && colorDarkHex.isNotEmpty) {
        buffer.writeln('    icon_background_color_dark: "$colorDarkHex"');
      }
      if (brandingPath != null && brandingPath.isNotEmpty) {
        buffer.writeln('    branding: $brandingPath');
      }
      if (brandingDarkPath != null && brandingDarkPath.isNotEmpty) {
        buffer.writeln('    branding_dark: $brandingDarkPath');
      }
    }

    buffer.writeln('  android: true');
    buffer.writeln('  ios: $enableIos');
    buffer.writeln('  web: $enableWeb');

    return buffer.toString();
  }

  /// Returns the terminal command to apply the generated native splash screen.
  static String get generateCliCommand =>
      'dart run flutter_native_splash:create';

  /// Returns the terminal command to revert/remove native splash screen modifications.
  static String get removeCliCommand => 'dart run flutter_native_splash:remove';
}
