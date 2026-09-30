import 'package:meta/meta.dart';

/// Result status emitted upon completion of the splash transition.
@immutable
class SplashResult {
  const SplashResult({
    required this.isSuccess,
    required this.duration,
    this.error,
    this.completedAt,
  });

  /// Whether the splash displayed and completed without unhandled exceptions.
  final bool isSuccess;

  /// Total elapsed duration spent on the splash screen.
  final Duration duration;

  /// Error message if initialization or audio playback failed.
  final String? error;

  /// Timestamp when the splash finished.
  final DateTime? completedAt;

  factory SplashResult.success(Duration duration) {
    return SplashResult(
      isSuccess: true,
      duration: duration,
      completedAt: DateTime.now(),
    );
  }

  factory SplashResult.failure(String error, Duration duration) {
    return SplashResult(
      isSuccess: false,
      duration: duration,
      error: error,
      completedAt: DateTime.now(),
    );
  }

  SplashResult copyWith({
    bool? isSuccess,
    Duration? duration,
    String? error,
    DateTime? completedAt,
  }) {
    return SplashResult(
      isSuccess: isSuccess ?? this.isSuccess,
      duration: duration ?? this.duration,
      error: error ?? this.error,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'durationMs': duration.inMilliseconds,
      'error': error,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SplashResult.fromMap(Map<String, dynamic> map) {
    return SplashResult(
      isSuccess: map['isSuccess'] as bool? ?? false,
      duration: Duration(milliseconds: map['durationMs'] as int? ?? 0),
      error: map['error'] as String?,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'SplashResult(isSuccess: $isSuccess, duration: ${duration.inMilliseconds}ms, error: $error)';
}
