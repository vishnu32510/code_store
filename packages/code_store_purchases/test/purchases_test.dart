import 'dart:async';

import 'package:code_store_purchases/code_store_purchases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockPurchaseService implements IPurchaseService {
  CustomerEntitlementInfo _customerInfo = CustomerEntitlementInfo.empty();
  final _controller = StreamController<CustomerEntitlementInfo>.broadcast();

  final List<AppSubscriptionPackage> _mockPackages = const [
    AppSubscriptionPackage(
      identifier: r'$rc_monthly',
      productIdentifier: 'com.codestore.app.pro.monthly',
      title: 'Monthly Pro',
      description: 'Billed monthly',
      priceString: r'$4.99',
      rawPrice: 4.99,
      currencyCode: 'USD',
      packageType: AppPackageType.monthly,
    ),
    AppSubscriptionPackage(
      identifier: r'$rc_annual',
      productIdentifier: 'com.codestore.app.pro.annual',
      title: 'Annual Pro',
      description: 'Billed annually',
      priceString: r'$35.99',
      rawPrice: 35.99,
      currencyCode: 'USD',
      packageType: AppPackageType.annual,
      isPopular: true,
    ),
  ];

  @override
  Future<void> initialize({required String apiKey, String? appUserId}) async {}

  @override
  Future<List<AppSubscriptionPackage>> getOfferings() async => _mockPackages;

  @override
  Future<PurchaseResult> purchasePackage(AppSubscriptionPackage package) async {
    _customerInfo = CustomerEntitlementInfo(
      activeEntitlements: {'pro'},
      allPurchasedProductIdentifiers: {package.productIdentifier},
      willRenew: true,
    );
    _controller.add(_customerInfo);
    return PurchaseResult.success(_customerInfo);
  }

  @override
  Future<CustomerEntitlementInfo> restorePurchases() async {
    _customerInfo = const CustomerEntitlementInfo(
      activeEntitlements: {'pro'},
      allPurchasedProductIdentifiers: {'com.codestore.app.pro.annual'},
      willRenew: true,
    );
    _controller.add(_customerInfo);
    return _customerInfo;
  }

  @override
  Future<CustomerEntitlementInfo> getCustomerInfo() async => _customerInfo;

  @override
  Future<bool> isEntitled(String entitlementId) async =>
      _customerInfo.isEntitled(entitlementId);

  @override
  Future<CustomerEntitlementInfo> logIn(String appUserId) async =>
      _customerInfo;

  @override
  Future<CustomerEntitlementInfo> logOut() async {
    _customerInfo = CustomerEntitlementInfo.empty();
    _controller.add(_customerInfo);
    return _customerInfo;
  }

  @override
  Stream<CustomerEntitlementInfo> get onCustomerInfoUpdated =>
      _controller.stream;

  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Purchases Models & DI', () {
    final sl = GetIt.asNewInstance();

    test('AppSubscriptionPackage model properties work', () {
      const pkg = AppSubscriptionPackage(
        identifier: r'$rc_annual',
        productIdentifier: 'pro.annual',
        title: 'Annual Pro',
        description: 'Annual plan',
        priceString: r'$39.99',
        rawPrice: 39.99,
        currencyCode: 'USD',
        packageType: AppPackageType.annual,
        isPopular: true,
      );

      expect(pkg.billingPeriodLabel, '/ year');
      expect(pkg.isPopular, true);
    });

    test('CustomerEntitlementInfo model properties work', () {
      final info = const CustomerEntitlementInfo(
        activeEntitlements: {'pro', 'analytics'},
        allPurchasedProductIdentifiers: {'pro.annual'},
      );

      expect(info.isPro, true);
      expect(info.isEntitled('pro'), true);
      expect(info.isEntitled('non_existent'), false);
    });

    test('setupPurchasesDI registers custom mock service', () {
      final mock = MockPurchaseService();
      setupPurchasesDI(locator: sl, customService: mock);

      expect(sl.isRegistered<IPurchaseService>(), true);
      expect(sl<IPurchaseService>(), isA<MockPurchaseService>());
    });
  });

  group('PaywallView Widget Tests', () {
    late MockPurchaseService mockService;

    setUp(() {
      mockService = MockPurchaseService();
    });

    tearDown(() {
      mockService.dispose();
    });

    testWidgets('Renders offerings, selects package, and triggers purchase', (
      tester,
    ) async {
      CustomerEntitlementInfo? purchasedInfo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallView(
              purchaseService: mockService,
              onPurchaseCompleted: (info) => purchasedInfo = info,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unlock CodeStore Pro'), findsOneWidget);
      expect(find.text('Monthly Pro'), findsOneWidget);
      expect(find.text('Annual Pro'), findsOneWidget);

      // Ensure button is scrolled into view and tap to purchase
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(purchasedInfo, isNotNull);
      expect(purchasedInfo!.isPro, true);
    });
  });
}
