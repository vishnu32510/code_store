# Template Usage Guide

## 1. Setup a New App

1. **Rename Package & App IDs:**
   ```bash
   flutter pub run change_app_package_name:main com.yourcompany.newapp
   ```
2. **Setup Env Variables:**
   ```bash
   cp .env.example .env
   ```

---

## 2. Remove Firebase (If Not Needed)

1. **Delete from `pubspec.yaml`:**
   Remove the following dependencies:
   * `firebase_core`
   * `firebase_auth`
   * `cloud_firestore`
   * `google_sign_in`
   * `sign_in_with_apple`
2. **Clean `lib/main.dart`:**
   * Remove Firebase imports.
   * Remove `await Firebase.initializeApp(...)` from the `main()` function.
3. **Fetch clean dependencies:**
   ```bash
   flutter pub get
   ```

---

## 3. Configure Firebase (If Needed)

1. **Generate native credentials:**
   Create a project in the Firebase Console and run:
   ```bash
   flutterfire configure
   ```

---

## 4. Upgrade Flutter & Packages

1. **Update `pubspec.yaml`:**
   Set the desired Target SDK version:
   ```yaml
   environment:
     sdk: ^3.8.0
   ```
2. **Upgrade dependencies:**
   ```bash
   flutter pub upgrade --major-versions
   ```
3. **Clean cache & rebuild:**
   ```bash
   flutter clean
   flutter pub get
   ```

---

## 5. Network Requests (Dio)

The template utilizes **`dio`** for HTTP networking, registered via `GetIt` inside `HttpServices`.

* **Initialization & Timeouts:** Globally configured with a 20-second timeout in `lib/core/services/services.dart`.
* **Logging Interceptor:** Automatically prints incoming/outgoing request headers, response data, and network errors during development.
* **Error Handling:** Automatically maps `DioException` states (timeouts, socket errors, and bad HTTP responses) into a unified `ServiceError` enum.
* **Advanced Features:**
  * **Options & Custom Headers:** Pass custom `Options` to any standard request (`getMethod`, `postMethod`, etc.) to override defaults per request.
  * **Cancellation Support:** Pass a `CancelToken` to cancel any ongoing request dynamically.
  * **File Downloads:** Use `downloadFile` with a `onReceiveProgress` callback for downloading files with UI progress bars.
  * **File Uploads:** Use `uploadFile` with multipart `FormData` and `onSendProgress` for progress-tracked uploads.


