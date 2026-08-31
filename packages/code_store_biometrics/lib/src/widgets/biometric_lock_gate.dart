import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/i_biometric_service.dart';

/// Reusable application lock gate that requires biometric authentication
/// on cold start and whenever the app resumes from the background.
class BiometricLockGate extends StatefulWidget {
  const BiometricLockGate({
    super.key,
    required this.child,
    this.shouldLock,
    this.promptReason = 'Authenticate with Face ID or Fingerprint to continue',
    this.biometricService,
    this.lockScreenBuilder,
  });

  /// The normal application widget to render when unlocked.
  final Widget child;

  /// Optional predicate to determine if the lock should be enforced
  /// (e.g. only enforce when user is authenticated). If null, defaults to true.
  final bool Function()? shouldLock;

  /// Localized explanation displayed in the biometric prompt.
  final String promptReason;

  /// Optional custom instance of [IBiometricService]. Defaults to `GetIt.instance<IBiometricService>()`.
  final IBiometricService? biometricService;

  /// Optional custom lock screen UI builder.
  final Widget Function(BuildContext context, VoidCallback onUnlock)?
  lockScreenBuilder;

  @override
  State<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends State<BiometricLockGate>
    with WidgetsBindingObserver {
  late final IBiometricService _service;
  bool _isPrompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service = widget.biometricService ?? GetIt.instance<IBiometricService>();
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final enabled = await _service.isAppLockEnabled();
    final allowed = widget.shouldLock?.call() ?? true;

    if (enabled && allowed) {
      _service.lock();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerUnlock();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _handleAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppPaused() async {
    final enabled = await _service.isAppLockEnabled();
    final allowed = widget.shouldLock?.call() ?? true;

    if (enabled && allowed) {
      _service.lock();
    }
  }

  Future<void> _handleAppResumed() async {
    if (_service.isLocked && !_isPrompting) {
      _triggerUnlock();
    }
  }

  Future<void> _triggerUnlock() async {
    if (_isPrompting) return;
    _isPrompting = true;

    try {
      await _service.promptUnlock(localizedReason: widget.promptReason);
    } finally {
      if (mounted) {
        setState(() {
          _isPrompting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _service.isLockedNotifier,
      builder: (context, isLocked, _) {
        if (!isLocked) {
          return widget.child;
        }

        if (widget.lockScreenBuilder != null) {
          return widget.lockScreenBuilder!(context, _triggerUnlock);
        }

        return _buildDefaultLockScreen(context);
      },
    );
  }

  Widget _buildDefaultLockScreen(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          gradient: LinearGradient(
            colors: [
              colors.surface,
              colors.surfaceContainerHighest.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'App Locked',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Biometric authentication is required to access your session.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _triggerUnlock,
                    icon: const Icon(Icons.fingerprint_rounded, size: 24),
                    label: const Text(
                      'Unlock with Biometrics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
