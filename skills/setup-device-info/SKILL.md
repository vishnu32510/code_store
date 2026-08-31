---
name: setup-device-info
description: Configures app package metadata, device hardware diagnostics, and DI registration for code_store_device_info.
---

# Setup Device Info Skill

This skill configures application version inspection, hardware diagnostics, and DI registration for `code_store_device_info`.

## Instructions for the Agent

When triggered, execute the following steps:

1. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_device_info` is declared under `dependencies:`.

2. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupDeviceInfoDI()` is called inside `setupDI()`.

3. **Verify UI & Routing Integration**:
   - Route `AppRoutes.deviceInfo = '/device-info'` points to `DeviceInfoScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

4. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` across all packages to confirm zero errors.
