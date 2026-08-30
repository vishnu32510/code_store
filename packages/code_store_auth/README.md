# `code_store_auth`

Modular Firebase Authentication package supporting Email/Password, Google Sign-In, and Apple Sign-In with BLoC architecture, persistent user streams, and DI injection.

---

## 📱 Required Permissions & Native Setup

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)

1. **Network Permission**:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```
2. **SHA-1 Fingerprint**:
   * For Google Sign-In, extract your debug and release keystore SHA-1:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   * Add this SHA-1 into your project settings in the Firebase Console.

---

### 🍎 iOS (`ios/Runner/Info.plist`)

1. **Google Sign-In URL Schemes & Client ID**:
   Read `iosClientId` from `lib/firebase_options.dart` and add to `ios/Runner/Info.plist`:

   ```xml
   <key>GIDClientID</key>
   <string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <!-- Reversed Client ID -->
               <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

2. **Apple Sign-In Capability**:
   * In Xcode, select `Runner` target → **Signing & Capabilities** → Click `+ Capability` → Add **Sign In with Apple**.

---

## 🚀 Quick Start
```dart
// DI registration
setupAuthDI();

// Listen to Auth State
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) { ... }
);
```
