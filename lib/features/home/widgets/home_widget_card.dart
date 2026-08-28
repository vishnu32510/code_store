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
  final _messageController =
      TextEditingController(text: 'All packages & services operational 🚀');
  bool _isSyncing = false;
  bool _isRendering = false;
  DateTime? _lastSyncTime;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
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
      status: 'Active',
      updatedAt: DateTime.now(),
      badgeCount: 1,
      actionUri: 'codestore://dashboard',
    );
  }

  Future<void> _syncTextData() async {
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
          getIt<IToastService>().showSuccess('Home widget text updated!');
        } else {
          getIt<IToastService>().showInfo('Widget sync requested.');
        }
      }
    } catch (e) {
      if (mounted) {
        getIt<IToastService>().showError('Failed to sync widget: $e');
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _renderAndSyncImage() async {
    setState(() => _isRendering = true);
    try {
      final service = getIt<HomeWidgetService>();
      final payload = _buildPayload();

      // Render Flutter widget off-screen to image
      final path = await service.renderFlutterWidget(
        widget: HomeWidgetSnapshotCard(payload: payload),
        key: 'home_widget_image',
        logicalSize: const Size(320, 160),
        pixelRatio: 3.0,
      );

      // Trigger native widget refresh
      await service.updateWidget();

      if (mounted) {
        setState(() {
          _lastSyncTime = DateTime.now();
        });
        if (path != null) {
          getIt<IToastService>().showSuccess('Snapshot rendered & pushed to widget!');
        } else {
          getIt<IToastService>().showInfo('Widget snapshot updated.');
        }
      }
    } catch (e) {
      if (mounted) {
        getIt<IToastService>().showError('Render failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isRendering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final payload = _buildPayload();

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  child: Icon(Icons.widgets_rounded, color: colors.primary, size: 22),
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
                        'iOS WidgetKit & Android AppWidget sync',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_lastSyncTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              onChanged: (_) => setState(() {}),
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              'Snapshot Preview:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: HomeWidgetSnapshotCard(payload: payload),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _syncTextData,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: const Text('Sync Text'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRendering ? null : _renderAndSyncImage,
                    icon: _isRendering
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_rounded, size: 18),
                    label: const Text('Sync Image'),
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
