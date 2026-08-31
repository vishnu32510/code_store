typedef OneTapCallback = void Function(String idToken);

/// Cross-platform stub for Google One Tap.
class GoogleOneTapHelper {
  /// Initializes Google One Tap (only active on Web).
  static void initialize({
    required String clientId,
    required OneTapCallback onCredential,
    bool autoSelect = false,
  }) {}

  /// Displays the Google One Tap prompt in the top-right corner on Web.
  static void prompt() {}

  /// Cancels the active One Tap prompt.
  static void cancel() {}
}
