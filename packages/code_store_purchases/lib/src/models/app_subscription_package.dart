import 'package:flutter/material.dart';

/// Normalized package duration / billing period types.
enum AppPackageType {
  /// Billed weekly.
  weekly,

  /// Billed monthly.
  monthly,

  /// Billed annually (yearly).
  annual,

  /// One-time lifetime purchase.
  lifetime,

  /// Custom product type.
  custom,
}

/// Normalized subscription or in-app purchase package item.
@immutable
class AppSubscriptionPackage {
  const AppSubscriptionPackage({
    required this.identifier,
    required this.productIdentifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.rawPrice,
    required this.currencyCode,
    this.packageType = AppPackageType.custom,
    this.periodString,
    this.introductoryPriceString,
    this.isPopular = false,
  });

  /// RevenueCat package identifier (e.g. '$rc_monthly', '$rc_annual').
  final String identifier;

  /// Store product ID (e.g. 'com.codestore.app.monthly_pro').
  final String productIdentifier;

  /// Display title.
  final String title;

  /// Display description.
  final String description;

  /// Formatted localized price string (e.g. '$9.99', '€8.99').
  final String priceString;

  /// Raw numeric price.
  final double rawPrice;

  /// ISO 4217 Currency code (e.g. 'USD', 'EUR').
  final String currencyCode;

  /// Package billing type.
  final AppPackageType packageType;

  /// Display period (e.g. '/ month', '/ year').
  final String? periodString;

  /// Optional introductory / free trial promo text.
  final String? introductoryPriceString;

  /// Whether to highlight this package as "Best Value" / "Most Popular".
  final bool isPopular;

  /// Returns friendly billing cadence label.
  String get billingPeriodLabel {
    if (periodString != null && periodString!.isNotEmpty) {
      return periodString!;
    }
    switch (packageType) {
      case AppPackageType.weekly:
        return '/ week';
      case AppPackageType.monthly:
        return '/ month';
      case AppPackageType.annual:
        return '/ year';
      case AppPackageType.lifetime:
        return 'one-time';
      case AppPackageType.custom:
        return '';
    }
  }

  @override
  String toString() =>
      'AppSubscriptionPackage(id: $identifier, price: $priceString, type: $packageType)';
}
