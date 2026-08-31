---
name: setup-purchases
description: Configures RevenueCat In-App Purchases, StoreKit 2, Google Play Billing, and DI registration for code_store_purchases.
---

# Setup Purchases Skill

This skill configures RevenueCat SDK credentials, offerings, and DI registration for `code_store_purchases`.

## Instructions for the Agent

When triggered, execute the following steps:

1. **RevenueCat API Keys Configuration**:
   - iOS Public API Key: `appl_...`
   - Android Public API Key: `goog_...`
   - Initialize in `lib/core/di/injection.dart` or during startup:
     ```dart
     getIt<IPurchaseService>().initialize(
       apiKey: Platform.isIOS ? 'appl_...' : 'goog_...',
       appUserId: currentUserId,
     );
     ```

2. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_purchases` is declared under `dependencies:`.

3. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupPurchasesDI()` is called inside `setupDI()`.

4. **Verify UI & Routing Integration**:
   - Route `AppRoutes.purchases = '/purchases'` points to `PurchasesScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

5. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` across all packages to confirm zero errors.
