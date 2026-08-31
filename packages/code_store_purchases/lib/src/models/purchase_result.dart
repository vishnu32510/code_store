import 'package:flutter/material.dart';

import 'customer_entitlement_info.dart';

/// Purchase transaction outcome status.
enum PurchaseStatus {
  /// Transaction completed and entitlements unlocked.
  success,

  /// User dismissed the native store payment sheet without paying.
  userCancelled,

  /// Payment is pending approval (e.g. Ask to Buy / Parent approval).
  pending,

  /// Transaction failed with an error.
  error,
}

/// Normalized result of an in-app purchase request.
@immutable
class PurchaseResult {
  const PurchaseResult({
    required this.status,
    this.customerInfo,
    this.errorMessage,
  });

  final PurchaseStatus status;
  final CustomerEntitlementInfo? customerInfo;
  final String? errorMessage;

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.userCancelled;

  factory PurchaseResult.success(CustomerEntitlementInfo info) =>
      PurchaseResult(status: PurchaseStatus.success, customerInfo: info);

  factory PurchaseResult.cancelled() =>
      const PurchaseResult(status: PurchaseStatus.userCancelled);

  factory PurchaseResult.pending() =>
      const PurchaseResult(status: PurchaseStatus.pending);

  factory PurchaseResult.error(String message) =>
      PurchaseResult(status: PurchaseStatus.error, errorMessage: message);
}
