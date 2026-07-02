---
name: update-android-fastlane
description: >
  Set up or update Fastlane for Android to automate Play Store releases and beta distribution, using advanced Ruby scripting for robust CI.
---

# update-android-fastlane

Updates or initializes Fastlane for the Android platform in a Flutter application, heavily based on best practices from working projects. This handles building the App Bundle and securely authenticating with the Play Store using a JSON service account key.

## Prerequisites

- Ruby and Bundler installed.
- Google Play Console API access configured (JSON key file).
- `PLAY_SERVICE_ACCOUNT_JSON_PATH` environment variable set.

## Workflow

### Step 1: Initialize Fastlane

Navigate to the `android` directory and initialize fastlane:

```bash
cd android
bundle exec fastlane init
```

### Step 2: Configure Fastfile

Update `android/fastlane/Fastfile` with lanes for building the app bundle and uploading it to the Play Store. Use the robust template below:

```ruby
# frozen_string_literal: true

default_platform(:android)

def repo_root
  File.expand_path("../..", __dir__)
end

def play_json_key
  path = ENV["PLAY_SERVICE_ACCOUNT_JSON_PATH"]
  UI.user_error!("Set PLAY_SERVICE_ACCOUNT_JSON_PATH to your Play Console API JSON key file") unless path
  File.expand_path(path)
end

def release_aab
  File.join(repo_root, "build/app/outputs/bundle/release/app-release.aab")
end

platform :android do
  desc "Build release AAB and upload to Internal testing track."
  lane :internal do
    Dir.chdir(repo_root) do
      sh("flutter pub get")
      sh("flutter build appbundle --release")
    end

    UI.user_error!("AAB not found — configure release signing in android/app/build.gradle.kts") unless File.file?(release_aab)

    upload_to_play_store(
      track: "internal",
      aab: release_aab,
      json_key: play_json_key,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: false
    )
  end

  desc "Upload the same AAB to Production (rolled out gradually)."
  lane :production do
    Dir.chdir(repo_root) do
      sh("flutter pub get")
      sh("flutter build appbundle --release")
    end

    UI.user_error!("AAB not found — configure release signing in android/app/build.gradle.kts") unless File.file?(release_aab)

    upload_to_play_store(
      track: "production",
      rollout: "0.1",
      aab: release_aab,
      json_key: play_json_key,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: false
    )
  end
end
```

### Step 3: Run Fastlane

Execute the lane to verify the deployment pipeline:

```bash
cd android
bundle exec fastlane internal
```
