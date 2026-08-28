import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import '../models/home_widget_payload.dart';

/// Central service for managing Home Screen widgets across iOS (WidgetKit) and Android (AppWidgets).
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

  /// Whether the service has been initialized with platform configuration.
  bool get isInitialized => _initialized;

  /// Current configured App Group ID (used by iOS WidgetKit & shared UserDefaults).
  String? get appGroupId => _appGroupId;

  /// Stream of URIs triggered when a user taps a widget on their home screen.
  Stream<Uri?> get widgetClickedStream => HomeWidget.widgetClicked;

  /// Initializes the Home Widget service with optional app group and widget identifiers.
  Future<void> initialize({
    String? appGroupId,
    String? defaultAndroidName,
    String? defaultIOSName,
  }) async {
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

  /// Retrieves the URI that launched the app if it was opened from a home screen widget.
  Future<Uri?> getInitiallyLaunchedUri() async {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  /// Saves a single key-value pair to shared widget storage.
  Future<bool> saveData<T>(String key, T value) async {
    if (value is String) {
      return await HomeWidget.saveWidgetData<String>(key, value) ?? false;
    } else if (value is int) {
      return await HomeWidget.saveWidgetData<int>(key, value) ?? false;
    } else if (value is bool) {
      return await HomeWidget.saveWidgetData<bool>(key, value) ?? false;
    } else if (value is double) {
      return await HomeWidget.saveWidgetData<double>(key, value) ?? false;
    }
    // Fallback as String
    return await HomeWidget.saveWidgetData<String>(key, value.toString()) ?? false;
  }

  /// Reads a value from shared widget storage.
  Future<T?> getData<T>(String key, {T? defaultValue}) async {
    return await HomeWidget.getWidgetData<T>(key, defaultValue: defaultValue);
  }

  /// Persists a [HomeWidgetPayload] into shared storage and immediately requests a native widget refresh.
  Future<bool> syncPayload(
    HomeWidgetPayload payload, {
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async {
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
  ///
  /// The native widget (iOS SwiftUI `Image` or Android `ImageView`) can then load this generated image directly.
  Future<String?> renderFlutterWidget({
    required Widget widget,
    required String key,
    Size logicalSize = const Size(320, 160),
    double pixelRatio = 3.0,
  }) async {
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
    return await HomeWidget.registerInteractivityCallback(callback) ?? false;
  }
}
