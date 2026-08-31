import 'package:flutter/material.dart';

import '../models/app_subscription_package.dart';
import '../models/customer_entitlement_info.dart';
import '../services/i_purchase_service.dart';

/// Interactive Paywall UI presenting subscription tiers, feature checklists, and purchase action.
class PaywallView extends StatefulWidget {
  const PaywallView({
    super.key,
    required this.purchaseService,
    this.title = 'Unlock CodeStore Pro',
    this.subtitle = 'Get unlimited access to all advanced modular features.',
    this.features = const [
      'Unlimited Cloud Sync & Devices',
      'Advanced Biometric Vault & App Lock',
      'High Priority Local & Push Notifications',
      'Custom Home Screen Widget Themes',
      'Full Offline Mode & Network Analytics',
    ],
    this.onPurchaseCompleted,
    this.onRestoreCompleted,
  });

  final IPurchaseService purchaseService;
  final String title;
  final String subtitle;
  final List<String> features;
  final ValueChanged<CustomerEntitlementInfo>? onPurchaseCompleted;
  final ValueChanged<CustomerEntitlementInfo>? onRestoreCompleted;

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  List<AppSubscriptionPackage> _packages = [];
  AppSubscriptionPackage? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);
    final offerings = await widget.purchaseService.getOfferings();
    if (mounted) {
      setState(() {
        _packages = offerings;
        // Default select the popular or annual package
        if (offerings.isNotEmpty) {
          _selectedPackage = offerings.firstWhere(
            (p) => p.isPopular,
            orElse: () => offerings.first,
          );
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final result = await widget.purchaseService.purchasePackage(
      _selectedPackage!,
    );

    if (mounted) {
      setState(() => _isPurchasing = false);
      if (result.isSuccess && result.customerInfo != null) {
        widget.onPurchaseCompleted?.call(result.customerInfo!);
      } else if (!result.isCancelled) {
        setState(() {
          _errorMessage =
              result.errorMessage ?? 'Purchase could not be completed.';
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final info = await widget.purchaseService.restorePurchases();

    if (mounted) {
      setState(() => _isPurchasing = false);
      widget.onRestoreCompleted?.call(info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, colors),
          const SizedBox(height: 24),
          _buildFeatureList(context, colors),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ..._packages.map((pkg) => _buildPackageCard(context, pkg, colors)),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: colors.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isPurchasing || _selectedPackage == null
                ? null
                : _handlePurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: _isPurchasing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _selectedPackage?.introductoryPriceString != null
                        ? 'Start 7-Day Free Trial'
                        : 'Continue with ${_selectedPackage?.title ?? "Selected Plan"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isPurchasing ? null : _handleRestore,
            child: Text(
              'Restore Purchases',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recurring billing. Cancel anytime in App Store / Google Play account settings.',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: widget.features
            .map(
              (feat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feat,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    AppSubscriptionPackage pkg,
    ColorScheme colors,
  ) {
    final isSelected = _selectedPackage?.identifier == pkg.identifier;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = pkg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? colors.primary : colors.outline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pkg.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (pkg.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pkg.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pkg.priceString,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.primary,
                  ),
                ),
                Text(
                  pkg.billingPeriodLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
