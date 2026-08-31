import 'dart:async';

import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_purchases/code_store_purchases.dart';
import 'package:flutter/material.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final IPurchaseService _purchaseService = getIt<IPurchaseService>();

  CustomerEntitlementInfo _customerInfo = CustomerEntitlementInfo.empty();
  StreamSubscription<CustomerEntitlementInfo>? _subscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    final info = await _purchaseService.getCustomerInfo();
    if (mounted) {
      setState(() {
        _customerInfo = info;
        _isLoading = false;
      });
    }

    _subscription = _purchaseService.onCustomerInfoUpdated.listen((info) {
      if (mounted) {
        setState(() => _customerInfo = info);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions & Pro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Entitlements',
            onPressed: _loadCustomerInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStatusBanner(context, colors),
                ),
                const SizedBox(height: 16),
                PaywallView(
                  purchaseService: _purchaseService,
                  onPurchaseCompleted: (info) {
                    setState(() => _customerInfo = info);
                    getIt<IToastService>().showSuccess('Pro subscription activated!');
                  },
                  onRestoreCompleted: (info) {
                    setState(() => _customerInfo = info);
                    if (info.isPro) {
                      getIt<IToastService>().showSuccess('Purchases restored successfully!');
                    } else {
                      getIt<IToastService>().showInfo('No active subscriptions found to restore.');
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, ColorScheme colors) {
    final isPro = _customerInfo.isPro;
    final bannerColor = isPro ? Colors.amber.shade700 : colors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPro ? Icons.verified_rounded : Icons.star_outline_rounded,
              color: bannerColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'Pro Membership Active' : 'Free Tier Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPro
                      ? 'Active entitlements: ${_customerInfo.activeEntitlements.join(", ")}'
                      : 'Upgrade to Pro to unlock all modular features.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
