---
name: change-name
description: >
  Rename a Flutter app's package name, bundle ID, Dart imports, and display names
  in one automated workflow.
---

# change-name

Renames a Flutter project end-to-end: native platform IDs (Android `applicationId`/`namespace`, iOS `PRODUCT_BUNDLE_IDENTIFIER`), Dart package imports, and human-readable display names.

## Prerequisites

The project must have `change_app_package_name` installed. If it is missing, add it by running:

```bash
flutter pub add --dev change_app_package_name
```
*(Alternatively, you can use `dart pub add dev:change_app_package_name`)*

## Parameters

Gather these from the user before proceeding:

| Parameter | Example | Description |
|-----------|---------|-------------|
| `OLD_NAME` | `code_store` | Current Dart package name (from `pubspec.yaml` `name:` field) |
| `OLD_DISPLAY_NAME` | `codestore` | Current display name in the native files |
| `OLD_PACKAGE_ID` | `com.nungu.codestore` | Current Android applicationId / iOS bundle identifier |
| `NEW_NAME` | `ringsizer` | New Dart package name (Note: avoid underscores `_` in new names) |
| `NEW_PACKAGE_ID` | `com.nungu.ringsizer` | New Android applicationId / iOS bundle identifier |
| `DISPLAY_NAME` | `Ring Sizer` | Human-readable app name for launcher icons |

## Workflow

### Step 1: Native Platform Rename (`change_app_package_name`)

```bash
dart run change_app_package_name:main <NEW_PACKAGE_ID>
```

This handles:
- Android: `applicationId`, `namespace` in `build.gradle.kts`
- Android: Kotlin/Java directory structure + `MainActivity` package declaration
- Android: `AndroidManifest.xml` package references
- iOS: `PRODUCT_BUNDLE_IDENTIFIER` in `project.pbxproj`

### Step 2: Dart Package Rename

```bash
# pubspec.yaml
sed -i '' "s/^name: \${OLD_NAME}$/name: \${NEW_NAME}/" pubspec.yaml

# All Dart imports in lib/ and test/
find lib test -name '*.dart' -exec sed -i '' "s|package:\${OLD_NAME}/|package:\${NEW_NAME}/|g" {} +
```

> **Linux note**: Remove the `''` after `-i` (macOS BSD sed requires it, GNU sed does not).

### Step 3: Display Names & Metadata

```bash
# Android label
sed -i '' "s/android:label=\"\${OLD_DISPLAY_NAME}\"/android:label=\"\${DISPLAY_NAME}\"/" android/app/src/main/AndroidManifest.xml

# iOS CFBundleName
sed -i '' "s/<string>\${OLD_DISPLAY_NAME}<\/string>/<string>\${DISPLAY_NAME}<\/string>/" ios/Runner/Info.plist

# Web
sed -i '' "s/\"name\": \"\${OLD_DISPLAY_NAME}\"/\"name\": \"\${DISPLAY_NAME}\"/" web/manifest.json
sed -i '' "s/\"short_name\": \"\${OLD_DISPLAY_NAME}\"/\"short_name\": \"\${DISPLAY_NAME}\"/" web/manifest.json
sed -i '' "s/content=\"\${OLD_DISPLAY_NAME}\"/content=\"\${DISPLAY_NAME}\"/" web/index.html
sed -i '' "s/<title>\${OLD_DISPLAY_NAME}<\/title>/<title>\${DISPLAY_NAME}<\/title>/" web/index.html

# Gradle / Fastlane comments (if old package ID present)
grep -rl "${OLD_PACKAGE_ID}" android/ | xargs sed -i '' "s/${OLD_PACKAGE_ID}/${NEW_PACKAGE_ID}/g" 2>/dev/null || true

# App Group ID in .env and iOS Entitlements
sed -i '' "s/group.${OLD_PACKAGE_ID}/group.${NEW_PACKAGE_ID}/g" .env .env.example 2>/dev/null || true
find ios -name '*.entitlements' -exec sed -i '' "s/group.${OLD_PACKAGE_ID}/group.${NEW_PACKAGE_ID}/g" {} + 2>/dev/null || true
find ios -name '*.swift' -exec sed -i '' "s/group.${OLD_PACKAGE_ID}/group.${NEW_PACKAGE_ID}/g" {} + 2>/dev/null || true
```

### Step 4: Clean Rebuild

```bash
flutter clean && flutter pub get
```

## Verification

Run this to ensure no stale references remain:

```bash
grep -r "\${OLD_NAME}" lib/ test/ pubspec.yaml
grep -r "\${OLD_DISPLAY_NAME}" android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist web/
```
