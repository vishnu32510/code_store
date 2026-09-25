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

    test('validates string expiration dates via validateExpiryDate', () {
      final futureYear = DateTime.now().year + 2;
      final yy = (futureYear % 100).toString().padLeft(2, '0');
      expect(CardValidator.validateExpiryDate('12/$yy'), isTrue);
      expect(CardValidator.validateExpiryDate('12/$futureYear'), isTrue);
      expect(CardValidator.validateExpiryDate('01/20'), isFalse);
      expect(CardValidator.validateExpiryDate('invalid'), isFalse);
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
      // Unknown card type accepts standard 3 or 4 digits:
      expect(CardValidator.validateCvv('123'), isTrue);
      expect(CardValidator.validateCvv('1234'), isTrue);
      expect(CardValidator.validateCvv('12'), isFalse);
    });
  });

  group('Card Number Validation', () {
    test('validateCardNumber verifies both length and Luhn checksum', () {
      // 16-digit valid Visa
      expect(CardValidator.validateCardNumber('4532015112830366'), isTrue);
      // Formatted card numbers with spaces
      expect(
        CardValidator.validateCardNumber('4532 0151 1283 0366'),
        isTrue,
      );
      // Valid Luhn but invalid length (11 digits) -> rejected
      expect(CardValidator.validateLuhn('49927398716'), isTrue);
      expect(CardValidator.validateCardNumber('49927398716'), isFalse);
      // 15-digit valid Amex
      expect(CardValidator.validateCardNumber('378282246310005'), isTrue);
      expect(
        CardValidator.validateCardNumber('3782 822463 10005'),
        isTrue,
      );
      // 16-digit valid Mastercard
      expect(CardValidator.validateCardNumber('5105105105105100'), isTrue);
      // Checksum corrupted -> rejected
      expect(CardValidator.validateCardNumber('4532015112830367'), isFalse);
      // Empty or non-numeric strings
      expect(CardValidator.validateCardNumber(''), isFalse);
      expect(CardValidator.validateCardNumber('   '), isFalse);
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

    test('formats 19-digit cards without truncating digits', () {
      expect(
        CardValidator.formatNumber('5018123456789012345'),
        '5018 1234 5678 9012 345',
      );
    });

    test('formats expiry as MM/YY', () {
      expect(CardValidator.formatExpiry('1228'), '12/28');
      expect(CardValidator.formatExpiry('05'), '05');
      expect(CardValidator.formatExpiry(''), '');
    });

    test('CardNumberInputFormatter formats input value dynamically', () {
      const formatter = CardNumberInputFormatter();
      final updated = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '4111222233334444'),
      );
      expect(updated.text, '4111 2222 3333 4444');
      expect(updated.selection.baseOffset, 19);
    });

    test('CardNumberInputFormatter preserves cursor offset during middle edit',
        () {
      const formatter = CardNumberInputFormatter();
      final updated = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '4111 2222 3333 4444',
          selection: TextSelection.collapsed(offset: 7),
        ),
        const TextEditingValue(
          text: '4111 2522 3333 4444',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(updated.text, '4111 2522 3333 4444');
      expect(updated.selection.baseOffset, 8);
    });

    test('CardExpiryInputFormatter inserts slash and limits to 4 digits', () {
      const formatter = CardExpiryInputFormatter();
      final updated = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1228555'),
      );
      expect(updated.text, '12/28');
      expect(updated.selection.baseOffset, 5);
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
        showLaser: false,
        showCardDesign: false,
        onCardDetected: (_) {},
        onCancel: () {},
      );

      expect(overlayView.heroTag, 'test_hero_tag');
      expect(overlayView.laserColor, Colors.pink);
      expect(overlayView.guidanceText, 'Keep steady');
      expect(overlayView.showLaser, isFalse);
      expect(overlayView.showCardDesign, isFalse);
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

    test('CardScannerHeroButton supports showLaser and showCardDesign toggles',
        () {
      final button = CardScannerHeroButton(
        showLaser: false,
        showCardDesign: false,
      );

      expect(button.showLaser, isFalse);
      expect(button.showCardDesign, isFalse);
    });

    test(
        'CardScannerHeroButton supports showCloseButton boolean and closeButton widget',
        () {
      final buttonWithoutClose = CardScannerHeroButton(showCloseButton: false);
      expect(buttonWithoutClose.showCloseButton, isFalse);

      const customClose = Icon(Icons.cancel_outlined);
      final buttonWithCustomClose = CardScannerHeroButton(
        showCloseButton: true,
        closeButton: customClose,
      );
      expect(buttonWithCustomClose.showCloseButton, isTrue);
      expect(buttonWithCustomClose.closeButton, customClose);
    });

    test(
        'CardCameraOverlayView supports custom laserColor, showLaser, and showCardDesign',
        () {
      final overlay = CardCameraOverlayView(
        heroTag: 'custom_tag',
        laserColor: Colors.greenAccent,
        showLaser: false,
        showCardDesign: false,
        onCardDetected: (_) {},
        onCancel: () {},
      );

      expect(overlay.laserColor, Colors.greenAccent);
      expect(overlay.showLaser, isFalse);
      expect(overlay.showCardDesign, isFalse);
    });

    test(
        'CardCameraOverlayView supports showCloseButton boolean and custom closeButton widget',
        () {
      final overlayWithoutClose = CardCameraOverlayView(
        heroTag: 'tag1',
        laserColor: Colors.teal,
        showCloseButton: false,
        onCardDetected: (_) {},
        onCancel: () {},
      );
      expect(overlayWithoutClose.showCloseButton, isFalse);

      const customClose = Text('Dismiss');
      final overlayWithClose = CardCameraOverlayView(
        heroTag: 'tag2',
        laserColor: Colors.teal,
        showCloseButton: true,
        closeButton: customClose,
        onCardDetected: (_) {},
        onCancel: () {},
      );
      expect(overlayWithClose.showCloseButton, isTrue);
      expect(overlayWithClose.closeButton, customClose);
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
      'CardCameraOverlayView renders custom close button when showCloseButton is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardCameraOverlayView(
              heroTag: 'custom_render_test',
              laserColor: Colors.purple,
              showCloseButton: true,
              closeButton: const Text('Exit Scanner'),
              onCardDetected: (_) {},
              onCancel: () {},
            ),
          ),
        );

        expect(find.text('Exit Scanner'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('close_camera_overlay_button')),
          findsOneWidget,
        );
      },
    );

    test('EmbeddedCardCamera defaults showLaser and showCardDesign to true',
        () {
      final camera = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
      );
      expect(camera.showLaser, isTrue);
      expect(camera.showCardDesign, isTrue);
    });

    test('EmbeddedCardCamera supports disabling showLaser and showCardDesign',
        () {
      final camera = EmbeddedCardCamera(
        onCardDetected: (_) {},
        onCancel: () {},
        showLaser: false,
        showCardDesign: false,
      );
      expect(camera.showLaser, isFalse);
      expect(camera.showCardDesign, isFalse);
    });

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

    testWidgets(
      'CardCameraOverlayScanner.buildHeroFlightShuttle renders custom shuttleIcon',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return CardCameraOverlayScanner.buildHeroFlightShuttle(
                  context,
                  const AlwaysStoppedAnimation<double>(0.5),
                  HeroFlightDirection.push,
                  context,
                  context,
                  shuttleIcon: Icons.credit_card_rounded,
                );
              },
            ),
          ),
        );

        expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'CardCameraOverlayScanner.buildHeroFlightShuttle renders custom shuttleChild',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return CardCameraOverlayScanner.buildHeroFlightShuttle(
                  context,
                  const AlwaysStoppedAnimation<double>(0.5),
                  HeroFlightDirection.push,
                  context,
                  context,
                  shuttleChild: const Text('Flying Child'),
                );
              },
            ),
          ),
        );

        expect(find.text('Flying Child'), findsOneWidget);
      },
    );

    testWidgets(
      'CardScannerHeroButton passes child as shuttleChild by default in flight shuttle',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                const button = CardScannerHeroButton(
                  child: Text('My Custom Button'),
                );
                final hero = button.build(context) as Hero;
                return hero.flightShuttleBuilder!(
                  context,
                  const AlwaysStoppedAnimation<double>(0.5),
                  HeroFlightDirection.push,
                  context,
                  context,
                );
              },
            ),
          ),
        );

        expect(find.text('My Custom Button'), findsOneWidget);
      },
    );

    test(
      'CardScannerHeroButton and CardCameraOverlayView accept shuttleChild and shuttleIcon',
      () {
        const customChild = Icon(Icons.flash_on);
        const button = CardScannerHeroButton(
          shuttleChild: customChild,
          shuttleIcon: Icons.flash_on,
        );
        expect(button.shuttleChild, equals(customChild));
        expect(button.shuttleIcon, equals(Icons.flash_on));

        final overlay = CardCameraOverlayView(
          heroTag: 'test_tag',
          laserColor: Colors.blue,
          shuttleChild: customChild,
          shuttleIcon: Icons.flash_on,
          onCardDetected: (_) {},
          onCancel: () {},
        );
        expect(overlay.shuttleChild, equals(customChild));
        expect(overlay.shuttleIcon, equals(Icons.flash_on));
      },
    );
  });

  group('CardBrandIcon Custom Company Assets & Config', () {
    tearDown(() {
      CardBrandIconConfig.reset();
    });

    testWidgets(
      'CardBrandIcon renders custom icon from customIcons map',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardBrandIcon(
                cardType: CardType.visa,
                customIcons: const {
                  CardType.visa: Text('MY_COMPANY_VISA'),
                },
              ),
            ),
          ),
        );

        expect(find.text('MY_COMPANY_VISA'), findsOneWidget);
      },
    );

    testWidgets('CardBrandIcon renders custom icon from iconBuilder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardBrandIcon(
              cardType: CardType.mastercard,
              iconBuilder: (context, type) {
                if (type == CardType.mastercard) {
                  return const Text('MY_COMPANY_MASTERCARD');
                }
                return null;
              },
            ),
          ),
        ),
      );

      expect(find.text('MY_COMPANY_MASTERCARD'), findsOneWidget);
    });

    testWidgets(
      'CardBrandIcon renders global custom icon from CardBrandIconConfig',
      (tester) async {
        CardBrandIconConfig.setGlobalIcons(const {
          CardType.americanExpress: Text('GLOBAL_AMEX_LOGO'),
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardBrandIcon(cardType: CardType.americanExpress),
            ),
          ),
        );

        expect(find.text('GLOBAL_AMEX_LOGO'), findsOneWidget);
      },
    );

    testWidgets(
      'CardBrandIcon falls back to built-in vector badge when no custom icon',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CardBrandIcon(cardType: CardType.visa)),
          ),
        );

        expect(find.text('VISA'), findsOneWidget);
      },
    );

    testWidgets(
      'CardBrandIcon uses defaultIcon for unmapped card brands but keeps specific customIcons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CardBrandIcon(
                    cardType: CardType.visa,
                    customIcons: const {
                      CardType.visa: Text('CUSTOM_VISA'),
                    },
                    defaultIcon: const Text('CUSTOM_DEFAULT'),
                  ),
                  CardBrandIcon(
                    cardType: CardType.mastercard,
                    customIcons: const {
                      CardType.visa: Text('CUSTOM_VISA'),
                    },
                    defaultIcon: const Text('CUSTOM_DEFAULT'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('CUSTOM_VISA'), findsOneWidget);
        expect(find.text('CUSTOM_DEFAULT'), findsOneWidget);
      },
    );

    testWidgets(
      'CardBrandIcon renders globalDefaultIcon from CardBrandIconConfig when unmapped',
      (tester) async {
        CardBrandIconConfig.setGlobalDefaultIcon(
            const Text('GLOBAL_DEFAULT_ICON'));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CardBrandIcon(cardType: CardType.jcb),
            ),
          ),
        );

        expect(find.text('GLOBAL_DEFAULT_ICON'), findsOneWidget);

        CardBrandIconConfig.reset();
        expect(CardBrandIconConfig.globalDefaultIcon, isNull);
      },
    );
  });
}
