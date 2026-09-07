---
name: setup-dynamic-island
description: Configures iOS Dynamic Island Live Activity with sprite animation looping, App Group sharing, and native SwiftUI Widget Extension setup.
---

# Setup Dynamic Island Skill

This skill configures the `code_store_dynamic_island` package for iOS Dynamic Island Live Activities with two modes: simple status display and sprite-frame animation looping (Handy-style).

## Architecture

```
[Flutter Core App]
     │ (Processes sprite sheet into PNG frames via `image` package)
     ▼
[App Group Shared Container]
     │ (Frames saved as {name}_{index}.png)
     ▼
[Native Swift Widget Extension]
     │ (SwiftUI TimelineView renders frame sequence)
     ▼
[Dynamic Island Loop]
```

## Instructions for the Agent

When triggered, execute the following steps:

### Step 1: Verify Package Dependency
- Ensure `code_store_dynamic_island` is declared in root `pubspec.yaml`.

### Step 2: Verify Dependency Injection
- Check `lib/core/di/injection.dart`.
- Ensure `setupDynamicIslandDI(appGroupId: AppConstants.appGroupId)` is called in `setupDI()`.

### Step 3: Verify UI & Routing
- Route `AppRoutes.dynamicIsland = '/dynamic-island'` points to `DynamicIslandScreen` in `lib/core/config/routes.dart`.
- Drawer item present in `lib/features/home/widgets/app_drawer.dart`.
- `DashboardScreen` remains untouched (Drawer-only rule).

### Step 4: Native iOS Configuration (Xcode Manual Steps)

> **These steps MUST be performed manually in Xcode:**

1. **Add Widget Extension Target**:
   - Open `ios/Runner.xcworkspace` in Xcode.
   - File → New → Target → Widget Extension.
   - Product Name: `DynamicIslandExtension`.
   - Bundle Identifier: `com.nungu.codestore.DynamicIslandExtension`.
   - Check "Include Live Activity".

2. **Copy Swift Source Files**:
   - The following files exist in `ios/DynamicIslandExtension/`:
     - `IslandAnimationAttributes.swift`
     - `DynamicIslandWidget.swift`
     - `DynamicIslandExtensionBundle.swift`
     - `DynamicIslandExtension.entitlements`
     - `Info.plist`
   - Add them to the new target in Xcode.

3. **Enable App Groups**:
   - Under Signing & Capabilities for the `DynamicIslandExtension` target.
   - Add App Group: `group.com.nungu.codestore`.

4. **Verify Info.plist**:
   - `NSSupportsLiveActivities: YES` must be present in both:
     - `ios/Runner/Info.plist` (main app)
     - `ios/DynamicIslandExtension/Info.plist` (extension)

### Step 5: Sprite Sheet Preparation
- Sprite sheets must be grid-based PNGs.
- Each frame should be ≤80×80px after slicing.
- Recommended: 10 FPS, 4–12 frames per animation.
- The `SpriteSlicer` utility handles auto-cropping and resizing.

### Step 6: Completion & Verification
- Run `flutter analyze` and `flutter test` across all packages.
- Run `flutter build ios --simulator --no-codesign` to verify compilation.
