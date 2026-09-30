import 'package:code_store_splash/code_store_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Mock implementation of [ISplashAudioPlayer] for isolated testing.
class MockSplashAudioPlayer implements ISplashAudioPlayer {
  String? lastPlayedAsset;
  double? lastVolume;
  bool? lastLoop;
  bool stopCalled = false;
  bool disposeCalled = false;

  @override
  Future<void> playAsset(
    String assetPath, {
    double volume = 1.0,
    bool loop = false,
  }) async {
    lastPlayedAsset = assetPath;
    lastVolume = volume;
    lastLoop = loop;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  @override
  void dispose() {
    disposeCalled = true;
  }
}

/// Mock implementation of [ISplashService] for widget and DI testing.
class MockSplashService implements ISplashService {
  bool preserveCalled = false;
  bool removeCalled = false;
  SplashAudioConfig? lastChimeConfig;
  bool stopChimeCalled = false;
  bool disposeCalled = false;

  @override
  Future<void> preserve({WidgetsBinding? widgetsBinding}) async {
    preserveCalled = true;
  }

  @override
  Future<void> remove() async {
    removeCalled = true;
  }

  @override
  Future<void> playChime({required SplashAudioConfig config}) async {
    lastChimeConfig = config;
  }

  @override
  Future<void> stopChime() async {
    stopChimeCalled = true;
  }

  @override
  bool get isNativeSupported => true;

