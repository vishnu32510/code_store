import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/app_subscription_package.dart';
import '../models/customer_entitlement_info.dart';
import '../models/purchase_result.dart';
import 'i_purchase_service.dart';

/// Concrete implementation of [IPurchaseService] wrapping RevenueCat's `purchases_flutter` SDK.
class PurchasesService implements IPurchaseService {
  PurchasesService();

  bool _isConfigured = false;
  final StreamController<CustomerEntitlementInfo> _customerInfoController =
      StreamController<CustomerEntitlementInfo>.broadcast();

  CustomerEntitlementInfo _mapCustomerInfo(CustomerInfo info) {
    final active = <String>{};
    for (final entry in info.entitlements.all.entries) {
      if (entry.value.isActive) {
        active.add(entry.key);
      }
    }

    final allProducts = info.allPurchasedProductIdentifiers.toSet();

    // Check expiration date from latest active entitlement
    DateTime? expDate;
    bool willRenew = false;
    for (final ent in info.entitlements.active.values) {
      if (ent.expirationDate != null) {
        final parsed = DateTime.tryParse(ent.expirationDate!);
        if (parsed != null && (expDate == null || parsed.isAfter(expDate))) {
          expDate = parsed;
          willRenew = ent.willRenew;
        }
      }
    }

    return CustomerEntitlementInfo(
      activeEntitlements: active,
      allPurchasedProductIdentifiers: allProducts,
      originalAppUserId: info.originalAppUserId,
      expirationDate: expDate,
      willRenew: willRenew,
    );
  }

  AppPackageType _toPackageType(PackageType type) {
    switch (type) {
      case PackageType.weekly:
        return AppPackageType.weekly;
      case PackageType.monthly:
        return AppPackageType.monthly;
      case PackageType.annual:
        return AppPackageType.annual;
      case PackageType.lifetime:
        return AppPackageType.lifetime;
      default:
        return AppPackageType.custom;
    }
  }

