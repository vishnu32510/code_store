import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';

typedef OneTapCallback = void Function(String idToken);

@JS('window')
external JSObject get _window;

/// Web implementation of Google One Tap via Google Identity Services (GIS).
class GoogleOneTapHelper {
  /// Initializes Google One Tap on web.
  static void initialize({
    required String clientId,
    required OneTapCallback onCredential,
    bool autoSelect = false,
  }) {
    try {
      final google = _window.getProperty('google'.toJS);
      if (google == null || google.isUndefined) return;
      final accounts = (google as JSObject).getProperty('accounts'.toJS);
      if (accounts == null || accounts.isUndefined) return;
      final id = (accounts as JSObject).getProperty('id'.toJS);
      if (id == null || id.isUndefined) return;

      final options = JSObject();
      options.setProperty('client_id'.toJS, clientId.toJS);
      options.setProperty('auto_select'.toJS, autoSelect.toJS);
      options.setProperty('cancel_on_tap_outside'.toJS, false.toJS);

      final jsCallback = ((JSObject response) {
        final cred = response.getProperty('credential'.toJS);
        if (cred != null && !cred.isUndefined) {
          final idToken = (cred as JSString).toDart;
          onCredential(idToken);
        }
      }).toJS;

      options.setProperty('callback'.toJS, jsCallback);

      (id as JSObject).callMethod('initialize'.toJS, options);
    } catch (e) {
      debugPrint('Google One Tap init error: $e');
    }
  }

  /// Displays the Google One Tap prompt in the top-right corner on Web.
  static void prompt() {
    try {
      final google = _window.getProperty('google'.toJS);
      if (google == null || google.isUndefined) return;
      final accounts = (google as JSObject).getProperty('accounts'.toJS);
      if (accounts == null || accounts.isUndefined) return;
      final id = (accounts as JSObject).getProperty('id'.toJS);
      if (id == null || id.isUndefined) return;

      (id as JSObject).callMethod('prompt'.toJS);
    } catch (e) {
      debugPrint('Google One Tap prompt error: $e');
    }
  }

  /// Cancels the active One Tap prompt.
  static void cancel() {
    try {
      final google = _window.getProperty('google'.toJS);
      if (google == null || google.isUndefined) return;
      final accounts = (google as JSObject).getProperty('accounts'.toJS);
      if (accounts == null || accounts.isUndefined) return;
      final id = (accounts as JSObject).getProperty('id'.toJS);
      if (id == null || id.isUndefined) return;

      (id as JSObject).callMethod('cancel'.toJS);
    } catch (e) {
      debugPrint('Google One Tap cancel error: $e');
    }
  }
}
