/// Represents an action or deep link triggered when a user taps a home screen widget.
class WidgetAction {
  WidgetAction({
    required this.uri,
    this.actionId,
    this.parameters = const <String, String>{},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// The raw URI received from the widget tap.
  final Uri uri;

  /// Optional action identifier (e.g. from query param `action` or host).
  final String? actionId;

  /// Query parameters attached to the URI.
  final Map<String, String> parameters;

  /// Timestamp when the action was captured.
  final DateTime timestamp;

  /// Normalizes and returns a clean, routable path from the URI (e.g. `/notifications`, `/home-widget`).
  String get routePath {
    final path = uri.path.trim();
    if (path.isNotEmpty && path != '/') {
      return path.startsWith('/') ? path : '/$path';
    }
    final host = uri.host.trim();
    if (host.isNotEmpty) {
      return '/$host';
    }
    return '/';
  }

  /// Creates a [WidgetAction] from a raw [Uri].
  factory WidgetAction.fromUri(Uri uri) {
    final actionId = uri.queryParameters['action'] ?? uri.host;
    return WidgetAction(
      uri: uri,
      actionId: actionId.isNotEmpty ? actionId : null,
      parameters: uri.queryParameters,
    );
  }

  @override
  String toString() =>
      'WidgetAction(uri: $uri, actionId: $actionId, params: $parameters)';
}
