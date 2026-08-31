---
name: setup-home-widget
description: Sets up or scaffolds native Home Screen widgets for iOS (WidgetKit) and Android (Glance/AppWidgets) using home_widget_cli and code_store_home_widget, configuring App Group IDs and isolated Xcode schemes.
---

# Setup Home Screen Widgets Skill

This skill scaffolds and configures native iOS (WidgetKit) and Android (Jetpack Glance / AppWidgets) home screen widgets using `code_store_home_widget` and `home_widget_cli`.

## Prerequisites

1. Ensure `packages/code_store_home_widget` is referenced in the root `pubspec.yaml`:
   ```yaml
   dependencies:
     code_store_home_widget:
       path: packages/code_store_home_widget
   ```
2. Activate `home_widget_cli`:
   ```bash
   dart pub global activate home_widget_cli
   ```

---

## Step 1: Determine Configuration & App Group ID

1. **App Group ID**:
   * Format: `group.<bundle_id>` (e.g. `group.com.nungu.codestore`).
   * Set in `.env`:
     ```env
     APP_GROUP_ID=group.com.nungu.codestore
     ```
   * Set in `lib/core/utils/app_constants.dart`:
     ```dart
     static String get appGroupId =>
         dotenv.get('APP_GROUP_ID', fallback: 'group.com.nungu.codestore');
     ```

---

## Step 2: Scaffold Native Widget with CLI

Run the `home_widget create` command from the root Flutter project:

```bash
home_widget create <WidgetName> --ios-app-group-id <APP_GROUP_ID>
```

*(Example: `home_widget create WeatherForecastWidget --ios-app-group-id group.com.nungu.codestore`)*

This command automatically:
* Generates iOS SwiftUI widget files in `ios/<WidgetName>HomeWidget/`.
* Creates `ios/<WidgetName>HomeWidget.entitlements` with the App Group ID.
* Updates `ios/Runner/Runner.entitlements` with the App Group ID.
* Adds the Widget Extension target to `ios/Runner.xcodeproj/project.pbxproj`.
* Generates Android Kotlin Glance widget files in `android/app/src/main/kotlin/...`.
* Updates `android/app/build.gradle.kts` and `android/app/src/main/AndroidManifest.xml`.

---

## Step 3: Configure Xcode Scheme Build Isolation (iOS)

To prevent Xcode from trying to build Flutter SPM plugins (`url_launcher_ios`, `gal`, etc.) when running the widget extension target alone:

1. **Add `FRAMEWORK_SEARCH_PATHS`, `SWIFT_OPTIMIZATION_LEVEL`, and `baseConfigurationReference`** in `ios/Runner.xcodeproj/project.pbxproj` for the new widget target's build configurations:
   ```
   baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
   SWIFT_OPTIMIZATION_LEVEL = "-Onone"; // Required for Xcode live Canvas Previews
   DEBUG_INFORMATION_FORMAT = dwarf;
   FRAMEWORK_SEARCH_PATHS = (
       "$(inherited)",
       "$(PROJECT_DIR)/Flutter",
   );
   ```

