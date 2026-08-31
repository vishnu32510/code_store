import '../models/app_subscription_package.dart';
import '../models/customer_entitlement_info.dart';
import '../models/purchase_result.dart';

/// Abstract contract for RevenueCat in-app subscriptions and entitlement management.
abstract interface class IPurchaseService {
  /// Initializes the RevenueCat Purchases SDK with the specified [apiKey] and optional [appUserId].
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
  });

  /// Fetches available store packages configured in RevenueCat Offerings.
  Future<List<AppSubscriptionPackage>> getOfferings();

  /// Initiates the native purchase sheet for the given [package].
  Future<PurchaseResult> purchasePackage(AppSubscriptionPackage package);

  /// Restores previous store purchases and returns updated customer entitlement status.
  Future<CustomerEntitlementInfo> restorePurchases();

  /// Fetches latest customer entitlement info from the server/cache.
  Future<CustomerEntitlementInfo> getCustomerInfo();

  /// Returns whether a specific entitlement (e.g. 'pro') is currently unlocked.
  Future<bool> isEntitled(String entitlementId);

  /// Synchronizes app user identity upon user log in.
  Future<CustomerEntitlementInfo> logIn(String appUserId);

  /// Resets customer identity upon user log out.
  Future<CustomerEntitlementInfo> logOut();

  /// Stream of customer info updates (e.g. renewals, expirations, purchases).
  Stream<CustomerEntitlementInfo> get onCustomerInfoUpdated;
}
