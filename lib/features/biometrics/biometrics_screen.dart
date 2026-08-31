import 'package:code_store_biometrics/code_store_biometrics.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/material.dart';

class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  final IBiometricService _biometricService = getIt<IBiometricService>();

  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = true;

  BiometricAuthResult? _lastAuthResult;
  bool _isVaultUnlocked = false;
  bool _isAppLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsStatus();
  }

  Future<void> _checkBiometricsStatus() async {
    setState(() => _isLoading = true);

    final isSupported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    final isAvailable = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();
    final isAppLockEnabled = await _biometricService.isAppLockEnabled();

    if (mounted) {
      setState(() {
        _isDeviceSupported = isSupported;
        _canCheckBiometrics = canCheck;
        _isBiometricAvailable = isAvailable;
        _availableBiometrics = biometrics;
        _isAppLockEnabled = isAppLockEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate({bool biometricOnly = false}) async {
    final result = await _biometricService.authenticate(
      localizedReason: 'Scan your fingerprint or face to verify your identity',
      biometricOnly: biometricOnly,
    );

    if (mounted) {
      setState(() {
        _lastAuthResult = result;
      });

      if (result.isSuccess) {
        getIt<IToastService>().showSuccess(
          'Biometric authentication successful!',
        );
      } else {
        getIt<IToastService>().showError(
          result.errorMessage ?? 'Authentication was not completed.',
        );
      }
    }
  }

  Future<void> _toggleVault() async {
    if (_isVaultUnlocked) {
      setState(() => _isVaultUnlocked = false);
      getIt<IToastService>().showInfo('Secure Vault Locked');
      return;
    }

    final result = await _biometricService.authenticate(
      localizedReason: 'Authenticate to unlock the Secure Vault',
      biometricOnly: false,
    );

    if (mounted) {
      setState(() {
        _lastAuthResult = result;
        if (result.isSuccess) {
          _isVaultUnlocked = true;
        }
      });

      if (result.isSuccess) {
        getIt<IToastService>().showSuccess('Vault unlocked successfully!');
      }
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      final result = await _biometricService.authenticate(
        localizedReason: 'Verify biometrics to enable App Lock',
      );
      if (result.isSuccess && mounted) {
        await _biometricService.setAppLockEnabled(true);
        setState(() => _isAppLockEnabled = true);
        getIt<IToastService>().showSuccess('App Lock enabled');
      }
    } else {
      final result = await _biometricService.authenticate(
        localizedReason: 'Verify biometrics to disable App Lock',
      );
      if (result.isSuccess && mounted) {
        await _biometricService.setAppLockEnabled(false);
        setState(() => _isAppLockEnabled = false);
        getIt<IToastService>().showInfo('App Lock disabled');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Hardware Status',
            onPressed: _checkBiometricsStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusBanner(context),
                const SizedBox(height: 20),
                _buildHardwareCard(context),
                const SizedBox(height: 20),
                _buildInteractiveAuthCard(context),
                const SizedBox(height: 20),
                _buildVaultCard(context),
                const SizedBox(height: 20),
                _buildAppLockTile(context),
              ],
            ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final IconData icon;
    final String title;
    final String subtitle;
    final Color bg;

    if (_availableBiometrics.contains(BiometricType.face)) {
      icon = Icons.face_rounded;
      title = 'Face ID / Face Unlock Ready';
      subtitle = 'Facial recognition hardware enrolled and active';
      bg = Colors.blueAccent;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint) ||
        _availableBiometrics.contains(BiometricType.strong)) {
      icon = Icons.fingerprint_rounded;
      title = 'Touch ID / Fingerprint Ready';
      subtitle = 'Fingerprint biometric hardware enrolled and active';
      bg = Colors.green;
    } else if (_isDeviceSupported) {
      icon = Icons.lock_clock_rounded;
      title = 'Biometrics Supported (Not Enrolled)';
      subtitle = 'Register your Face or Fingerprint in Device Settings';
      bg = Colors.orangeAccent;
    } else {
      icon = Icons.security_rounded;
      title = 'Passcode / PIN Fallback';
      subtitle = 'Biometrics hardware unavailable on this platform';
      bg = colors.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: bg, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildHardwareCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Hardware & Enrollment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCheckRow('Hardware Supported', _isDeviceSupported, colors),
            const Divider(height: 20),
            _buildCheckRow(
              'Sensor Active / Can Check',
              _canCheckBiometrics,
              colors,
            ),
            const Divider(height: 20),
            _buildCheckRow(
              'Biometrics Enrolled & Available',
              _isBiometricAvailable,
              colors,
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enrolled Types',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  _availableBiometrics.isEmpty
                      ? 'None'
                      : _availableBiometrics
                            .map((b) => b.name)
                            .join(', ')
                            .toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String label, bool isOk, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Icon(
              isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isOk ? Colors.green : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isOk ? 'Yes' : 'No',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOk ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractiveAuthCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Test Authentication',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Trigger system Face ID, Touch ID, or Android BiometricPrompt sheets:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _authenticate(biometricOnly: true),
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Biometrics Only'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _authenticate(biometricOnly: false),
                    icon: const Icon(Icons.password_rounded),
                    label: const Text('With Passcode'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_lastAuthResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lastAuthResult!.isSuccess
                      ? Colors.green.withValues(alpha: 0.1)
                      : colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _lastAuthResult!.isSuccess
                        ? Colors.green.withValues(alpha: 0.3)
                        : colors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastAuthResult!.isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: _lastAuthResult!.isSuccess
                          ? Colors.green
                          : colors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Status: ${_lastAuthResult!.status.name.toUpperCase()}${_lastAuthResult!.errorMessage != null ? ' - ${_lastAuthResult!.errorMessage}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _lastAuthResult!.isSuccess
                              ? Colors.green
                              : colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVaultCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isVaultUnlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      color: _isVaultUnlocked ? Colors.green : colors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Protected Vault Demo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isVaultUnlocked
                        ? Icons.lock_reset_rounded
                        : Icons.lock_rounded,
                    color: _isVaultUnlocked ? Colors.redAccent : colors.primary,
                  ),
                  tooltip: _isVaultUnlocked ? 'Lock Vault' : 'Unlock Vault',
                  onPressed: _toggleVault,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isVaultUnlocked
                    ? Colors.green.withValues(alpha: 0.08)
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isVaultUnlocked
                      ? Colors.green.withValues(alpha: 0.3)
                      : colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: _isVaultUnlocked
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔐 Secret API Token:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        SelectableText(
                          'DEMO_VAULT_TOKEN_ABCD1234XYZ',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 36,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vault is locked. Authenticate to view secret keys.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _toggleVault,
                          icon: const Icon(Icons.fingerprint_rounded, size: 18),
                          label: const Text('Unlock Secret Vault'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLockTile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        title: const Text(
          'Biometric App Lock',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: const Text(
          'Require Face ID or Fingerprint when resuming app',
          style: TextStyle(fontSize: 13),
        ),
        secondary: Icon(
          Icons.fingerprint_rounded,
          color: _isAppLockEnabled ? colors.primary : Colors.grey,
        ),
        value: _isAppLockEnabled,
        onChanged: _toggleAppLock,
      ),
    );
  }
}
