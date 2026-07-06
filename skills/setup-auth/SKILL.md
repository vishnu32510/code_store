---
name: setup-auth
description: Configures Google Sign-In and Apple Sign-In by updating Info.plist, AndroidManifest.xml, and extracting SHA fingerprints from debug.keystore.
---

# Setup Auth Skill

This skill configures social authentication methods (Google Sign-In, Apple Sign-In) for a Flutter project configured with Firebase.

## Instructions for the Agent

When triggered, you must perform the following steps:

1. **Extract Client IDs**:
   - Read `lib/firebase_options.dart`.
   - Extract the `iosClientId` (e.g. `12345-abcde.apps.googleusercontent.com`).
   - Compute the reversed client ID (e.g. `com.googleusercontent.apps.12345-abcde`).

2. **Update iOS `Info.plist`**:
   - Use the `multi_replace_file_content` or `replace_file_content` tool to update `ios/Runner/Info.plist`.
   - Update `GIDClientID` with the `iosClientId`.
   - Update `CFBundleURLSchemes` with the reversed client ID.
   - Example configuration for reference:
     ```xml
     <key>GIDClientID</key>
     <string>YOUR_IOS_CLIENT_ID</string>
     <key>CFBundleURLTypes</key>
     <array>
       <dict>
         <key>CFBundleTypeRole</key>
         <string>Editor</string>
         <key>CFBundleURLSchemes</key>
         <array>
           <string>YOUR_REVERSED_CLIENT_ID</string>
         </array>
       </dict>
     </array>
     ```

3. **Verify Android `AndroidManifest.xml`**:
   - View `android/app/src/main/AndroidManifest.xml`.
   - Verify that the `INTERNET` permission is present: `<uses-permission android:name="android.permission.INTERNET"/>`.
   - Generally, no specific Google Sign-In keys are required in the Android manifest if using `firebase_options.dart`.

4. **Extract SHA Fingerprints**:
   - Run the following command to extract the debug keystore fingerprints:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Parse the output to find the **SHA-1** and **SHA-256** fingerprints.

5. **Report to User**:
   - Output the SHA-1 and SHA-256 fingerprints to the user clearly so they can add them to the Firebase Console.
   - Confirm that the `Info.plist` and `AndroidManifest.xml` have been updated/verified successfully.
