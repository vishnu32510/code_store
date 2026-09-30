import 'dart:io';

/// Command-line executable for `code_store_splash` package.
///
/// Automatically configures splash screens for ALL platforms in one shot:
/// 1. Android: Legacy XML drawables & Android 12+ Splash API
/// 2. iOS: LaunchScreen.storyboard & Info.plist
/// 3. Web: Instant dark HTML/CSS pre-loader in index.html & manifest.json
///
/// Usage:
///   dart run code_store_splash:create
///   dart run code_store_splash:create --color "#121212" --logo "assets/icon/app_logo.png" --branding "assets/icon/branding.png"
void main(List<String> args) {
  stdout.writeln(
    '🎨 [code_store_splash] Setting up Native & Web Splash Screens...',
  );

  String colorHex = '#121212';
  String? colorDarkHex = '#121212';
  String imagePath = 'assets/icon/app_logo.png';
  String? brandingPath = 'assets/icon/branding.png';
  String footerText = 'Powered by Nungu';
  bool enableWeb = true;

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
  --footer-text <text> Footer branding tagline (default: Powered by Nungu)
  --no-branding        Disable footer branding logo
  --no-web             Disable Web HTML/CSS splash automation
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
    } else if (args[i] == '--footer-text' && i + 1 < args.length) {
      footerText = args[++i];
    } else if (args[i] == '--no-branding') {
      brandingPath = null;
    } else if (args[i] == '--no-web') {
      enableWeb = false;
    }
  }

  // 1. Generate YAML content for Android & iOS native builder
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
  stdout.writeln('✅ Configured ${yamlFile.path}:');
  stdout.writeln('   - Color: $colorHex (Dark: $colorDarkHex)');
  stdout.writeln('   - Logo: $imagePath');
  stdout.writeln('   - Branding: ${brandingPath ?? "None"}');
  stdout.writeln('');

  // 3. Execute flutter_native_splash:create for Android & iOS
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

  if (result.exitCode != 0) {
    stderr.writeln('⚠️ Native compilation error: ${result.stderr}');
    exit(result.exitCode);
  }

  // 4. Automatically configure Web splash screen (if web/ exists and enabled)
  if (enableWeb) {
    _configureWebSplash(
      colorHex: colorHex,
      imagePath: imagePath,
      brandingPath: brandingPath,
      footerText: footerText,
    );
  }

  stdout.writeln(
    '✨ [code_store_splash] All platforms (Android, iOS, Web) setup complete!',
  );
}

/// Automatically configures `web/index.html`, `web/manifest.json`, and web splash assets
/// to prevent any white screen flashes during browser load.
void _configureWebSplash({
  required String colorHex,
  required String imagePath,
  String? brandingPath,
  String footerText = 'Powered by Nungu',
}) {
  final webDir = Directory('web');
  if (!webDir.existsSync()) return;

  stdout.writeln('🌐 Configuring Web splash screen...');

  // Copy splash logo to web/splash_logo.png
  final logoSrc = File(imagePath);
  if (logoSrc.existsSync()) {
    logoSrc.copySync('web/splash_logo.png');
  }

  // Copy splash branding to web/splash_branding.png
  if (brandingPath != null && File(brandingPath).existsSync()) {
    File(brandingPath).copySync('web/splash_branding.png');
  }

  // Update web/manifest.json background_color and theme_color
  final manifestFile = File('web/manifest.json');
  if (manifestFile.existsSync()) {
    var manifest = manifestFile.readAsStringSync();
    manifest = manifest.replaceAll(
      RegExp(r'"background_color":\s*"[^"]*"'),
      '"background_color": "$colorHex"',
    );
    manifest = manifest.replaceAll(
      RegExp(r'"theme_color":\s*"[^"]*"'),
      '"theme_color": "$colorHex"',
    );
    manifestFile.writeAsStringSync(manifest);
  }

  // Update or inject splash into web/index.html
  final indexFile = File('web/index.html');
  if (indexFile.existsSync()) {
    final brandingHtml = (brandingPath != null && brandingPath.isNotEmpty)
        ? '    <div id="splash-footer">\n'
              '      <img src="splash_branding.png" alt="Branding">\n'
              '      <span>$footerText</span>\n'
              '    </div>'
        : '';

    final isDarkBg =
        !colorHex.toLowerCase().startsWith('#f') &&
        !colorHex.toLowerCase().startsWith('#e') &&
        colorHex.toLowerCase() != '#ffffff';
    final textColorCss = isDarkBg
        ? 'rgba(255, 255, 255, 0.75)'
        : 'rgba(0, 0, 0, 0.6)';

    final splashStyle =
        '''
  <style id="splash-styles">
    html, body {
      background-color: $colorHex !important;
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      user-select: none;
      -webkit-user-select: none;
    }
    #splash-loading {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background-color: $colorHex;
      z-index: 99999;
      pointer-events: none;
      transition: opacity 0.4s ease-out;
    }
    #splash-logo {
      width: 130px;
      height: 130px;
      object-fit: contain;
      animation: pulse-logo 1.6s ease-in-out infinite alternate;
    }
    #splash-footer {
      position: absolute;
      bottom: 24px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
    }
    #splash-footer img {
      height: 44px;
      object-fit: contain;
    }
    #splash-footer span {
      color: $textColorCss;
      font-size: 13px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      letter-spacing: 0.3px;
    }
    @keyframes pulse-logo {
      0% { transform: scale(0.96); opacity: 0.9; }
      100% { transform: scale(1.04); opacity: 1; }
    }
  </style>''';

    final splashBody =
        '''
<body style="background-color: $colorHex;">
  <div id="splash-loading">
    <img id="splash-logo" src="splash_logo.png" alt="Logo">
$brandingHtml
  </div>
  <script>
    // Remove pre-Flutter HTML splash as soon as Flutter's first frame renders
    window.addEventListener('flutter-first-frame', function() {
      var splash = document.getElementById('splash-loading');
      if (splash) {
        splash.style.display = 'none';
        splash.remove();
      }
    });
  </script>''';

    var html = indexFile.readAsStringSync();

    // Replace existing style or inject before </head>
    if (html.contains('<style id="splash-styles">')) {
      html = html.replaceAll(
        RegExp(r'<style id="splash-styles">[\s\S]*?</style>'),
        splashStyle.trim(),
      );
    } else if (html.contains('</head>')) {
      html = html.replaceFirst('</head>', '$splashStyle\n</head>');
    }

    // Replace existing body or inject after <body
    if (html.contains('<div id="splash-loading">')) {
      html = html.replaceAll(
        RegExp(r'<body[^>]*>[\s\S]*?<script src="flutter_bootstrap\.js"'),
        '$splashBody\n  <script src="flutter_bootstrap.js"',
      );
    } else if (html.contains('<body')) {
      html = html.replaceFirst(RegExp(r'<body[^>]*>'), splashBody);
    }

    indexFile.writeAsStringSync(html);
  }

  stdout.writeln(
    '✨ [Web] Instant HTML/CSS splash configured (zero white flash)!',
  );
}
