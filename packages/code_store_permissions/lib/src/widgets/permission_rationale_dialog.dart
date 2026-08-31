import 'package:flutter/material.dart';

import '../models/app_permission_type.dart';
import '../services/i_permission_service.dart';

/// Interactive rationale and educational prompt dialog for device permissions.
class PermissionRationaleDialog extends StatelessWidget {
  const PermissionRationaleDialog({
    super.key,
    required this.permissionType,
    this.customTitle,
    this.customRationale,
    this.isPermanentlyDenied = false,
    required this.onConfirm,
    this.onCancel,
  });

  final AppPermissionType permissionType;
  final String? customTitle;
  final String? customRationale;
  final bool isPermanentlyDenied;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  /// Shows the rationale dialog helper.
  static Future<bool> show(
    BuildContext context, {
    required AppPermissionType type,
    String? title,
    String? rationale,
    bool isPermanentlyDenied = false,
    required IPermissionService permissionService,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => PermissionRationaleDialog(
        permissionType: type,
        customTitle: title,
        customRationale: rationale,
        isPermanentlyDenied: isPermanentlyDenied,
        onConfirm: () async {
          Navigator.of(ctx).pop(true);
          if (isPermanentlyDenied) {
            await permissionService.openAppSettings();
          } else {
            await permissionService.requestPermission(type);
          }
        },
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = customTitle ?? '${permissionType.displayName} Permission';
    final description = customRationale ?? permissionType.defaultRationale;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(permissionType.icon, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isPermanentlyDenied
                  ? '$description\n\nAccess was previously denied. Please enable it in Settings.'
                  : description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).maybePop(false);
                    },
                    child: Text(
                      'Not Now',
                      style: TextStyle(
                        color: colors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isPermanentlyDenied ? 'Open Settings' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
