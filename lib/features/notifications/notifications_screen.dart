import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_messaging/code_store_messaging.dart';
import 'package:code_store_theme/code_store_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final IMessagingService _messaging;
  late final IToastService _toast;

  NotificationSettings? _settings;
  String? _fcmToken;
  bool _isLoading = true;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _messaging = getIt<IMessagingService>();
    _toast = getIt<IToastService>();
    _loadNotificationData();
  }

  Future<void> _loadNotificationData() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _messaging.getNotificationSettings();
      final token = await _messaging.getToken();
      if (mounted) {
        setState(() {
          _settings = settings;
          _fcmToken = token;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequestingPermission = true);
    try {
      final settings = await _messaging.requestPermission();
      final token = await _messaging.getToken();
      if (mounted) {
        setState(() {
          _settings = settings;
          _fcmToken = token;
          _isRequestingPermission = false;
        });
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          _toast.showSuccess('Notifications enabled!');
        } else {
          _toast.showInfo('Status: ${settings.authorizationStatus.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
        _toast.showError('Error requesting permission: $e');
      }
    }
  }

  Future<void> _sendTestLocalNotification() async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      if (kIsWeb) {
        _toast.showInfo('Test Notification triggered (Foreground Web Event)');
      } else {
        await _messaging.showLocalNotification(
          id: id,
          title: '🚀 CodeStore Test Notification',
          body: 'Local push notifications are working smoothly!',
          payload: '{"type": "test_notification", "id": $id}',
        );
        _toast.showSuccess('Local notification sent!');
      }
    } catch (e) {
      _toast.showError('Error showing notification: $e');
    }
  }

  Future<void> _sendTestRichMediaNotification() async {
    if (kIsWeb) {
      _toast.showInfo('Rich media is for mobile notifications.');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      await _messaging.showRichMediaNotification(
        id: id,
        title: '🎨 Rich Media Alert',
        body: 'This notification includes high-resolution image preview!',
        imageUrl: 'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/shared/brand/flutter/logo/flutter-lockup.png',
        payload: '{"type": "rich_media_test"}',
      );
      _toast.showSuccess('Rich media notification sent!');
    } catch (e) {
      _toast.showError('Error showing rich media: $e');
    }
  }

  Future<void> _schedule5SecNotification() async {
    if (kIsWeb) {
      _toast.showInfo('Background scheduling is for native mobile platforms.');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final scheduledDate = DateTime.now().add(const Duration(seconds: 5));
    try {
      await _messaging.scheduleNotification(
        id: id,
        title: '⏰ Scheduled Reminder',
        body: 'This notification was scheduled 5 seconds ago!',
        scheduledDate: scheduledDate,
      );
      _toast.showSuccess('Notification scheduled for 5 seconds from now!');
    } catch (e) {
      _toast.showError('Error scheduling: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isAuthorized =
        _settings?.authorizationStatus == AuthorizationStatus.authorized ||
        _settings?.authorizationStatus == AuthorizationStatus.provisional;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeHeaderButton(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CARD 1: Permission Status & Action
                _buildCard(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Notification Permission',
                  subtitle: 'Required to receive alerts, background updates, and order notifications.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isAuthorized
                                  ? colors.primaryContainer
                                  : colors.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAuthorized
                                      ? Icons.check_circle_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 16,
                                  color: isAuthorized
                                      ? colors.onPrimaryContainer
                                      : colors.onErrorContainer,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAuthorized
                                      ? 'Permissions Enabled'
                                      : 'Permission Not Granted',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isAuthorized
                                        ? colors.onPrimaryContainer
                                        : colors.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isAuthorized)
                        FilledButton.icon(
                          onPressed: _isRequestingPermission
                              ? null
                              : _requestPermission,
                          icon: _isRequestingPermission
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.notifications_active_rounded),
                          label: Text(
                            _isRequestingPermission
                                ? 'Requesting...'
                                : 'Enable Notifications',
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Re-check Permission Status'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // CARD 2: FCM Registration Token
                _buildCard(
                  context,
                  icon: Icons.key_rounded,
                  title: 'FCM Registration Token',
                  subtitle: 'Use this token in Firebase Console (Test Campaign) to target this exact device.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: SelectableText(
                          _fcmToken ??
                              (_isLoading
                                  ? 'Loading token...'
                                  : 'No token available. Request permission first.'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _fcmToken != null
                                  ? () {
                                      Clipboard.setData(
                                        ClipboardData(text: _fcmToken!),
                                      );
                                      _toast.showSuccess(
                                        'FCM Token copied to clipboard!',
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copy Token'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.outlined(
                            onPressed: _loadNotificationData,
                            tooltip: 'Refresh Token',
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // CARD 3: Local Notification Testing
                _buildCard(
                  context,
                  icon: Icons.phonelink_ring_rounded,
                  title: 'Test Local Notifications',
                  subtitle: 'Test heads-up banners, rich media attachments, and background scheduled alarms.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _sendTestLocalNotification,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Send Instant Local Notification'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _sendTestRichMediaNotification,
                        icon: const Icon(Icons.image_rounded),
                        label: const Text('Send Rich Media Notification'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _schedule5SecNotification,
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text('Schedule in 5 Seconds'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: colors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