2. **Create a shared Xcode Scheme** at `ios/Runner.xcodeproj/xcshareddata/xcschemes/<WidgetName>HomeWidget.xcscheme` with:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Scheme
      LastUpgradeVersion = "1510"
      version = "1.3">
      <BuildAction
         parallelizeBuildables = "YES"
         buildImplicitDependencies = "NO">
         <BuildActionEntries>
            <BuildActionEntry
               buildForTesting = "YES"
               buildForRunning = "YES"
               buildForProfiling = "YES"
               buildForArchiving = "YES"
               buildForAnalyzing = "YES">
               <BuildableReference
                  BuildableIdentifier = "primary"
                  BlueprintIdentifier = "<TARGET_BLUEPRINT_ID>"
                  BuildableName = "<WidgetName>HomeWidget.appex"
                  BlueprintName = "<WidgetName>HomeWidget"
                  ReferencedContainer = "container:Runner.xcodeproj">
               </BuildableReference>
            </BuildActionEntry>
         </BuildActionEntries>
      </BuildAction>
      <LaunchAction
         buildConfiguration = "Debug"
         selectedDebuggerIdentifier = ""
         selectedLauncherIdentifier = "Xcode.IDEFoundation.Launcher.PosixSpawn"
         launchStyle = "0"
         useCustomWorkingDirectory = "NO"
         ignoresPersistentStateOnLaunch = "NO"
         debugDocumentVersioning = "YES"
         debugServiceExtension = "internal"
         allowLocationSimulation = "YES"
         launchAutomaticallySubstyle = "2">
         <BuildableProductRunnable
            runnableDebuggingMode = "0">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "<TARGET_BLUEPRINT_ID>"
               BuildableName = "<WidgetName>HomeWidget.appex"
               BlueprintName = "<WidgetName>HomeWidget"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildableProductRunnable>
      </LaunchAction>
      <ProfileAction
         buildConfiguration = "Release"
         shouldUseLaunchSchemeArgsEnv = "YES"
         savedToolIdentifier = ""
         useCustomWorkingDirectory = "NO"
         debugDocumentVersioning = "YES">
      </ProfileAction>
   </Scheme>
   ```

---

## Step 4: Register and Bootstrap `HomeWidgetService`

1. **Dependency Injection** (`lib/core/di/injection.dart`):
   ```dart
   getIt.registerLazySingleton<HomeWidgetService>(
     () => HomeWidgetService(
       appGroupId: AppConstants.appGroupId,
       defaultAndroidName: '<WidgetName>HomeWidgetReceiver',
       defaultIOSName: '<WidgetName>HomeWidget',
     ),
   );
   ```

2. **App Bootstrap** (`lib/core/di/injection.dart`):
   ```dart
   // Initializes platform bridge, listens to live taps, and auto-dispatches cold starts
   await getIt<HomeWidgetService>().initialize(
     onNavigate: (route) => AppRouter.router.go(route),
   );
   ```

---

---

## Step 5: Pure Model & Data Synchronization

### A. Synchronize Structured JSON Models (Dart -> Swift/Kotlin)
```dart
// Flutter side:
await getIt<HomeWidgetService>().syncModel(
  key: 'user_profile',
  model: profileData,
  toJson: (p) => p.toJson(),
  actionUri: 'codestore://profile',
);
```

* **iOS Native (`WidgetBridge.swift`)**:
  ```swift
  let profile = WidgetBridge.decode(UserProfile.self, forKey: "user_profile")
  ```
* **Android Native (`WidgetBridge.kt`)**:
  ```kotlin
  val profile = WidgetBridge.getString(context, "user_profile")
  ```

### B. Synchronize Key-Value Payloads
```dart
// Flutter side:
await getIt<HomeWidgetService>().syncPayload(
  HomeWidgetPayload(
    title: 'CodeStore Status',
    message: 'All systems operational 🚀',
    status: 'Active',
  ),
);
```

* **iOS Native (`Widget.swift`)**:
  ```swift
  let title = WidgetBridge.string(forKey: "title", fallback: "CodeStore Status")
  let message = WidgetBridge.string(forKey: "message", fallback: "All systems operational")
  let status = WidgetBridge.string(forKey: "status", fallback: "Active")
  ```
* **Android Native (`AppStatusWidgetHomeWidget.kt`)**:
  ```kotlin
  val title = WidgetBridge.getString(context, "title", "CodeStore Status")
  val message = WidgetBridge.getString(context, "message", "All systems operational")
  val status = WidgetBridge.getString(context, "status", "Active")
  ```

### C. Listening to Widget Click Actions in Flutter
```dart
getIt<HomeWidgetService>().onActionTriggered.listen((action) {
  debugPrint('User tapped widget: ${action.actionId} | uri: ${action.uri}');
});
```

---

## Step 6: Verification

1. Verify Dart analysis and tests:
   ```bash
   flutter analyze
   flutter test
   ```
2. Verify iOS Widget Extension compilation:
   ```bash
   xcodebuild -workspace ios/Runner.xcworkspace -scheme <WidgetName>HomeWidget -configuration Debug -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator
   ```
3. Verify Full App Simulator Build:
   ```bash
   flutter build ios --simulator --debug
   ```
