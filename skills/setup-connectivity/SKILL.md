---
name: setup-connectivity
description: Configures real-time network connectivity monitor, offline banners, and DI registration for code_store_connectivity.
---

# Setup Connectivity Skill

This skill configures real-time network monitoring, connection types (Wi-Fi, Cellular, Ethernet), offline banner wrappers, and DI registration for `code_store_connectivity`.

## Instructions for the Agent

When triggered, execute the following steps:

1. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_connectivity` is declared under `dependencies:`.

2. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupConnectivityDI()` is called inside `setupDI()`.

3. **Verify App-level Offline Banner Wrapper**:
   - Check `lib/main.dart` builder to ensure `OfflineBannerWrapper` wraps the root navigator.

4. **Verify UI & Routing Integration**:
   - Route `AppRoutes.connectivity = '/connectivity'` points to `ConnectivityScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

5. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` across all packages to confirm zero errors.
