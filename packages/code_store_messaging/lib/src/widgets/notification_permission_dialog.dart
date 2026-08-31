import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/i_messaging_service.dart';

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
    this.subtitle =
        'Enable notifications so you never miss important updates, new features, and account security alerts.',
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
