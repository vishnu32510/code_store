---
name: update-github-actions
description: >
  Update or configure GitHub Actions workflows for continuous integration and continuous deployment (CI/CD) for a Flutter project.
---

# update-github-actions

Manages GitHub Action workflows for Flutter projects. It specifically handles CI routines like testing, formatting, and building APKs (e.g., `flutter_ci.yml`, `android_debug_apk.yml`).

## Prerequisites

- A GitHub repository.

## Workflow

### Step 1: Identify Workflows to Update

Look into `.github/workflows/` to find existing workflows. Common examples:
- `.github/workflows/flutter_ci.yml` (Testing & Linting)
- `.github/workflows/android_debug_apk.yml` (Build Debug APK)

### Step 2: Basic CI Workflow Update

To update standard CI (Formatting, Analysis, Testing), modify `.github/workflows/flutter_ci.yml`:

```yaml
name: Flutter CI

on:
  pull_request:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Create .env file
        run: cp .env.example .env

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Run static analysis
        run: flutter analyze

      - name: Run tests
        run: flutter test
```

### Step 3: Debug APK Workflow Update

To update Android debug builds, modify `.github/workflows/android_debug_apk.yml`:

```yaml
name: Build Android Debug APK

on:
  workflow_dispatch:

jobs:
  android_debug_apk:
    name: Build Android Debug APK
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main' || github.event_name == 'workflow_dispatch'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Create .env file
        run: cp .env.example .env

      - name: Install dependencies
        run: flutter pub get

      - name: Build debug APK
        run: flutter build apk --debug

      - name: Upload debug APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
          if-no-files-found: error
```

### Step 4: Verification

Ensure the updated YAML files are valid and commit them.

```bash
git add .github/workflows/
git commit -m "Update GitHub Actions CI/CD pipelines"
```