  @override
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
  }) async {
    if (kIsWeb) {
      debugPrint('PurchasesService: Web platform uses Stripe / mock entitlements');
      _isConfigured = true;
      return;
    }

    if (apiKey.isEmpty || apiKey == 'placeholder_api_key') {
      debugPrint('PurchasesService: No valid RevenueCat API key provided. Operating in demo mode.');
      _isConfigured = false;
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = appUserId;
      await Purchases.configure(configuration);

      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfoController.add(_mapCustomerInfo(info));
      });

      _isConfigured = true;
      debugPrint('PurchasesService: RevenueCat successfully initialized');
    } catch (e) {
      debugPrint('PurchasesService initialization error: $e');
    }
  }

  @override
  Future<List<AppSubscriptionPackage>> getOfferings() async {
    if (!_isConfigured || kIsWeb) {
      // Return high-quality mock packages for demo / test runs
      return const [
        AppSubscriptionPackage(
          identifier: r'$rc_monthly',
          productIdentifier: 'com.codestore.app.pro.monthly',
          title: 'Monthly Pro',
          description: 'Full access to all premium features, billed monthly.',
          priceString: r'$4.99',
          rawPrice: 4.99,
          currencyCode: 'USD',
          packageType: AppPackageType.monthly,
          periodString: '/ month',
        ),
        AppSubscriptionPackage(
          identifier: r'$rc_annual',
          productIdentifier: 'com.codestore.app.pro.annual',
          title: 'Annual Pro',
          description: 'Save 40% with annual billing. 7-day free trial included.',
          priceString: r'$35.99',
          rawPrice: 35.99,
          currencyCode: 'USD',
          packageType: AppPackageType.annual,
          periodString: '/ year',
          introductoryPriceString: '7-Day Free Trial',
          isPopular: true,
        ),
        AppSubscriptionPackage(
          identifier: r'$rc_lifetime',
          productIdentifier: 'com.codestore.app.pro.lifetime',
          title: 'Lifetime Access',
          description: 'Pay once, unlock all current and future features forever.',
          priceString: r'$99.99',
          rawPrice: 99.99,
          currencyCode: 'USD',
          packageType: AppPackageType.lifetime,
          periodString: 'one-time',
        ),
      ];
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return [];
      }

      return current.availablePackages.map((pkg) {
        final storeProduct = pkg.storeProduct;
        return AppSubscriptionPackage(
          identifier: pkg.identifier,
          productIdentifier: storeProduct.identifier,
          title: storeProduct.title,
          description: storeProduct.description,
          priceString: storeProduct.priceString,
          rawPrice: storeProduct.price,
          currencyCode: storeProduct.currencyCode,
          packageType: _toPackageType(pkg.packageType),
          isPopular: pkg.packageType == PackageType.annual,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return [];
    }
  }

  @override
  Future<PurchaseResult> purchasePackage(AppSubscriptionPackage package) async {
    if (!_isConfigured || kIsWeb) {
      // Mock purchase success in demo mode
      final mockInfo = CustomerEntitlementInfo(
        activeEntitlements: {'pro'},
        allPurchasedProductIdentifiers: {package.productIdentifier},
        expirationDate: DateTime.now().add(const Duration(days: 365)),
        willRenew: true,
      );
      _customerInfoController.add(mockInfo);
      return PurchaseResult.success(mockInfo);
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final rcPackage = current?.availablePackages.firstWhere(
        (p) => p.identifier == package.identifier,
        orElse: () => throw Exception('Package ${package.identifier} not found in offerings'),
      );

      if (rcPackage == null) {
        return PurchaseResult.error('Package not found');
      }

      final customerInfo = await Purchases.purchasePackage(rcPackage);
      final mapped = _mapCustomerInfo(customerInfo);
      return PurchaseResult.success(mapped);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.error(e.message ?? 'Purchase failed');
    } catch (e) {
      return PurchaseResult.error(e.toString());
    }
  }

  @override
  Future<CustomerEntitlementInfo> restorePurchases() async {
    if (!_isConfigured || kIsWeb) {
      const mock = CustomerEntitlementInfo(
        activeEntitlements: {'pro'},
        allPurchasedProductIdentifiers: {'com.codestore.app.pro.annual'},
        willRenew: true,
      );
      _customerInfoController.add(mock);
      return mock;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      final mapped = _mapCustomerInfo(customerInfo);
      _customerInfoController.add(mapped);
      return mapped;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return CustomerEntitlementInfo.empty();
    }
  }

  @override
  Future<CustomerEntitlementInfo> getCustomerInfo() async {
    if (!_isConfigured || kIsWeb) {
      return CustomerEntitlementInfo.empty();
    }
    try {
      final info = await Purchases.getCustomerInfo();
      return _mapCustomerInfo(info);
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return CustomerEntitlementInfo.empty();
    }
  }

  @override
  Future<bool> isEntitled(String entitlementId) async {
    final info = await getCustomerInfo();
    return info.isEntitled(entitlementId);
  }

  @override
  Future<CustomerEntitlementInfo> logIn(String appUserId) async {
    if (!_isConfigured || kIsWeb) {
      return CustomerEntitlementInfo.empty();
    }
    try {
      final result = await Purchases.logIn(appUserId);
      final mapped = _mapCustomerInfo(result.customerInfo);
      _customerInfoController.add(mapped);
      return mapped;
    } catch (e) {
      debugPrint('Error logging in Purchases: $e');
      return CustomerEntitlementInfo.empty();
    }
  }

  @override
  Future<CustomerEntitlementInfo> logOut() async {
    if (!_isConfigured || kIsWeb) {
      return CustomerEntitlementInfo.empty();
    }
    try {
      final info = await Purchases.logOut();
      final mapped = _mapCustomerInfo(info);
      _customerInfoController.add(mapped);
      return mapped;
    } catch (e) {
      debugPrint('Error logging out Purchases: $e');
      return CustomerEntitlementInfo.empty();
    }
  }

  @override
  Stream<CustomerEntitlementInfo> get onCustomerInfoUpdated =>
      _customerInfoController.stream;
}
