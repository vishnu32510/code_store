---
name: setup-secure-storage
description: Configures hardware-encrypted secure storage (iOS Keychain, Android KeyStore, Web) and DI registration for code_store_secure_storage.
---

# Setup Secure Storage Skill

This skill configures hardware-encrypted key-value storage for access tokens, refresh tokens, and encrypted offline caching (`code_store_secure_storage`).

## Instructions for the Agent

When triggered, execute the following steps:

1. **Verify Dependency in `pubspec.yaml`**:
   - Ensure `code_store_secure_storage` is declared under `dependencies:`.

2. **Verify Dependency Injection Setup**:
   - Check `lib/core/di/injection.dart`.
   - Ensure `setupSecureStorageDI()` is called inside `setupDI()`.

3. **Verify UI & Routing Integration**:
   - Route `AppRoutes.secureStorage = '/secure-storage'` points to `SecureStorageScreen` in `lib/core/config/routes.dart`.
   - Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
   - `DashboardScreen` remains untouched (Drawer-only rule).

4. **Completion & Verification**:
   - Run `flutter analyze` and `flutter test` to confirm zero errors.
