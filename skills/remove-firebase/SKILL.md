---
name: remove-firebase
description: Completely removes Firebase dependencies and initialization from the project.
---
# remove-firebase

Use this skill to strip out FlutterFire configuration and dependencies.

## Workflow

### Step 1: Delete Config Files

Run the following commands to delete all native and Dart config files related to Firebase:

```bash
rm -f firebase.json
rm -f lib/firebase_options.dart
rm -f android/app/google-services.json
rm -f ios/Runner/GoogleService-Info.plist
rm -rf .firebase/
```

### Step 2: Remove iOS Project References

Remove `GoogleService-Info.plist` from the Xcode project so the iOS build doesn't fail:

```bash
sed -i '' '/GoogleService-Info.plist/d' ios/Runner.xcodeproj/project.pbxproj
```

### Step 3: Remove Package Dependencies

Remove or comment out Firebase packages in `pubspec.yaml` to prevent bloated native builds:
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`
- `sign_in_with_apple`

### Step 4: Update Native Configurations

- In `android/app/build.gradle` (or `build.gradle.kts`), remove or comment out `id("com.google.gms.google-services")` or `apply plugin: 'com.google.gms.google-services'`

### Step 5: Remove Initialization from Dart

Comment out `Firebase.initializeApp(...)` and its import in `lib/main.dart` or wherever initialization occurs.

```dart
// Before:
import 'package:firebase_core/firebase_core.dart';
import 'package:ring_sizer/firebase_options.dart';
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// After:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:ring_sizer/firebase_options.dart';
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```
