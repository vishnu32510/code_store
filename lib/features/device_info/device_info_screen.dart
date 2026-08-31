import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_device_info/code_store_device_info.dart';
import 'package:flutter/material.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final IDeviceInfoService _deviceInfoService = getIt<IDeviceInfoService>();

  AppDeviceInfo? _deviceInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() => _isLoading = true);
    final info = await _deviceInfoService.getDeviceInfo();
    if (mounted) {
      setState(() {
        _deviceInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device & App Info'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Info',
            onPressed: _loadDeviceInfo,
          ),
        ],
      ),
      body: _isLoading || _deviceInfo == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeroCard(context, colors),
                const SizedBox(height: 20),
                Text(
                  'Application Metadata',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  icon: Icons.apps_rounded,
                  title: 'App Name',
                  value: _deviceInfo!.appName,
                  colors: colors,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.tag_rounded,
                  title: 'Package / Bundle ID',
                  value: _deviceInfo!.packageName,
                  colors: colors,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.code_rounded,
                  title: 'Version & Build',
                  value: _deviceInfo!.formattedVersion,
                  colors: colors,
                ),
                const SizedBox(height: 20),
                Text(
                  'Hardware & OS Diagnostics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  icon: Icons.phone_android_rounded,
                  title: 'Device Model',
                  value: _deviceInfo!.deviceModel,
                  colors: colors,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.memory_rounded,
                  title: 'Operating System',
                  value: '${_deviceInfo!.osName} ${_deviceInfo!.osVersion}',
                  colors: colors,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.verified_user_rounded,
                  title: 'Environment',
                  value: _deviceInfo!.isPhysicalDevice
                      ? 'Physical Hardware'
                      : 'Simulator / Emulator',
                  colors: colors,
                ),
              ],
            ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded, color: colors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _deviceInfo!.appName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Running version ${_deviceInfo!.formattedVersion}',
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

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colors,
  }) {
    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: colors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
