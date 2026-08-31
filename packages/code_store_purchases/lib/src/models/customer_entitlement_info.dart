import 'package:flutter/material.dart';

/// Normalized user subscription entitlement and active purchase status.
@immutable
class CustomerEntitlementInfo {
  const CustomerEntitlementInfo({
    required this.activeEntitlements,
    required this.allPurchasedProductIdentifiers,
    this.originalAppUserId,
    this.expirationDate,
    this.willRenew = false,
  });

  /// Set of active entitlement identifiers (e.g. {'pro', 'premium', 'unlimited'}).
  final Set<String> activeEntitlements;

  /// Set of all purchased product IDs in store history.
  final Set<String> allPurchasedProductIdentifiers;

  /// User identifier registered in RevenueCat.
  final String? originalAppUserId;

  /// Expiration date of the latest subscription if applicable.
  final DateTime? expirationDate;

  /// Whether the subscription is set to auto-renew.
  final bool willRenew;

  /// Whether the user has active Pro access.
  bool get isPro =>
      activeEntitlements.contains('pro') ||
      activeEntitlements.contains('premium') ||
      activeEntitlements.isNotEmpty;

  /// Returns true if an entitlement with [entitlementId] is currently active.
  bool isEntitled(String entitlementId) =>
      activeEntitlements.contains(entitlementId);

  /// Empty / Unsubscribed customer info factory.
  factory CustomerEntitlementInfo.empty() => const CustomerEntitlementInfo(
    activeEntitlements: {},
    allPurchasedProductIdentifiers: {},
  );

  @override
  String toString() =>
      'CustomerEntitlementInfo(isPro: $isPro, active: $activeEntitlements)';
}
