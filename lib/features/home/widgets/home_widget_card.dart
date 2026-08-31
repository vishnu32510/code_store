import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_home_widget/code_store_home_widget.dart';
import 'package:flutter/material.dart';

class HomeWidgetCard extends StatefulWidget {
  const HomeWidgetCard({super.key});

  @override
  State<HomeWidgetCard> createState() => _HomeWidgetCardState();
}

class _HomeWidgetCardState extends State<HomeWidgetCard> {
  final _titleController = TextEditingController(text: 'CodeStore Status');
  final _messageController = TextEditingController(
    text: 'All packages & services operational 🚀',
  );
  final _statusController = TextEditingController(text: 'Active');
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  HomeWidgetPayload _buildPayload() {
    return HomeWidgetPayload(
      title: _titleController.text.trim().isEmpty
          ? 'CodeStore Status'
          : _titleController.text.trim(),
      message: _messageController.text.trim().isEmpty
          ? 'No message'
          : _messageController.text.trim(),
      status: _statusController.text.trim().isEmpty
          ? 'Active'
          : _statusController.text.trim(),
      updatedAt: DateTime.now(),
      badgeCount: 1,
      actionUri: 'codestore://notifications',
    );
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    try {
      final service = getIt<HomeWidgetService>();
      final payload = _buildPayload();
      final success = await service.syncPayload(payload);
      if (mounted) {
        setState(() {
          _lastSyncTime = DateTime.now();
        });
        if (success) {
          getIt<IToastService>().showSuccess('Widget data synchronized live!');
        } else {
          getIt<IToastService>().showInfo('Widget sync requested.');
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is UnsupportedError
            ? (e.message ?? 'Home widgets are not supported on this platform.')
            : 'Failed to sync widget: $e';
        getIt<IToastService>().showError(message);
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.widgets_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home Screen Widget',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sync live model data to native iOS & Android widgets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_lastSyncTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Synced',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Widget Title',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Widget Message',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status Badge (e.g. Active, Operational)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSyncing ? null : _syncData,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 20),
                label: const Text(
                  'Sync to Home Widget',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
