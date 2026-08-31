import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../services/i_messaging_service.dart';

/// Opens a dialog displaying the device's FCM registration token with a one-tap copy button.
Future<void> showFCMTokenDialog(
  BuildContext context, {
  IMessagingService? messagingService,
}) async {
  final service = messagingService ?? GetIt.instance<IMessagingService>();
  final token = await service.getToken();

  if (!context.mounted) return;

  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.key_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'FCM Registration Token',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Paste this token into the Firebase Console ("Test this campaign" or "Send test message") to target this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: SelectableText(
                    token ?? 'Token not generated yet. Request permission first.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (token != null)
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ FCM Token copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy Token to Clipboard'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Displays a high-converting, user-friendly pre-permission rationale dialog
/// explaining WHY notifications are requested before triggering the OS prompt.
Future<bool> showNotificationPermissionPrompt(
  BuildContext context, {
  String title = 'Stay Updated with CodeStore',
  String subtitle =
      'Enable notifications so you never miss important updates, new features, and account security alerts.',
  String confirmLabel = 'Enable Notifications',
  String dismissLabel = 'Maybe Later',
  IMessagingService? messagingService,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => NotificationPermissionPromptDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      dismissLabel: dismissLabel,
      messagingService: messagingService,
    ),
  );

  return result ?? false;
}

/// A modal dialog presenting a clear rationale for notification permissions.
class NotificationPermissionPromptDialog extends StatelessWidget {
  const NotificationPermissionPromptDialog({
    super.key,
    this.title = 'Stay Updated with CodeStore',
    this.subtitle = 'Enable notifications so you never miss important updates, new features, and account security alerts.',
    this.confirmLabel = 'Enable Notifications',
    this.dismissLabel = 'Maybe Later',
    this.messagingService,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;
  final String dismissLabel;
  final IMessagingService? messagingService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon with subtle glowing container
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 32,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Feature Highlights List
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      icon: Icons.bolt_rounded,
                      text: 'Real-time critical alerts and activity updates',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureRow(
                      context,
                      icon: Icons.security_rounded,
                      text: 'Account security and verification alerts',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureRow(
                      context,
                      icon: Icons.star_rounded,
                      text: 'New template drops and platform announcements',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              FilledButton(
                onPressed: () async {
                  final service =
                      messagingService ?? GetIt.instance<IMessagingService>();
                  Navigator.of(context).pop(true);
                  try {
                    await service.requestPermission();
                  } catch (_) {}
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(dismissLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
