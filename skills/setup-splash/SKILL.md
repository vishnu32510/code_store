---
name: setup-splash
description: Configures native OS splash screens (Android launch_background.xml, Android 12 Splash API, iOS LaunchScreen.storyboard), logo animation styles, optional footer branding, and entrance audio chimes for code_store_splash.
---

# Setup Splash Screen Skill

Use this skill whenever you need to configure or customize native and animated splash screens for a Flutter app using `code_store_splash`.

---

## 1. Package Installation

Ensure `code_store_splash` is listed in your `pubspec.yaml`:

```yaml
dependencies:
  code_store_splash:
    path: packages/code_store_splash
```

---

## 2. Dependency Injection Registration

In your app DI setup (e.g. `lib/core/di/injection.dart`):

```dart
import 'package:code_store_splash/code_store_splash.dart';

void setupDI() {
  // Registers ISplashService into GetIt
  setupSplashDI();
}
```

---

## 3. Preserving Native Splash in `main()`

In `lib/main.dart`, preserve the native splash window before Flutter begins rendering:

```dart
import 'package:code_store_splash/code_store_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hold OS native launch screen
  await getIt<ISplashService>().preserve();
  
  // Initialize other services...
  runApp(const MyApp());
}
```

---

## 4. Native Platform Configuration (Android & iOS)

Create `flutter_native_splash.yaml` in the project root:

```yaml
flutter_native_splash:
  color: "#ffffff"
  color_dark: "#121212"
  image: assets/icon/app_icon.png
  image_dark: assets/icon/app_icon.png
  branding: assets/icon/branding.png # Optional footer logo
  branding_dark: assets/icon/branding.png
  android_12:
    image: assets/icon/app_icon.png
    icon_background_color: "#ffffff"
    branding: assets/icon/branding.png
  android: true
  ios: true
  web: true
```

Generate the native XML drawables and iOS storyboard:

```bash
dart run flutter_native_splash:create
```

---

## 5. Flutter Splash Transition Widget (`NativeSplashView`)

Render `NativeSplashView` during app startup or as an initial route:

```dart
NativeSplashView(
  config: SplashConfig(
    logoAsset: 'assets/icon/app_icon.png',
    // Choose between static (SplashAnimationType.none) or animated:
    animationType: SplashAnimationType.scale,
    animationDuration: const Duration(milliseconds: 1200),
    stayDuration: const Duration(milliseconds: 1800),
    backgroundColor: Colors.white,
    darkBackgroundColor: const Color(0xFF121212),
    // Optional native-aligned footer branding:
    footerLogoAsset: 'assets/icon/branding.png',
    footerText: 'Powered by CodeStore',
    footerLogoHeight: 36,
    // Optional audio chime / tune:
    audioConfig: const SplashAudioConfig(
      assetPath: 'assets/audio/splash_chime.wav',
      volume: 0.8,
    ),
    onInit: () async {
      // Async initialization (fetching user, preloading caches)
      await prefetchAllData();
    },
    nextRoute: '/home',
  ),
);
```

---

## 6. Verification Steps

1. **Unit & Widget Tests**:
   ```bash
   flutter test packages/code_store_splash
   flutter test test/features/splash_preview_screen_test.dart
   ```
2. **Static Analysis**:
   ```bash
   dart analyze packages/code_store_splash lib test
   ```
3. **Interactive Showcase**:
   Open the app drawer $\to$ **Native Splash Screen** (`/splash`) to test live animations, footer branding, and audio playback.
