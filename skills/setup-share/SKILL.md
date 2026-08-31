---
name: setup-share
description: Configures native system share sheets, referral links, and DI registration for code_store_share.
---

# Setup Share Skill

This skill configures native sharing capabilities for text, images, files, referral links, and DI registration for `code_store_share`.

## Instructions for the Agent

When triggered, execute the following steps:

1. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_share` is declared under `dependencies:`.

2. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupShareDI()` is called inside `setupDI()`.

3. **Verify UI & Routing Integration**:
   - Route `AppRoutes.share = '/share'` points to `ShareScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

4. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` across all packages to confirm zero errors.
