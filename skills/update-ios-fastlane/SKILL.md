---
name: update-ios-fastlane
description: >
  Set up or update Fastlane for iOS to automate screenshots, beta deployment, and App Store releases, using App Store Connect API keys and match.
---

# update-ios-fastlane

Updates or initializes Fastlane for the iOS platform in a Flutter application, heavily based on best practices from working projects. This automates building IPAs, managing code signing with `match`, and authenticating securely via App Store Connect API keys.

## Prerequisites

- Ruby and Bundler installed.
- Apple Developer account credentials available.
- App Store Connect API keys generated (`APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, etc.).
- Fastlane Match repository configured for team code signing.

## Workflow

### Step 1: Initialize Fastlane

Navigate to the `ios` directory and initialize fastlane if it isn't already:

```bash
cd ios
bundle exec fastlane init
```

### Step 2: Configure Fastfile

Update `ios/fastlane/Fastfile` with lanes for your specific needs, such as building, code signing (match), and uploading to TestFlight. Use the robust template below:

```ruby
# frozen_string_literal: true

default_platform(:ios)

def repo_root
  File.expand_path("../..", __dir__)
end

def app_bundle_id
  "com.example.yourApp" # UPDATE THIS
end

def app_team_id
  "YOUR_TEAM_ID" # UPDATE THIS
end

def asc_api_key
  key_id = ENV["APP_STORE_CONNECT_KEY_ID"]
  issuer_id = ENV["APP_STORE_CONNECT_ISSUER_ID"]
  key_path = ENV["APP_STORE_CONNECT_KEY_PATH"]
  key_content = ENV["APP_STORE_CONNECT_KEY_CONTENT"]

  UI.user_error!("Set APP_STORE_CONNECT_KEY_ID and APP_STORE_CONNECT_ISSUER_ID") unless key_id && issuer_id

  if key_path && File.file?(File.expand_path(key_path))
    app_store_connect_api_key(
      key_id: key_id,
      issuer_id: issuer_id,
      key_filepath: File.expand_path(key_path)
    )
  elsif key_content
    app_store_connect_api_key(
      key_id: key_id,
      issuer_id: issuer_id,
      key_content: key_content,
      is_key_content_base64: ENV["APP_STORE_CONNECT_KEY_IS_BASE64"] == "1"
    )
  else
    UI.user_error!("Set APP_STORE_CONNECT_KEY_PATH (AuthKey_xxx.p8) or APP_STORE_CONNECT_KEY_CONTENT")
  end
end

def sync_match_for_ci
  return if ENV["MATCH_SKIP"] == "1"
  return unless ENV["MATCH_PASSWORD"]

  setup_ci if ENV["CI"]

  match(
    type: "appstore",
    readonly: true,
    app_identifier: [app_bundle_id],
    team_id: app_team_id
  )

  mapping = lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING]
  profile_name = mapping[app_bundle_id]
  UI.user_error!("match did not return a provisioning profile for #{app_bundle_id}") unless profile_name

  update_code_signing_settings(
    path: "Runner.xcodeproj",
    use_automatic_signing: false,
    targets: ["Runner"],
    build_configurations: ["Release", "Profile"],
    team_id: app_team_id,
    profile_name: profile_name,
    code_sign_identity: "Apple Distribution"
  )
end

platform :ios do
  desc "Build Flutter IPA and upload to TestFlight."
  lane :beta do
    api_key = asc_api_key
    sync_match_for_ci

    Dir.chdir(repo_root) do
      sh("flutter pub get")
      sh("flutter build ipa --release")
    end

    ipa = Dir.glob(File.join(repo_root, "build/ios/ipa/*.ipa")).first
    UI.user_error!("IPA not found under build/ios/ipa/") unless ipa

    upload_to_testflight(
      api_key: api_key,
      ipa: ipa,
      skip_waiting_for_build_processing: true
    )
  end
end
```

### Step 3: Run Fastlane

Run the lane to ensure everything works correctly:

```bash
cd ios
bundle exec fastlane beta
```
