# code_store

Flutter app skeleton you can copy when starting a new project. It mirrors patterns from **plushie_yourself**: `lib/features/` (authentication, theme, home demo), `lib/core/` (DI, routes, services), **GetIt** for `ThemeBloc` and `IToastService`, global **navigator** / **scaffold messenger** keys, and **Firebase Auth** with email (continue flow), Google, and Apple.

## What is included

- **Features**: `authentication/` (BLoC + `FirebaseAuthenticationRepository`), `theme/` (ThemeBloc), `home/` (dashboard + flashlight), `flashlight/` (torch, strobe, SOS).
- **Core**: `core/di/injection.dart`, `core/config/global_keys.dart`, `core/config/routes.dart`, `core/services/` (HTTP helpers, toast, flashlight).
- **Env**: `flutter_dotenv` loads `.env` if present (see assets in `pubspec.yaml`).

**Auth:** The app opens straight to the dashboard. Login is not required on launch (auth BLoC still runs for optional sign-in from the profile tab).

## Prerequisites

- Flutter SDK matching `environment.sdk` in `pubspec.yaml`.
- A Firebase project with Auth enabled (Google / Apple / Email as you need). Regenerate options with [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

## Run locally

```bash
cd code_store
flutter pub get
flutter run
```

Ensure `lib/firebase_options.dart` matches your Firebase apps (or run `flutterfire configure`).

## Launcher icon

Replace `assets/icon/app_icon.png` with a 1024×1024 PNG, then regenerate platform icons:

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
```

Config lives in [`flutter_launcher_icons.yaml`](flutter_launcher_icons.yaml).

## Create a new app from this template

1. **Copy the tree**  
   Duplicate this folder or clone the repo and work from a new directory (for example `my_app`).

2. **Rename the Dart package**  
   - Set `name:` in `pubspec.yaml` to your package name (e.g. `my_app`).  
   - Replace imports: refactor `package:code_store/` → `package:my_app/` across `lib/` and tests (IDE refactor is safest).

3. **Firebase**  
   Run `flutterfire configure` for the new Firebase project and replace `lib/firebase_options.dart`. Update Android `applicationId`, iOS bundle identifier, and any OAuth client IDs as usual.

4. **Platform IDs**  
   Adjust Android (`android/app/build.gradle.kts`, namespace) and iOS/macOS bundle IDs in Xcode / project files so they match Firebase and store listings.

5. **Secrets**  
   Keep local keys in `.env` (listed under `flutter: assets:`). Do not commit real secrets; use your own ignore rules if you track `.env` locally.

6. **Optional: rename script**  
   See [`tool/new_from_template.sh`](tool/new_from_template.sh) for a minimal automated rename + `flutter pub get`.

### Mason (optional)

For repeated scaffolding, you can later wrap `lib/features` and `lib/core` in a [Mason](https://pub.dev/packages/mason) brick with variables for `project_name` and organization.

## Layout

```
lib/
  core/
    config/       # routes, global keys
    di/           # GetIt setup
    services/     # toast, HTTP, etc.
    utils/
  features/
    authentication/
    theme/
    home/
    flashlight/
  main.dart
```

## Analyze

```bash
dart analyze lib
```
