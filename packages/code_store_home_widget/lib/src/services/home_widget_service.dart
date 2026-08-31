import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../models/home_widget_payload.dart';
import '../models/widget_action.dart';

/// Central generalized service for managing Home Screen widgets across iOS (WidgetKit) and Android (AppWidgets/Glance).
class HomeWidgetService {
  HomeWidgetService({
    String? appGroupId,
    String? defaultAndroidName,
    String? defaultIOSName,
  }) {
    _appGroupId = appGroupId;
    _defaultAndroidName = defaultAndroidName;
    _defaultIOSName = defaultIOSName;
  }

  String? _appGroupId;
  String? _defaultAndroidName;
  String? _defaultIOSName;
  bool _initialized = false;

  /// Whether the current platform supports native Home Screen Widgets (Android & iOS).
  static bool get isPlatformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Throws an [UnsupportedError] if called on a platform that does not support home widgets.
  void _ensurePlatformSupported() {
    if (!isPlatformSupported) {
      throw UnsupportedError(
        'Home widgets are only supported on Android and iOS.',
      );
    }
  }

  /// Whether the service has been initialized with platform configuration.
  bool get isInitialized => _initialized;

  /// Current configured App Group ID (used by iOS WidgetKit & shared UserDefaults).
  String? get appGroupId => _appGroupId;

  /// Stream of raw URIs triggered when a user taps a widget on their home screen.
  Stream<Uri?> get widgetClickedStream =>
      isPlatformSupported ? HomeWidget.widgetClicked : const Stream.empty();

  /// Stream of parsed [WidgetAction] events triggered when a user taps a widget.
  Stream<WidgetAction> get onActionTriggered => isPlatformSupported
      ? HomeWidget.widgetClicked
            .where((uri) => uri != null)
            .map((uri) => WidgetAction.fromUri(uri!))
      : const Stream.empty();

  /// Initializes the Home Widget service with optional app group and widget identifiers.
  Future<void> initialize({
    String? appGroupId,
    String? defaultAndroidName,
    String? defaultIOSName,
  }) async {
    if (!isPlatformSupported) return;

    if (appGroupId != null) {
      _appGroupId = appGroupId;
      await HomeWidget.setAppGroupId(appGroupId);
    }
    if (defaultAndroidName != null) {
      _defaultAndroidName = defaultAndroidName;
    }
    if (defaultIOSName != null) {
      _defaultIOSName = defaultIOSName;
    }
    _initialized = true;
  }

