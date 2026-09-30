import 'dart:io';

/// Command-line executable for `code_store_splash` package.
///
/// Generates `flutter_native_splash.yaml` in the consumer project's root
/// and compiles native Android XML drawables and iOS LaunchScreen storyboards.
///
/// Usage:
///   dart run code_store_splash:create
///   dart run code_store_splash:create --color "#121212" --logo "assets/icon/app_logo.png" --branding "assets/icon/branding.png"
void main(List<String> args) {
  stdout.writeln('🎨 [code_store_splash] Setting up Native Splash Screen...');

  String colorHex = '#121212';
  String? colorDarkHex = '#121212';
  String imagePath = 'assets/icon/app_logo.png';
  String? brandingPath = 'assets/icon/branding.png';

  // Parse optional command-line flags
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--help' || args[i] == '-h') {
      stdout.writeln('''
Usage: dart run code_store_splash:create [options]

Options:
  --color <hex>        Background hex color (default: #121212)
  --color-dark <hex>   Dark mode background hex color (default: #121212)
  --logo <path>        Path to logo image asset (default: assets/icon/app_logo.png)
  --branding <path>    Path to footer branding asset (default: assets/icon/branding.png)
  --no-branding        Disable footer branding logo
  -h, --help           Show this help message
''');
      exit(0);
    } else if (args[i] == '--color' && i + 1 < args.length) {
      colorHex = args[++i];
    } else if (args[i] == '--color-dark' && i + 1 < args.length) {
      colorDarkHex = args[++i];
    } else if (args[i] == '--logo' && i + 1 < args.length) {
      imagePath = args[++i];
    } else if (args[i] == '--branding' && i + 1 < args.length) {
      brandingPath = args[++i];
    } else if (args[i] == '--no-branding') {
      brandingPath = null;
    }
  }

  // 1. Generate YAML content
  final buffer = StringBuffer();
  buffer.writeln('flutter_native_splash:');
  buffer.writeln('  color: "$colorHex"');
  if (colorDarkHex != null && colorDarkHex.isNotEmpty) {
    buffer.writeln('  color_dark: "$colorDarkHex"');
  }
  buffer.writeln('  image: "$imagePath"');
  buffer.writeln('  image_dark: "$imagePath"');

  if (brandingPath != null && brandingPath.isNotEmpty) {
    buffer.writeln('  branding: "$brandingPath"');
    buffer.writeln('  branding_dark: "$brandingPath"');
  }

  buffer.writeln('  android_12:');
  buffer.writeln('    image: "$imagePath"');
  buffer.writeln('    image_dark: "$imagePath"');
  buffer.writeln('    color: "$colorHex"');
  buffer.writeln('    icon_background_color: "$colorHex"');
  if (colorDarkHex != null && colorDarkHex.isNotEmpty) {
    buffer.writeln('    color_dark: "$colorDarkHex"');
    buffer.writeln('    icon_background_color_dark: "$colorDarkHex"');
  }
  if (brandingPath != null && brandingPath.isNotEmpty) {
    buffer.writeln('    branding: "$brandingPath"');
    buffer.writeln('    branding_dark: "$brandingPath"');
  }

  buffer.writeln('  android: true');
  buffer.writeln('  ios: true');
  buffer.writeln('  web: false');

  // 2. Write to flutter_native_splash.yaml in the project root
  final yamlFile = File('flutter_native_splash.yaml');
  yamlFile.writeAsStringSync(buffer.toString());
  stdout.writeln('✅ Successfully configured ${yamlFile.path}:');
  stdout.writeln('   - Color: $colorHex (Dark: $colorDarkHex)');
  stdout.writeln('   - Logo: $imagePath');
  stdout.writeln('   - Branding: ${brandingPath ?? "None"}');
  stdout.writeln('');

  // 3. Execute flutter_native_splash:create
  stdout.writeln(
    '🚀 Compiling native Android XML drawables and iOS LaunchScreen...',
  );
  final result = Process.runSync('dart', [
    'run',
    'flutter_native_splash:create',
  ], runInShell: true);

  if (result.stdout != null && result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }

  if (result.exitCode == 0) {
    stdout.writeln(
      '✨ [code_store_splash] Native splash screen setup complete!',
    );
  } else {
    stderr.writeln('⚠️ Native compilation error: ${result.stderr}');
    exit(result.exitCode);
  }
}
