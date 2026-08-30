---
name: update-github-actions
description: >
  Update or configure GitHub Actions workflows for continuous integration and continuous deployment (CI/CD) for a Flutter project.
---

# update-github-actions

Manages GitHub Action workflows for Flutter projects. It handles multiplatform CI/CD pipelines including linting/testing, Android debug APKs, Firebase Hosting web deployments, and iOS/Android Fastlane store releases.

## Available Workflows (`.github/workflows/`)

1. **`flutter_ci.yml`**: Common CI (Testing, Static Analysis, Formatting check, and Web release build verification). Triggers on Pull Requests, Push to `main`, and manual dispatch.
2. **`android_debug_apk.yml`**: Builds and uploads Android Debug APK artifact on `workflow_dispatch`.
3. **`web_deploy_prod.yml`**: Deploys the Flutter Web build to Firebase Hosting (live channel) on `workflow_dispatch`.
4. **`web_deploy_preview.yml`**: Deploys a preview channel URL on `workflow_dispatch` or PRs.
5. **`android_store_release.yml`**: Fastlane release to Google Play Console (Internal / Production) with keystore signing.
6. **`ios_store_release.yml`**: Fastlane release to TestFlight or App Store using App Store Connect API keys and Match certificates.

## GitHub Repository Secrets Cheat Sheet

| Secret Name | Workflow | Description |
| :--- | :--- | :--- |
| `FIREBASE_SERVICE_ACCOUNT_CODE_STORE` | Web Hosting | Firebase Service Account JSON for hosting deployments |
| `ANDROID_UPLOAD_KEYSTORE_B64` | Android Fastlane | Base64-encoded `upload-keystore.jks` |
| `ANDROID_STORE_PASSWORD` | Android Fastlane | Keystore store password |
| `ANDROID_KEY_PASSWORD` | Android Fastlane | Keystore key password |
| `ANDROID_KEY_ALIAS` | Android Fastlane | Keystore key alias |
| `PLAY_SERVICE_ACCOUNT_JSON_B64` | Android Fastlane | Base64-encoded Google Play API service account JSON |
| `APP_STORE_CONNECT_KEY_ID` | iOS Fastlane | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | iOS Fastlane | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_KEY_CONTENT` | iOS Fastlane | Base64-encoded `.p8` AuthKey file |
| `MATCH_GIT_URL` | iOS Fastlane | Git repo URL holding encrypted certificates |
| `MATCH_PASSWORD` | iOS Fastlane | Encryption passphrase for fastlane match |
