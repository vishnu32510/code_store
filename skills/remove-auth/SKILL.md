---
name: remove-auth
description: Removes authentication UI, services, and logic from the project.
---
# remove-auth

Use this skill to strip out all authentication-related code if the cloned project does not require user sign-in.

## Workflow

### Step 1: Remove Authentication Dependencies

Remove any auth-specific packages from `pubspec.yaml`:
```bash
flutter pub remove firebase_auth google_sign_in sign_in_with_apple
```

### Step 2: Delete Auth Directories

Delete directories associated with authentication features:
```bash
rm -rf lib/features/auth
rm -rf lib/services/auth
```
*(Adjust the paths based on the specific architecture of the template).*

### Step 3: Remove Auth Guards from Router

Locate the app's router (e.g., `lib/router.dart` or `lib/app_router.dart`) and remove logic that redirects unauthenticated users to a login screen. Set the initial route to the home page or onboarding.

### Step 4: Clean up App State

If using Riverpod, Provider, or Bloc, remove providers that watch auth state:
- Find and remove `authProvider` or `userProvider`.
- Remove auth initialization calls in `main.dart`.

### Step 5: Verification

Run the project to ensure no dangling references remain:
```bash
flutter analyze
flutter test
```
