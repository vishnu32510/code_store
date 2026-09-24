import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:code_store/features/card_scanner/card_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCardScannerService implements ICardScannerService {
  CardScanResult scanResult = CardScanResult.success(
    CardDetails(
      cardNumber: '4532015112830366',
      expiryMonth: 12,
      expiryYear: 28,
      cardHolderName: 'SCANNED USER',
      cvv: '999',
      cardType: CardType.visa,
    ),
  );

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<CardScanResult> scanCard() async {
    return scanResult;
  }

  @override
  CardDetails parseOcrLines(List<String> lines) =>
      CardOcrParser.parseRecognizedLines(lines);

  @override
  CardType detectCardType(String cardNumber) =>
      CardValidator.detectType(cardNumber);

  @override
  bool validateCardNumber(String cardNumber) =>
      CardValidator.validateLuhn(cardNumber);

  @override
  bool validateExpiryDate(int? month, int? year) =>
      CardValidator.validateExpiry(month, year);

  @override
  bool validateCvv(String cvv, CardType type) =>
      CardValidator.validateCvv(cvv, type);

  @override
  String formatCardNumber(String cardNumber) =>
      CardValidator.formatNumber(cardNumber);
}

void main() {
  setUp(() async {
    await getIt.reset();
    final mockService = MockCardScannerService();
    getIt.registerSingleton<ICardScannerService>(mockService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestableWidget() {
    return const MaterialApp(home: CardScannerScreen());
  }

  void setTestSurfaceSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('CardScannerScreen renders all essential UI sections', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Card Scanner & Details'), findsOneWidget);

    // Verify Action buttons
    expect(find.text('Scan Debit / Credit Card'), findsOneWidget);
    expect(find.text('Save Card Details'), findsOneWidget);

    // Verify Form Fields
    expect(find.widgetWithText(TextFormField, 'Card Number'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Cardholder Name'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Expires'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'CVV'), findsOneWidget);

    // Verify Presets
    expect(find.text('Quick Test Presets (Simulator)'), findsOneWidget);
    expect(find.text('Visa'), findsOneWidget);
    expect(find.text('Mastercard'), findsOneWidget);
    expect(find.text('Amex'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Real-time regex detects card brands and updates postfix icon', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final cardNumberFinder = find.widgetWithText(TextFormField, 'Card Number');

    // 1. Enter Visa prefix '4'
    await tester.enterText(cardNumberFinder, '4');
    await tester.pumpAndSettle();

    expect(find.text('Detected: Visa'), findsOneWidget);
    expect(find.text('VISA'), findsWidgets);

    // 2. Enter Mastercard prefix '5555'
    await tester.enterText(cardNumberFinder, '5555');
    await tester.pumpAndSettle();

    expect(find.text('Detected: Mastercard'), findsOneWidget);

    // 3. Enter Amex prefix '3782'
    await tester.enterText(cardNumberFinder, '3782');
    await tester.pumpAndSettle();

    expect(find.text('Detected: American Express'), findsOneWidget);
    expect(find.text('AMEX'), findsWidgets);

    // 4. Enter Discover prefix '6011'
    await tester.enterText(cardNumberFinder, '6011');
    await tester.pumpAndSettle();

    expect(find.text('Detected: Discover'), findsOneWidget);
  });

  testWidgets('Preset chips populate details and trigger Luhn valid state', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap Visa Preset
    final visaChip = find.widgetWithText(ActionChip, 'Visa');
    await tester.tap(visaChip);
    await tester.pumpAndSettle();

    expect(find.text('Valid Checksum'), findsOneWidget);
    expect(find.text('ALICE SMITH'), findsWidgets);
    expect(find.text('12/28'), findsWidgets);

    // Tap Amex Preset
    final amexChip = find.widgetWithText(ActionChip, 'Amex');
    await tester.tap(amexChip);
    await tester.pumpAndSettle();

    expect(find.text('CAROL WILLIAMS'), findsWidgets);
    expect(find.text('11/29'), findsWidgets);
    expect(find.text('AMEX'), findsWidgets);
  });

  testWidgets('Card flips on tap and shows back with magnetic stripe', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify initially front is showing
    expect(find.text('Tap card to view back & CVV'), findsOneWidget);
    expect(find.text('CARDHOLDER'), findsOneWidget);

    // Tap card to flip
    await tester.tap(find.text('CARDHOLDER'));
    await tester.pumpAndSettle();

    // Verify back is showing
    expect(find.text('Tap card to view front'), findsOneWidget);
    expect(
      find.text('Authorized Signature • Not Transferable'),
      findsOneWidget,
    );

    // Tap again to flip back to front
    await tester.tap(find.text('Authorized Signature • Not Transferable'));
    await tester.pumpAndSettle();

    expect(find.text('Tap card to view back & CVV'), findsOneWidget);
  });

  testWidgets('Scan card button triggers service and populates fields', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final scanButton = find.text('Scan Debit / Credit Card');
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    // Verify fields populated from mock scanner
    expect(find.text('SCANNED USER'), findsWidgets);
    expect(find.text('12/28'), findsWidgets);
    expect(
      find.text('Card details extracted successfully (Visa)'),
      findsOneWidget,
    );
    expect(find.text('Valid Checksum'), findsOneWidget);
  });

  testWidgets('Save card details validates and displays confirmation modal', (
    WidgetTester tester,
  ) async {
    setTestSurfaceSize(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap Visa Preset to make everything valid
    await tester.tap(find.widgetWithText(ActionChip, 'Visa'));
    await tester.pumpAndSettle();

    // Tap Save Card Details
    await tester.tap(find.text('Save Card Details'));
    await tester.pumpAndSettle();

    // Confirmation modal should appear
    expect(find.text('Card Added Successfully'), findsOneWidget);
    expect(find.text('Verified via Luhn Mod-10 Checksum'), findsOneWidget);
    expect(find.text('ALICE SMITH'), findsWidgets);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done to close modal
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Card Added Successfully'), findsNothing);
  });

  testWidgets(
    'Triggering real scanner activates in-place embedded camera flow',
    (WidgetTester tester) async {
      setTestSurfaceSize(tester);
      await getIt.reset();
      getIt.registerSingleton<ICardScannerService>(CardScannerService());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Scan Debit / Credit Card'), findsOneWidget);
      expect(find.text('Tap card to view back & CVV'), findsOneWidget);

      // Tap Scan button to open in-place camera
      await tester.tap(find.text('Scan Debit / Credit Card'));
      await tester.pump();

      // Verify active camera viewfinder is mounted directly in place of the 3D card
      expect(
        find.byKey(const ValueKey('embedded_camera_viewfinder')),
        findsOneWidget,
      );
      expect(find.text('Stop Camera Scanner'), findsOneWidget);

      // Tap Stop Camera Scanner to close camera and return to 3D card
      await tester.tap(find.text('Stop Camera Scanner'));
      await tester.pump();

      // Verify back to 3D card
      expect(
        find.byKey(const ValueKey('embedded_camera_viewfinder')),
        findsNothing,
      );
      expect(find.text('Scan Debit / Credit Card'), findsOneWidget);
    },
  );
}
