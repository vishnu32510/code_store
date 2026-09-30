# code_store_splash

A pluggable native and animated splash screen package for Flutter with:
- **Zero-Flicker Native Transition**: Seamless hand-off from native OS launch screen (Android/iOS) to Flutter view.
- **Animated or Static Logo**: Choose between static logo or entrance animations (`scale`, `fade`, `pulse`, `shimmer`, `bounce`, `flip`, `custom`).
- **Optional Native Footer / Branding Logo**: Coordinated bottom branding image and text matching native Android 12 branding / iOS layout.
- **Audio Chime & Tunes**: Play an entrance chime or jingle during logo animation with configurable volume and delay.
- **Dependency Injection**: Pre-wired for `GetIt` with mockable interfaces.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  code_store_splash:
    path: packages/code_store_splash
```

---

## Quick Start

### 1. Register DI (`injection.dart`)

```dart
import 'package:code_store_splash/code_store_splash.dart';

void setupDI() {
  setupSplashDI();
}
```

### 2. Preserve Native Splash in `main()`

```dart
import 'package:code_store_splash/code_store_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep native splash visible until Flutter renders
  await getIt<ISplashService>().preserve();
  
  runApp(const MyApp());
}
```

### 3. Add `NativeSplashView`

```dart
NativeSplashView(
  config: SplashConfig(
    logoAsset: 'assets/icon/app_icon.png',
    animationType: SplashAnimationType.scale,
    animationDuration: const Duration(milliseconds: 1200),
    stayDuration: const Duration(milliseconds: 1800),
    backgroundColor: Colors.white,
    darkBackgroundColor: Color(0xFF121212),
    // Optional Footer Logo:
    footerLogoAsset: 'assets/icon/branding.png',
    footerText: 'Powered by CodeStore',
    // Optional Audio Chime:
    audioConfig: const SplashAudioConfig(
      assetPath: 'assets/audio/splash_chime.wav',
      volume: 0.8,
    ),
    onInit: () async {
      await loadUserData();
    },
    nextRoute: '/home',
  ),
);
```

---

## Native Splash Configuration (Android & iOS)

### Quickest Way: Package Executable CLI
Run the package executable directly from your project terminal to generate configuration and compile native drawables/storyboards in one step:

```bash
dart run code_store_splash:create
```

Options:
```bash
dart run code_store_splash:create --color "#121212" --logo "assets/icon/app_logo.png" --branding "assets/icon/branding.png"
```

### Direct YAML Generation
You can also generate the YAML directly from your `SplashConfig`:
```dart
final yaml = NativeSplashConfigHelper.fromConfig(mySplashConfig);
```

Or write `flutter_native_splash.yaml` in the project root:

```yaml
flutter_native_splash:
  color: "#121212"
  color_dark: "#121212"
  image: assets/icon/app_logo.png
  image_dark: assets/icon/app_logo.png
  branding: assets/icon/branding.png
  branding_dark: assets/icon/branding.png
  android_12:
    image: assets/icon/app_logo.png
    icon_background_color: "#121212"
    branding: assets/icon/branding.png
  android: true
  ios: true
  web: false
```

Then compile:

```bash
dart run flutter_native_splash:create
```

