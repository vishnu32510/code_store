---
name: create-package
description: Scaffolds a new modular package under packages/, creates its interfaces, DI, barrel exports, unit tests, and matching setup skill.
---

# Create Package Skill

Use this skill whenever you need to scaffold, implement, and integrate a new modular Flutter package under `packages/` in the `code_store` monorepo.

---

## Complete Package Architecture Checklist

Every package in `packages/code_store_<name>` must adhere to the following architecture:

```text
packages/code_store_<name>/
├── pubspec.yaml                      # Lean dependencies, SDK constraints & lints
├── README.md                         # Usage instructions & API reference
├── lib/
│   ├── code_store_<name>.dart        # Barrel export (DI, models, services, widgets, re-exported 3rd party types)
│   └── src/
│       ├── di/
│       │   └── <name>_injection.dart  # setup<Name>DI({GetIt? locator, I<Name>Service? customService})
│       ├── models/                   # Immutable models (@immutable, toMap/fromMap, copyWith, toString)
│       ├── services/                 # Abstract interface (I<Name>Service) + Concrete implementation
│       ├── utils/                    # Platform guards (kIsWeb), isolates (@pragma('vm:entry-point')), helpers
│       └── widgets/                  # Optional UI widgets, dialogs, or bottom sheets
└── test/
    └── <name>_test.dart              # Model serialization, mock services, and DI registration unit tests
```

---

## Detailed Step-by-Step Execution Workflow

### Step 1: Create `pubspec.yaml`
Ensure standard SDK constraints, minimal dependencies, and lints:

```yaml
name: code_store_<name>
description: "Modular <feature_description> package for code_store."
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.13.1 <4.0.0'
  flutter: '>=3.47.1'

dependencies:
  flutter:
    sdk: flutter
  get_it: ^9.2.1
  meta: ^1.19.0
  # Only add required third-party plugins (e.g. local_auth, shared_preferences, etc.)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

---

### Step 2: Define Service Contract (`lib/src/services/i_<name>_service.dart`)
- Define an `abstract interface class I<Name>Service`.
- Use strongly-typed result models instead of raw maps or uncaught platform exceptions.
- Provide optional lifecycle hooks (`initialize({void Function(String routePath)? onNavigate, ...})`) if the service handles deep links, taps, or external events.

```dart
abstract interface class I<Name>Service {
  Future<bool> isAvailable();
  Future<<Name>Result> performAction();
  Future<void> initialize({void Function(String routePath)? onNavigate});
}
```

---

### Step 3: Implement Service with Platform Guards (`lib/src/services/<name>_service.dart`)
- Inject third-party dependencies into the constructor for effortless test mocking:
  ```dart
  class <Name>Service implements I<Name>Service {
    <Name>Service({PluginInstance? plugin})
        : _plugin = plugin ?? PluginInstance();

    final PluginInstance _plugin;
  ```
- **Cross-Platform Safety**: Always guard web and unsupported platforms with `kIsWeb` or try/catch blocks returning safe default result models (`<Name>Result.notSupported()`) rather than throwing unhandled exceptions.
- **Top-Level Isolate Handlers**: If background execution is required (alarms, messaging, audio), use `@pragma('vm:entry-point')` on top-level handler functions.

---

### Step 4: Create Dependency Injection (`lib/src/di/<name>_injection.dart`)
- Provide safe, idempotent DI registration:

```dart
import 'package:get_it/get_it.dart';
import '../services/<name>_service.dart';
import '../services/i_<name>_service.dart';

void setup<Name>DI({
  GetIt? locator,
  I<Name>Service? customService,
}) {
  final di = locator ?? GetIt.instance;

  if (customService != null) {
    if (!di.isRegistered<I<Name>Service>()) {
      di.registerSingleton<I<Name>Service>(customService);
    }
    return;
  }

  if (!di.isRegistered<I<Name>Service>()) {
    final service = <Name>Service();
    di.registerLazySingleton<I<Name>Service>(() => service);

    if (!di.isRegistered<<Name>Service>()) {
      di.registerLazySingleton<<Name>Service>(() => service);
    }
  }
}
```

---

### Step 5: Create Barrel Export (`lib/code_store_<name>.dart`)
Re-export:
1. Third-party package types that consuming code needs (so consumers don't need direct third-party imports).
2. DI entry point (`setup<Name>DI`).
3. Models.
4. Services (`I<Name>Service`, `<Name>Service`).
5. Widgets/Dialogs.

```dart
library;

// Re-export 3rd party types
export 'package:some_plugin/some_plugin.dart' show CommonType1, CommonType2;

// DI
export 'src/di/<name>_injection.dart';

// Models
export 'src/models/...';

// Services
export 'src/services/<name>_service.dart';
export 'src/services/i_<name>_service.dart';

// Widgets (if any)
export 'src/widgets/...';
```

---

### Step 6: Write Unit Tests (`test/<name>_test.dart`)
Every package **MUST** have unit tests covering:
1. **Model Serialization**: `toMap()`, `fromMap()`, `copyWith`, and status factories.
2. **DI Isolation**: Test `setup<Name>DI(locator: GetIt.asNewInstance(), customService: MockService())`.
3. **Mock Service**: Verify methods and streams return expected data.

---

### Step 7: Main App Integration

1. **Root `pubspec.yaml`**:
   ```yaml
   dependencies:
     code_store_<name>:
       path: packages/code_store_<name>
   ```

2. **Root DI (`lib/core/di/injection.dart`)**:
   - Add `import 'package:code_store_<name>/code_store_<name>.dart';`
   - Call `setup<Name>DI();` in `setupDI()`.
   - Call `await getIt<I<Name>Service>().initialize(...);` if async startup is required.

3. **App Navigation & Routes (Drawer-Only Integration Rule)**:
   - Register the route in `lib/core/config/routes.dart` (e.g., `AppRoutes.<name> = '/<name>'`).
   - Add the navigation tile into `AppDrawer` (`lib/features/home/widgets/app_drawer.dart`).
   - **CRITICAL RULE**: Do **NOT** modify or add feature rows into `DashboardScreen` (`dashboard_screen.dart`). Keep the dashboard clean and untouched; features are accessed exclusively via the `AppDrawer` and direct deep links.

---

### Step 8: Native Platform Configuration (If Applicable)

| Platform | File | Checklist Items |
| :--- | :--- | :--- |
| **iOS** | `ios/Runner/Info.plist` | Privacy descriptions (`NS*UsageDescription`), `UIBackgroundModes`, `URL Schemes` |
| **iOS** | `ios/Runner/AppDelegate.swift` | Delegate registration, background fetch triggers |
| **Android** | `android/app/src/main/AndroidManifest.xml` | `<uses-permission>`, `<service>`, `<receiver>`, `<meta-data>` |
| **Android** | `MainActivity.kt` | Switch to `FlutterFragmentActivity` if native modal dialogs/biometrics are used |
| **macOS** | `macos/Runner/*.entitlements` | App Sandbox permissions (network, camera, etc.) |
| **Web** | `web/index.html` | CDN scripts, service worker registrations, meta headers |

---

### Step 9: Companion Skill Generation
Create a matching skill file at `skills/setup-<name>/SKILL.md` containing:
- Purpose of the feature and package.
- Exact native configuration snippets for Android and iOS.
- DI and app initialization instructions.
- Verification steps.

---

### Step 10: Full Monorepo Quality & Build Verification
Execute the verification chain:

```bash
# 1. Test isolated package
cd packages/code_store_<name> && flutter test

# 2. Test entire workspace (all packages + app)
cd ../.. && flutter test

# 3. Analyze workspace
flutter analyze

# 4. Dry-run native compilation
flutter build ios --simulator --no-codesign
flutter build web
```