  @override
  void dispose() {
    disposeCalled = true;
  }
}

void main() {
  group('SplashAnimationType Tests', () {
    test('SplashAnimationType has all expected values and correct isAnimated state', () {
      expect(SplashAnimationType.none.isAnimated, isFalse);
      expect(SplashAnimationType.scale.isAnimated, isTrue);
      expect(SplashAnimationType.fade.isAnimated, isTrue);
      expect(SplashAnimationType.pulse.isAnimated, isTrue);
      expect(SplashAnimationType.shimmer.isAnimated, isTrue);
      expect(SplashAnimationType.bounce.isAnimated, isTrue);
      expect(SplashAnimationType.flip.isAnimated, isTrue);
      expect(SplashAnimationType.custom.isAnimated, isTrue);
      expect(SplashAnimationType.values.length, 8);
    });
  });

  group('SplashAudioConfig Model Tests', () {
    test('constructs and serializes cleanly to and from Map', () {
      const config = SplashAudioConfig(
        assetPath: 'assets/audio/splash.wav',
        volume: 0.8,
        delay: Duration(milliseconds: 250),
        loop: false,
        enabled: true,
      );

      final map = config.toMap();
      final restored = SplashAudioConfig.fromMap(map);

      expect(restored.assetPath, 'assets/audio/splash.wav');
      expect(restored.volume, 0.8);
      expect(restored.delay, const Duration(milliseconds: 250));
      expect(restored.loop, isFalse);
      expect(restored.enabled, isTrue);
      expect(restored, equals(config));
    });

    test('muted factory returns disabled config', () {
      final muted = SplashAudioConfig.muted(assetPath: 'audio.wav');
      expect(muted.enabled, isFalse);
      expect(muted.assetPath, 'audio.wav');
    });

    test('copyWith updates properties correctly', () {
      const original = SplashAudioConfig(assetPath: 'a.wav');
      final updated = original.copyWith(volume: 0.5, enabled: false);

      expect(updated.assetPath, 'a.wav');
      expect(updated.volume, 0.5);
      expect(updated.enabled, isFalse);
    });
  });

  group('SplashConfig Model Tests', () {
    test('hasFooter reflects presence of footer elements', () {
      const noFooter = SplashConfig(logoAsset: 'logo.png');
      expect(noFooter.hasFooter, isFalse);

      const withAsset = SplashConfig(
        logoAsset: 'logo.png',
        footerLogoAsset: 'branding.png',
      );
      expect(withAsset.hasFooter, isTrue);

      const withText = SplashConfig(
        logoAsset: 'logo.png',
        footerText: 'Powered by CodeStore',
      );
      expect(withText.hasFooter, isTrue);

      const withWidget = SplashConfig(
        logoAsset: 'logo.png',
        footerLogoWidget: Text('Custom Footer'),
      );
      expect(withWidget.hasFooter, isTrue);
    });

    test('serializes to and from Map correctly', () {
      const config = SplashConfig(
        logoAsset: 'assets/icon/logo.png',
        logoSize: 140.0,
        animationType: SplashAnimationType.shimmer,
        animationDuration: Duration(milliseconds: 1500),
        stayDuration: Duration(milliseconds: 2000),
        backgroundColor: Colors.blue,
        footerText: 'Footer Brand',
        audioConfig: SplashAudioConfig(assetPath: 'chime.mp3'),
      );

      final map = config.toMap();
      final restored = SplashConfig.fromMap(map);

      expect(restored.logoAsset, 'assets/icon/logo.png');
      expect(restored.logoSize, 140.0);
      expect(restored.animationType, SplashAnimationType.shimmer);
      expect(restored.stayDuration, const Duration(milliseconds: 2000));
      expect(restored.footerText, 'Footer Brand');
      expect(restored.audioConfig?.assetPath, 'chime.mp3');
    });
  });

  group('SplashResult Model Tests', () {
    test('success and failure factory constructors behave as expected', () {
      final success = SplashResult.success(const Duration(milliseconds: 1800));
      expect(success.isSuccess, isTrue);
      expect(success.duration.inMilliseconds, 1800);
      expect(success.error, isNull);

      final failure = SplashResult.failure(
        'Network error',
        const Duration(milliseconds: 1200),
      );
      expect(failure.isSuccess, isFalse);
      expect(failure.error, 'Network error');

      final map = failure.toMap();
      final restored = SplashResult.fromMap(map);
      expect(restored.isSuccess, isFalse);
      expect(restored.error, 'Network error');
    });
  });

  group('NativeSplashConfigHelper Tests', () {
    test(
      'generateYaml creates valid configuration with branding and colors',
      () {
        final yaml = NativeSplashConfigHelper.generateYaml(
          colorHex: '#ffffff',
          colorDarkHex: '#121212',
          imagePath: 'assets/icon/app_icon.png',
          imageDarkPath: 'assets/icon/app_icon_dark.png',
          brandingPath: 'assets/icon/branding.png',
          brandingDarkPath: 'assets/icon/branding_dark.png',
          enableAndroid12: true,
        );

        expect(yaml, contains('flutter_native_splash:'));
        expect(yaml, contains('color: "#ffffff"'));
        expect(yaml, contains('color_dark: "#121212"'));
        expect(yaml, contains('image: "assets/icon/app_icon.png"'));
        expect(yaml, contains('branding: "assets/icon/branding.png"'));
        expect(yaml, contains('android_12:'));
        expect(yaml, contains('branding: "assets/icon/branding.png"'));
      },
    );

    test('fromConfig generates valid YAML directly from SplashConfig', () {
      const config = SplashConfig(
        logoAsset: 'assets/icon/app_logo.png',
        backgroundColor: Color(0xFFFFFFFF),
        darkBackgroundColor: Color(0xFF121212),
        footerLogoAsset: 'assets/icon/branding.png',
      );

      final yaml = NativeSplashConfigHelper.fromConfig(config);
      expect(yaml, contains('color: "#ffffff"'));
      expect(yaml, contains('color_dark: "#121212"'));
      expect(yaml, contains('image: "assets/icon/app_logo.png"'));
      expect(yaml, contains('branding: "assets/icon/branding.png"'));
    });

    test('CLI commands return expected string syntax', () {
      expect(
        NativeSplashConfigHelper.generateCliCommand,
        'dart run flutter_native_splash:create',
      );
      expect(
        NativeSplashConfigHelper.removeCliCommand,
        'dart run flutter_native_splash:remove',
      );
    });
  });

  group('SplashService & Audio Tests', () {
    test(
      'SplashService coordinates chime playback through ISplashAudioPlayer',
      () async {
        final mockPlayer = MockSplashAudioPlayer();
        final service = SplashService(audioPlayer: mockPlayer);

        await service.playChime(
          config: const SplashAudioConfig(
            assetPath: 'assets/audio/chime.wav',
            volume: 0.7,
          ),
        );

        expect(mockPlayer.lastPlayedAsset, 'assets/audio/chime.wav');
        expect(mockPlayer.lastVolume, 0.7);

        await service.stopChime();
        expect(mockPlayer.stopCalled, isTrue);

        service.dispose();
        expect(mockPlayer.disposeCalled, isTrue);
      },
    );

    test('SplashService ignores disabled audio configuration', () async {
      final mockPlayer = MockSplashAudioPlayer();
      final service = SplashService(audioPlayer: mockPlayer);

      await service.playChime(
        config: SplashAudioConfig.muted(assetPath: 'assets/audio/chime.wav'),
      );

      expect(mockPlayer.lastPlayedAsset, isNull);
    });
  });

  group('Dependency Injection Tests', () {
    setUp(() {
      GetIt.instance.reset();
    });

    test('setupSplashDI registers ISplashService with custom service', () {
      final mock = MockSplashService();
      setupSplashDI(customService: mock);

      expect(GetIt.instance.isRegistered<ISplashService>(), isTrue);
      expect(GetIt.instance<ISplashService>(), same(mock));
    });

    test('setupSplashDI registers default SplashService if none provided', () {
      setupSplashDI(audioPlayer: MockSplashAudioPlayer());

      expect(GetIt.instance.isRegistered<ISplashService>(), isTrue);
      expect(GetIt.instance<ISplashService>(), isA<SplashService>());
    });

    test('setupSplashDI is idempotent', () {
      final mock = MockSplashService();
      setupSplashDI(customService: mock);
      setupSplashDI(customService: mock);

      expect(GetIt.instance<ISplashService>(), same(mock));
    });
  });

  group('Widget Tests', () {
    testWidgets('AnimatedSplashLogo renders static logo without animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedSplashLogo(
                logoAsset: '',
                logoWidget: Text('STATIC_LOGO'),
                animationType: SplashAnimationType.none,
              ),
            ),
          ),
        ),
      );

      expect(find.text('STATIC_LOGO'), findsOneWidget);
    });

    testWidgets('AnimatedSplashLogo renders with Scale animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedSplashLogo(
                logoAsset: '',
                logoWidget: Text('SCALE_LOGO'),
                animationType: SplashAnimationType.scale,
                duration: Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      expect(find.text('SCALE_LOGO'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('SCALE_LOGO'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'AnimatedSplashLogo renders fallback icon when asset path empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AnimatedSplashLogo(
                  logoAsset: '',
                  animationType: SplashAnimationType.none,
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
      },
    );

    testWidgets('SplashFooterLogo renders branding text and custom widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashFooterLogo(
              footerLogoWidget: Text('BRAND_ICON'),
              footerText: 'Powered by Acme Corp',
            ),
          ),
        ),
      );

      expect(find.text('BRAND_ICON'), findsOneWidget);
      expect(find.text('Powered by Acme Corp'), findsOneWidget);
    });

    testWidgets(
      'NativeSplashView coordinates lifecycle and invokes callbacks',
      (WidgetTester tester) async {
        final mockService = MockSplashService();
        var finishedCalled = false;
        SplashResult? recordedResult;

        final config = SplashConfig(
          logoAsset: '',
          logoWidget: const Text('MAIN_LOGO'),
          footerText: 'FOOTER_BRAND',
          animationType: SplashAnimationType.none,
          stayDuration: const Duration(milliseconds: 100),
          audioConfig: const SplashAudioConfig(
            assetPath: 'assets/audio/chime.wav',
          ),
          onFinished: () {
            finishedCalled = true;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: NativeSplashView(
              config: config,
              service: mockService,
              onResult: (result) {
                recordedResult = result;
              },
            ),
          ),
        );

        // Verify immediate render of main logo and footer
        expect(find.text('MAIN_LOGO'), findsOneWidget);
        expect(find.text('FOOTER_BRAND'), findsOneWidget);

        // Verify remove was called via post frame callback
        await tester.pump();
        expect(mockService.removeCalled, isTrue);
        expect(
          mockService.lastChimeConfig?.assetPath,
          'assets/audio/chime.wav',
        );

        // Fast-forward stay duration
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(finishedCalled, isTrue);
        expect(recordedResult, isNotNull);
        expect(recordedResult!.isSuccess, isTrue);
      },
    );

    testWidgets('NativeSplashView works without GetIt registration', (
      tester,
    ) async {
      final config = SplashConfig(
        logoAsset: '',
        logoWidget: const Text('STANDALONE_LOGO'),
        animationType: SplashAnimationType.none,
        stayDuration: const Duration(milliseconds: 50),
        removeNativeSplashOnMount:
            false, // avoid static platform calls in headless test
      );

      await tester.pumpWidget(
        MaterialApp(home: NativeSplashView(config: config)),
      );

      expect(find.text('STANDALONE_LOGO'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });
  });
}
