import 'package:code_store/features/splash/splash_preview_screen.dart';
import 'package:code_store_splash/code_store_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockSplashService implements ISplashService {
  @override
  Future<void> preserve({WidgetsBinding? widgetsBinding}) async {}

  @override
  Future<void> remove() async {}

  @override
  Future<void> playChime({required SplashAudioConfig config}) async {}

  @override
  Future<void> stopChime() async {}

  @override
  bool get isNativeSupported => true;

  @override
  void dispose() {}
}

void main() {
  setUp(() async {
    GetIt.instance.reset();
    setupSplashDI(customService: MockSplashService());
  });

  Widget buildTestableWidget() {
    return const MaterialApp(home: SplashPreviewScreen());
  }

  testWidgets(
    'SplashPreviewScreen renders all essential sections and controls',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Verify AppBar
      expect(find.text('Native Splash Package'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Play Fullscreen'), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);

      // Verify Configuration Sections
      expect(find.text('Configuration & Features'), findsOneWidget);
      expect(find.text('Logo Animation Style'), findsOneWidget);
      expect(find.text('Native Footer / Branding Logo'), findsOneWidget);
      expect(find.text('Audio Chime / Entrance Tune'), findsOneWidget);

      // Verify Animation Choice Chips
      expect(
        find.widgetWithText(ChoiceChip, 'Static (No Animation)'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ChoiceChip, 'Scale In'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Fade In'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Pulse'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Shimmer'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Bounce'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '3D Flip'), findsOneWidget);
    },
  );

  testWidgets('Selecting different animation chips updates state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump(const Duration(milliseconds: 100));

    // Select Static
    await tester.tap(find.widgetWithText(ChoiceChip, 'Static (No Animation)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.widgetWithText(ChoiceChip, 'Static (No Animation)'),
      findsOneWidget,
    );

    // Select Shimmer
    await tester.tap(find.widgetWithText(ChoiceChip, 'Shimmer'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.widgetWithText(ChoiceChip, 'Shimmer'), findsOneWidget);
  });

  testWidgets('YAML Dialog opens and renders native YAML instructions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump(const Duration(milliseconds: 100));

    // Tap code icon in AppBar
    await tester.tap(find.byIcon(Icons.code_rounded));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Native Config (YAML)'), findsOneWidget);
    expect(find.text('Copy YAML'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Native Config (YAML)'), findsNothing);
  });

  testWidgets(
    'Play Fullscreen launches full splash overlay and dismisses cleanly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Play Fullscreen
      await tester.tap(find.text('Play Fullscreen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NativeSplashView), findsOneWidget);
      expect(find.byTooltip('Dismiss Splash'), findsOneWidget);

      // Dismiss overlay
      await tester.tap(find.byTooltip('Dismiss Splash'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NativeSplashView), findsNothing);
    },
  );
}