  /// Checks if the app was launched from a home screen widget and returns the parsed [WidgetAction].
  Future<WidgetAction?> getInitialAction() async {
    if (!isPlatformSupported) return null;
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri == null) return null;
    return WidgetAction.fromUri(uri);
  }

  /// Retrieves the raw URI that launched the app if opened from a widget.
  Future<Uri?> getInitiallyLaunchedUri() async {
    if (!isPlatformSupported) return null;
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  /// ---------------------------------------------------------------------------
  /// GENERALIZED SYNCHRONIZATION PRIMITIVES
  /// ---------------------------------------------------------------------------

  /// 1. Synchronize any structured Dart model to native widget storage as JSON.
  ///
  /// The native Swift/Kotlin side can decode it directly with `WidgetBridge.decode(MyModel.self, forKey: key)`.
  Future<bool> syncModel<T>({
    required String key,
    required T model,
    Map<String, dynamic> Function(T)? toJson,
    String? actionUri,
    bool update = true,
    String? androidName,
    String? iOSName,
  }) async {
    final Map<String, dynamic> map = toJson != null
        ? toJson(model)
        : (model as dynamic).toJson();
    final jsonStr = jsonEncode(map);
    final saved = await saveData<String>(key, jsonStr);

    if (actionUri != null) {
      await saveData<String>('${key}_action_uri', actionUri);
    }

    if (update && saved) {
      await updateWidget(androidName: androidName, iOSName: iOSName);
    }
    return saved;
  }

  /// Reads and deserializes a structured JSON model from shared widget storage.
  Future<T?> getModel<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final jsonStr = await getData<String>(key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// 2. Synchronize a batch Map of key-value pairs to shared widget storage.
  Future<bool> syncMap(
    Map<String, dynamic> data, {
    bool update = true,
    String? androidName,
    String? iOSName,
  }) async {
    for (final entry in data.entries) {
      await saveData(entry.key, entry.value);
    }
    if (update) {
      return await updateWidget(androidName: androidName, iOSName: iOSName);
    }
    return true;
  }

  /// 3. Render any Flutter [widget] off-screen to an image and synchronize to native widgets.
  Future<String?> renderAndSync({
    required Widget widget,
    String key = 'home_widget_image',
    Size logicalSize = const Size(320, 160),
    double pixelRatio = 3.0,
    String? actionUri,
    bool update = true,
    String? androidName,
    String? iOSName,
  }) async {
    final path = await renderFlutterWidget(
      widget: widget,
      key: key,
      logicalSize: logicalSize,
      pixelRatio: pixelRatio,
    );

    if (actionUri != null) {
      await saveData<String>('${key}_action_uri', actionUri);
    }

    if (update && path != null) {
      await updateWidget(androidName: androidName, iOSName: iOSName);
    }
    return path;
  }

  /// 4. Saves a single typed value to shared storage.
  Future<bool> saveData<T>(String key, T value) async {
    _ensurePlatformSupported();
    if (value is String) {
      return await HomeWidget.saveWidgetData<String>(key, value) ?? false;
    } else if (value is int) {
      return await HomeWidget.saveWidgetData<int>(key, value) ?? false;
    } else if (value is bool) {
      return await HomeWidget.saveWidgetData<bool>(key, value) ?? false;
    } else if (value is double) {
      return await HomeWidget.saveWidgetData<double>(key, value) ?? false;
    }
    return await HomeWidget.saveWidgetData<String>(key, value.toString()) ??
        false;
  }

  /// Reads a value from shared widget storage.
  Future<T?> getData<T>(String key, {T? defaultValue}) async {
    _ensurePlatformSupported();
    return await HomeWidget.getWidgetData<T>(key, defaultValue: defaultValue);
  }

  /// Persists a [HomeWidgetPayload] into shared storage and immediately requests a native widget refresh.
  Future<bool> syncPayload(
    HomeWidgetPayload payload, {
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async {
    _ensurePlatformSupported();
    final map = payload.toMap();
    for (final entry in map.entries) {
      await saveData(entry.key, entry.value);
    }
    return await updateWidget(
      androidName: androidName ?? _defaultAndroidName,
      iOSName: iOSName ?? _defaultIOSName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }

  /// Triggers the native platform to refresh the specified widget.
  Future<bool> updateWidget({
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async {
    _ensurePlatformSupported();
    final targetAndroid = androidName ?? _defaultAndroidName;
    final targetIOS = iOSName ?? _defaultIOSName;

    return await HomeWidget.updateWidget(
          androidName: targetAndroid,
          iOSName: targetIOS,
          qualifiedAndroidName: qualifiedAndroidName,
        ) ??
        false;
  }

  /// Renders a Flutter [widget] off-screen to an image file and saves the image path to shared storage under [key].
  Future<String?> renderFlutterWidget({
    required Widget widget,
    required String key,
    Size logicalSize = const Size(320, 160),
    double pixelRatio = 3.0,
  }) async {
    _ensurePlatformSupported();
    return await HomeWidget.renderFlutterWidget(
      widget,
      key: key,
      logicalSize: logicalSize,
      pixelRatio: pixelRatio,
    );
  }

  /// Registers an interactive background callback (for interactive widgets on iOS 17+ and Android).
  Future<bool> registerInteractivityCallback(
    FutureOr<void> Function(Uri?) callback,
  ) async {
    _ensurePlatformSupported();
    return await HomeWidget.registerInteractivityCallback(callback) ?? false;
  }
}
