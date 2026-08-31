import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_permissions/code_store_permissions.dart';
import 'package:flutter/material.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final IPermissionService _permissionService = getIt<IPermissionService>();

  final Map<AppPermissionType, AppPermissionStatus> _statusMap = {};
  bool _isLoading = true;

  final List<AppPermissionType> _trackedPermissions = [
    AppPermissionType.camera,
    AppPermissionType.photos,
    AppPermissionType.notification,
    AppPermissionType.locationWhenInUse,
    AppPermissionType.microphone,
    AppPermissionType.bluetooth,
    AppPermissionType.appTrackingTransparency,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllPermissions();
    }
  }

  Future<void> _refreshAllPermissions() async {
    setState(() => _isLoading = true);

    final Map<AppPermissionType, AppPermissionStatus> updated = {};
    for (final perm in _trackedPermissions) {
      updated[perm] = await _permissionService.checkPermission(perm);
    }

    if (mounted) {
      setState(() {
        _statusMap.addAll(updated);
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePermissionTap(AppPermissionType type) async {
    final currentStatus = _statusMap[type] ?? AppPermissionStatus.denied;

    if (currentStatus.isGranted) {
      getIt<IToastService>().showInfo(
        '${type.displayName} permission is already granted!',
      );
      return;
    }

    if (currentStatus.isPermanentlyDenied) {
      final shouldOpen = await PermissionRationaleDialog.show(
        context,
        type: type,
        isPermanentlyDenied: true,
        permissionService: _permissionService,
      );
      if (shouldOpen) {
        _refreshAllPermissions();
      }
      return;
    }

    // Show educational rationale dialog before requesting
    final confirmed = await PermissionRationaleDialog.show(
      context,
      type: type,
      permissionService: _permissionService,
    );

    if (confirmed) {
      await _refreshAllPermissions();
      final newStatus = _statusMap[type] ?? AppPermissionStatus.denied;
      if (newStatus.isGranted) {
        getIt<IToastService>().showSuccess(
          '${type.displayName} access granted!',
        );
      } else {
        getIt<IToastService>().showWarning(
          '${type.displayName} status: ${newStatus.label}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final grantedCount = _statusMap.values.where((s) => s.isGranted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: _refreshAllPermissions,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Open Device Settings',
            onPressed: () => _permissionService.openAppSettings(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSummaryCard(context, grantedCount, colors),
                const SizedBox(height: 20),
                Text(
                  'Hardware & Platform Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._trackedPermissions.map((perm) => _buildPermissionTile(
                      context,
                      perm,
                      _statusMap[perm] ?? AppPermissionStatus.denied,
                      colors,
                    )),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int grantedCount,
    ColorScheme colors,
  ) {
    final total = _trackedPermissions.length;
    final progress = total == 0 ? 0.0 : grantedCount / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: colors.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              Text(
                '$grantedCount/$total',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device Permissions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$grantedCount of $total permissions currently enabled',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    AppPermissionType type,
    AppPermissionStatus status,
    ColorScheme colors,
  ) {
    final Color badgeColor;
    final IconData statusIcon;

    if (status.isGranted) {
      badgeColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
    } else if (status.isPermanentlyDenied) {
      badgeColor = colors.error;
      statusIcon = Icons.settings_rounded;
    } else {
      badgeColor = Colors.orange;
      statusIcon = Icons.lock_outline_rounded;
    }

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(type.icon, color: colors.primary, size: 24),
        ),
        title: Text(
          type.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            type.defaultRationale,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: InkWell(
          onTap: () => _handlePermissionTap(type),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: badgeColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () => _handlePermissionTap(type),
      ),
    );
  }
}
