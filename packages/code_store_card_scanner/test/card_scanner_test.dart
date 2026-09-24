import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  group('CardValidator & Regex Brand Detection', () {
    test('detects Visa brand correctly', () {
      expect(CardValidator.detectType('4111222233334444'), CardType.visa);
      expect(CardValidator.detectType('4000 0000 0000 0000'), CardType.visa);
    });

    test('detects Mastercard brand correctly (5-series and 2-series)', () {
      expect(CardValidator.detectType('5105105105105100'), CardType.mastercard);
      expect(CardValidator.detectType('5500000000000004'), CardType.mastercard);
      expect(CardValidator.detectType('2221000000000000'), CardType.mastercard);
      expect(CardValidator.detectType('2720000000000000'), CardType.mastercard);
    });

    test('detects American Express brand correctly', () {
      expect(
        CardValidator.detectType('340000000000000'),
        CardType.americanExpress,
      );
      expect(
        CardValidator.detectType('378282246310005'),
        CardType.americanExpress,
      );
    });

    test('detects Discover brand correctly', () {
      expect(CardValidator.detectType('6011000000000000'), CardType.discover);
      expect(CardValidator.detectType('6500000000000000'), CardType.discover);
    });

    test('detects JCB brand correctly', () {
      expect(CardValidator.detectType('3528000000000000'), CardType.jcb);
      expect(CardValidator.detectType('213100000000000'), CardType.jcb);
    });

    test('detects Diners Club brand correctly', () {
      expect(CardValidator.detectType('30000000000000'), CardType.dinersClub);
      expect(CardValidator.detectType('36000000000000'), CardType.dinersClub);
    });

    test('detects UnionPay brand correctly', () {
      expect(CardValidator.detectType('6200000000000000'), CardType.unionPay);
      expect(CardValidator.detectType('8100000000000000'), CardType.unionPay);
    });

    test('detects Maestro brand correctly', () {
      expect(CardValidator.detectType('5018000000000000'), CardType.maestro);
      expect(CardValidator.detectType('6759000000000000'), CardType.maestro);
    });

    test('detects Elo brand correctly', () {
      expect(CardValidator.detectType('4011780000000000'), CardType.elo);
      expect(CardValidator.detectType('5066990000000000'), CardType.elo);
    });

    test('returns unknown for unrecognized prefix or empty string', () {
      expect(CardValidator.detectType(''), CardType.unknown);
      expect(CardValidator.detectType('9999000000000000'), CardType.unknown);
    });
  });

  group('Luhn Checksum Validation', () {
    test('validates valid credit card numbers', () {
      // Known valid Luhn numbers
      expect(CardValidator.validateLuhn('4532015112830366'), isTrue);
      expect(CardValidator.validateLuhn('49927398716'), isTrue);
      expect(CardValidator.validateLuhn('4532 0151 1283 0366'), isTrue);
    });

    test('rejects invalid numbers or numbers corrupted by 1 digit', () {
      expect(CardValidator.validateLuhn('4532015112830367'), isFalse);
      expect(CardValidator.validateLuhn('49927398717'), isFalse);
      expect(CardValidator.validateLuhn('12345'), isFalse); // too short
      expect(CardValidator.validateLuhn(''), isFalse);
    });
  });

  group('Expiry Date & CVV Validation', () {
    test('validates valid future expiry dates', () {
      final futureYear = DateTime.now().year + 2;
      expect(CardValidator.validateExpiry(12, futureYear), isTrue);
      expect(CardValidator.validateExpiry(6, futureYear % 100), isTrue);
    });

    test('rejects past or invalid expiry dates', () {
      expect(CardValidator.validateExpiry(1, 2020), isFalse);
      expect(CardValidator.validateExpiry(13, 2028), isFalse);
      expect(CardValidator.validateExpiry(0, 2028), isFalse);
      expect(CardValidator.validateExpiry(null, 2028), isFalse);
    });

    test('validates CVV lengths according to brand', () {
      expect(CardValidator.validateCvv('123', CardType.visa), isTrue);
      expect(CardValidator.validateCvv('1234', CardType.visa), isFalse);
      expect(
        CardValidator.validateCvv('1234', CardType.americanExpress),
        isTrue,
      );
      expect(
        CardValidator.validateCvv('123', CardType.americanExpress),
        isFalse,
      );
    });
  });

  group('Number and Expiry Formatting', () {
    test('formats 16-digit cards with 4-4-4-4 spacing', () {
      expect(
        CardValidator.formatNumber('4111222233334444'),
        '4111 2222 3333 4444',
      );
    });

    test('formats American Express cards with 4-6-5 spacing', () {
      expect(
        CardValidator.formatNumber('378282246310005'),
        '3782 822463 10005',
      );
    });

    test('formats expiry as MM/YY', () {
      expect(CardValidator.formatExpiry('1228'), '12/28');
      expect(CardValidator.formatExpiry('05'), '05');
      expect(CardValidator.formatExpiry(''), '');
    });
  });

  group('CardDetails Model Serialization & Immutability', () {
    test('serializes to and from map cleanly', () {
      const details = CardDetails(
        cardNumber: '4532758923481234',
        cardHolderName: 'JANE DOE',
        expiryMonth: 10,
        expiryYear: 27,
        cvv: '999',
        cardType: CardType.visa,
        isValidNumber: true,
      );

      final map = details.toMap();
      final reconstructed = CardDetails.fromMap(map);

      expect(reconstructed, equals(details));
      expect(reconstructed.formattedExpiry, '10/27');
      expect(reconstructed.maskedNumber, '**** **** **** 1234');
      expect(reconstructed.isExpired, isFalse);
    });

    test('copyWith updates fields as expected', () {
      const original = CardDetails(cardNumber: '4111');
      final updated = original.copyWith(
        cardHolderName: 'ALICE',
        cardType: CardType.visa,
      );

      expect(updated.cardNumber, '4111');
      expect(updated.cardHolderName, 'ALICE');
      expect(updated.cardType, CardType.visa);
    });
  });

  group('Dependency Injection', () {
    setUp(() {
      GetIt.instance.reset();
    });

    test('setupCardScannerDI registers ICardScannerService', () {
      setupCardScannerDI();

      expect(GetIt.instance.isRegistered<ICardScannerService>(), isTrue);
      expect(GetIt.instance<ICardScannerService>(), isA<CardScannerService>());
    });

    test('setupCardScannerDI accepts custom service', () {
      final custom = CardScannerService();
      setupCardScannerDI(customService: custom);

      expect(GetIt.instance<ICardScannerService>(), same(custom));
    });
  });

  group('EmbeddedCardCamera Configuration & Transitions', () {
    test('EmbeddedCardCamera defaults detectionDelay to 1100ms', () {
      final cameraWidget = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
      );

      expect(cameraWidget.detectionDelay, const Duration(milliseconds: 1100));
    });

    test('EmbeddedCardCamera supports custom detectionDelay', () {
      final cameraWidget = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
        detectionDelay: const Duration(milliseconds: 1500),
      );

      expect(cameraWidget.detectionDelay, const Duration(milliseconds: 1500));
    });

    test('EmbeddedCardCamera supports custom laserColor', () {
      final cameraWidget = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
        laserColor: Colors.deepPurpleAccent,
      );

      expect(cameraWidget.laserColor, Colors.deepPurpleAccent);
    });

    test('CardCameraScannerView supports custom laserColor and title', () {
      final scannerView = CardCameraScannerView(
        laserColor: Colors.orangeAccent,
        title: 'Custom Scan Title',
      );

      expect(scannerView.laserColor, Colors.orangeAccent);
      expect(scannerView.title, 'Custom Scan Title');
    });

    test(
      'EmbeddedCardCamera supports custom guidanceText and guidanceIcon',
      () {
        final cameraWidget = EmbeddedCardCamera(
          onCardDetected: (_) {},
          onCancel: () {},
          guidanceText: 'Scan Card Front',
          guidanceIcon: Icons.camera_alt_rounded,
          showGuidance: false,
        );

        expect(cameraWidget.guidanceText, 'Scan Card Front');
        expect(cameraWidget.guidanceIcon, Icons.camera_alt_rounded);
        expect(cameraWidget.showGuidance, isFalse);
      },
    );

    test('CardCameraScannerView supports custom guidance options', () {
      final scannerView = CardCameraScannerView(
        guidanceText: 'Position card clearly',
        guidanceIcon: Icons.center_focus_strong,
        showGuidance: true,
      );

      expect(scannerView.guidanceText, 'Position card clearly');
      expect(scannerView.guidanceIcon, Icons.center_focus_strong);
      expect(scannerView.showGuidance, isTrue);
    });

    test(
      'CardScannerHeroButton initializes with custom heroTag and properties',
      () {
        const customChild = Icon(Icons.photo_camera);
        final button = CardScannerHeroButton(
          heroTag: 'my_custom_tag',
          laserColor: Colors.teal,
          child: customChild,
        );

        expect(button.heroTag, 'my_custom_tag');
        expect(button.laserColor, Colors.teal);
        expect(button.child, customChild);
      },
    );

    test('CardCameraOverlayView accepts custom heroTag and guidance', () {
      final overlayView = CardCameraOverlayView(
        heroTag: 'test_hero_tag',
        laserColor: Colors.pink,
        guidanceText: 'Keep steady',
        bannerTitle: 'Center Card',
        onCardDetected: (_) {},
        onCancel: () {},
      );

      expect(overlayView.heroTag, 'test_hero_tag');
      expect(overlayView.laserColor, Colors.pink);
      expect(overlayView.guidanceText, 'Keep steady');
      expect(overlayView.bannerTitle, 'Center Card');
    });
  });

  group('CardScannerHeroButton & CardCameraOverlayView Customization', () {
    test('CardScannerHeroButton accepts custom child widget', () {
      const customWidget = Text('Tap to Scan');
      final button = CardScannerHeroButton(
        child: customWidget,
      );

      expect(button.child, customWidget);
    });

    test(
      'CardScannerHeroButton supports custom overlay colors and barrierColor',
      () {
        final button = CardScannerHeroButton(
          laserColor: Colors.cyanAccent,
          overlayColor: Colors.black87,
          barrierColor: Colors.black54,
        );

        expect(button.laserColor, Colors.cyanAccent);
        expect(button.overlayColor, Colors.black87);
        expect(button.barrierColor, Colors.black54);
      },
    );

    test('CardScannerHeroButton supports custom banner colors and styling', () {
      final button = CardScannerHeroButton(
        bannerTitle: 'Hold Steady',
        bannerIcon: Icons.credit_card,
        bannerBackgroundColor: Colors.indigo,
        bannerTextColor: Colors.yellow,
      );

      expect(button.bannerTitle, 'Hold Steady');
      expect(button.bannerIcon, Icons.credit_card);
      expect(button.bannerBackgroundColor, Colors.indigo);
      expect(button.bannerTextColor, Colors.yellow);
    });

    test(
        'CardScannerHeroButton supports showCloseButton boolean and close button styling',
        () {
      final buttonWithoutClose = CardScannerHeroButton(showCloseButton: false);
      expect(buttonWithoutClose.showCloseButton, isFalse);

      final buttonWithCustomClose = CardScannerHeroButton(
        showCloseButton: true,
        closeButtonText: 'Dismiss Scanner',
        closeButtonIcon: Icons.cancel_outlined,
        closeButtonColor: Colors.redAccent,
        closeButtonTextColor: Colors.white,
      );
      expect(buttonWithCustomClose.showCloseButton, isTrue);
      expect(buttonWithCustomClose.closeButtonText, 'Dismiss Scanner');
      expect(buttonWithCustomClose.closeButtonIcon, Icons.cancel_outlined);
      expect(buttonWithCustomClose.closeButtonColor, Colors.redAccent);
      expect(buttonWithCustomClose.closeButtonTextColor, Colors.white);
    });

    test(
        'CardCameraOverlayView supports custom laserColor, overlay, and banner colors',
        () {
      final overlay = CardCameraOverlayView(
        heroTag: 'custom_tag',
        laserColor: Colors.greenAccent,
        bannerTitle: 'Align Card',
        bannerIcon: Icons.camera,
        bannerBackgroundColor: Colors.black54,
        bannerTextColor: Colors.lightGreenAccent,
        onCardDetected: (_) {},
        onCancel: () {},
      );

      expect(overlay.laserColor, Colors.greenAccent);
      expect(overlay.bannerTitle, 'Align Card');
      expect(overlay.bannerIcon, Icons.camera);
      expect(overlay.bannerBackgroundColor, Colors.black54);
      expect(overlay.bannerTextColor, Colors.lightGreenAccent);
    });

    test(
        'CardCameraOverlayView supports showCloseButton boolean and close button styling',
        () {
      final overlayWithoutClose = CardCameraOverlayView(
        heroTag: 'tag1',
        laserColor: Colors.teal,
        showCloseButton: false,
        onCardDetected: (_) {},
        onCancel: () {},
      );
      expect(overlayWithoutClose.showCloseButton, isFalse);

      final overlayWithClose = CardCameraOverlayView(
        heroTag: 'tag2',
        laserColor: Colors.teal,
        showCloseButton: true,
        closeButtonText: 'Dismiss',
        closeButtonIcon: Icons.cancel,
        closeButtonColor: Colors.purple,
        closeButtonTextColor: Colors.amber,
        onCardDetected: (_) {},
        onCancel: () {},
      );
      expect(overlayWithClose.showCloseButton, isTrue);
      expect(overlayWithClose.closeButtonText, 'Dismiss');
      expect(overlayWithClose.closeButtonIcon, Icons.cancel);
      expect(overlayWithClose.closeButtonColor, Colors.purple);
      expect(overlayWithClose.closeButtonTextColor, Colors.amber);
    });

    testWidgets(
      'CardScannerHeroButton defaults to camera icon when child is null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CardScannerHeroButton(
                  key: ValueKey('test_hero_btn'),
                ),
              ),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.camera_alt_rounded);
        expect(iconFinder, findsOneWidget);
      },
    );

    testWidgets(
      'CardScannerHeroButton renders and wraps custom child widget',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CardScannerHeroButton(
                  key: ValueKey('custom_child_btn'),
                  child: Text('Custom Scan Action'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Custom Scan Action'), findsOneWidget);
        expect(find.byType(InkResponse), findsOneWidget);
      },
    );

    testWidgets(
      'CardCameraOverlayView hides close button when showCloseButton is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardCameraOverlayView(
              heroTag: 'no_close_test',
              laserColor: Colors.purple,
              showCloseButton: false,
              onCardDetected: (_) {},
              onCancel: () {},
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('close_camera_overlay_button')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'CardCameraOverlayView renders custom banner and close button when showCloseButton is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardCameraOverlayView(
              heroTag: 'custom_render_test',
              laserColor: Colors.purple,
              bannerTitle: 'Scan Custom Title',
              bannerIcon: Icons.star,
              bannerTextColor: Colors.yellow,
              showCloseButton: true,
              closeButtonText: 'Exit Scanner',
              closeButtonIcon: Icons.exit_to_app,
              onCardDetected: (_) {},
              onCancel: () {},
            ),
          ),
        );

        expect(find.text('Scan Custom Title'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('Exit Scanner'), findsOneWidget);
        expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
        expect(
          find.byKey(const ValueKey('close_camera_overlay_button')),
          findsOneWidget,
        );
      },
    );

    test(
        'EmbeddedCardCamera accepts onNoCamera callback and initializes correctly',
        () {
      bool noCameraCalled = false;
      final camera = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
        onNoCamera: () {
          noCameraCalled = true;
        },
      );

      expect(camera.onNoCamera, isNotNull);
      camera.onNoCamera?.call();
      expect(noCameraCalled, isTrue);
    });
  });
}
