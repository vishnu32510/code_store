import 'dart:async';
import 'package:code_store_connectivity/code_store_connectivity.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/material.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  final IConnectivityService _connectivityService = getIt<IConnectivityService>();

  AppConnectivityStatus _currentStatus = AppConnectivityStatus.offline();
  StreamSubscription<AppConnectivityStatus>? _subscription;
  bool _isLoading = true;
  bool _isPinging = false;
  int? _latencyMs;
  final List<String> _eventLogs = [];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final status = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _currentStatus = status;
        _isLoading = false;
        _addLog('Initial state: ${status.primaryTypeName} (Connected: ${status.isConnected})');
      });
    }

    _subscription = _connectivityService.onConnectivityChanged.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
          _addLog('Network changed: ${status.primaryTypeName} (Connected: ${status.isConnected})');
        });
      }
    });
  }

  void _addLog(String msg) {
    final time = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
    _eventLogs.insert(0, '[$time] $msg');
    if (_eventLogs.length > 20) {
      _eventLogs.removeLast();
    }
  }

  Future<void> _runPingTest() async {
    setState(() {
      _isPinging = true;
      _latencyMs = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      // Simulate pinging Google DNS / Cloudflare
      await Future.delayed(const Duration(milliseconds: 140));
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _latencyMs = stopwatch.elapsedMilliseconds;
          _isPinging = false;
          _addLog('Latency Ping test: ${_latencyMs}ms');
        });
        getIt<IToastService>().showSuccess('Ping completed: ${_latencyMs}ms');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPinging = false);
        getIt<IToastService>().showError('Ping failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connectivity'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () async {
              final s = await _connectivityService.checkConnectivity();
              setState(() => _currentStatus = s);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusHero(context, colors),
                const SizedBox(height: 20),
                _buildPingCard(context, colors),
                const SizedBox(height: 20),
                Text(
                  'Live Network Events',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLogsCard(context, colors),
              ],
            ),
    );
  }

  Widget _buildStatusHero(BuildContext context, ColorScheme colors) {
    final isOnline = _currentStatus.isConnected;
    final statusColor = isOnline ? Colors.green : colors.error;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _currentStatus.icon,
              size: 48,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOnline ? 'Online & Connected' : 'Disconnected (Offline)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Active interface: ${_currentStatus.primaryTypeName}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPingCard(BuildContext context, ColorScheme colors) {
    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.speed_rounded, color: colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latency & Speed Test',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _latencyMs != null
                        ? 'Response time: ${_latencyMs}ms'
                        : 'Measure round-trip time',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isPinging ? null : _runPingTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: _isPinging
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsCard(BuildContext context, ColorScheme colors) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _eventLogs.isEmpty
          ? const Center(child: Text('No events recorded yet.'))
          : ListView.builder(
              itemCount: _eventLogs.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  _eventLogs[i],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
    );
  }
}
