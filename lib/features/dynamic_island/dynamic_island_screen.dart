import 'package:code_store_dynamic_island/code_store_dynamic_island.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Interactive demo screen for Dynamic Island features.
///
/// Provides controls for:
/// - Device support check
/// - Simple status display (text + SF Symbol icon)
/// - Sprite sheet slicing from bundled RetroCatsFree asset
/// - Looping animation start/stop
/// - FPS speed adjustment
class DynamicIslandScreen extends StatefulWidget {
  const DynamicIslandScreen({super.key});

  @override
  State<DynamicIslandScreen> createState() => _DynamicIslandScreenState();
}

class _DynamicIslandScreenState extends State<DynamicIslandScreen> {
  late final IDynamicIslandService _service;

  bool? _isSupported;
  bool _isActivityRunning = false;
  bool _isSlicing = false;
  int _slicedFrameCount = 0;
  double _fps = 10;
  String _selectedAnimation = 'retro_cat_brown';

  final List<_AnimationOption> _animations = [
    _AnimationOption(
      name: 'retro_cat_brown',
      label: 'Brown Cat (Idle)',
      startRow: 0,
      endRow: 0,
      columns: 4,
      totalRows: 7,
    ),
    _AnimationOption(
      name: 'retro_cat_white',
      label: 'White Cat (Idle)',
      startRow: 1,
      endRow: 1,
      columns: 4,
      totalRows: 7,
    ),
    _AnimationOption(
      name: 'retro_cat_sleeping',
      label: 'Sleeping Cat',
      startRow: 2,
      endRow: 2,
      columns: 4,
      totalRows: 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _service = GetIt.instance<IDynamicIslandService>();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final supported = await _service.isSupported();
    if (mounted) {
      setState(() => _isSupported = supported);
    }
  }

  Future<void> _sliceAndAnimate() async {
    final option = _animations.firstWhere((a) => a.name == _selectedAnimation);

    setState(() => _isSlicing = true);

    final frameCount = await _service.sliceSpriteSheet(
      assetPath: 'assets/icon/RetroCatsFree.png',
      animationName: option.name,
      columns: option.columns,
      rows: option.totalRows,
      startRow: option.startRow,
      endRow: option.endRow,
    );

    if (mounted) {
      setState(() {
        _isSlicing = false;
        _slicedFrameCount = frameCount;
      });
    }

    if (frameCount > 0) {
      await _startAnimation(option.name, frameCount);
    }
  }

  Future<void> _startAnimation(String name, int frames) async {
    final config = IslandAnimationConfig(
      animationName: name,
      totalFrames: frames,
      framesPerSecond: _fps.round(),
    );

    final success = await _service.startAnimation(config);
    if (mounted) {
      setState(() => _isActivityRunning = success);
    }
  }

  Future<void> _startSimpleStatus() async {
    const status = IslandStatus(
      title: 'CodeStore',
      subtitle: 'Running...',
      iconSystemName: 'square.grid.2x2.fill',
      isActive: true,
    );

    final success = await _service.startStatus(status);
    if (mounted) {
      setState(() => _isActivityRunning = success);
    }
  }

  Future<void> _stopActivity() async {
    await _service.endActivity();
    if (mounted) {
      setState(() => _isActivityRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Island'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Support status card
          _buildSupportCard(colorScheme),
          const SizedBox(height: 16),

          // Simple status section
          _buildSectionHeader('Simple Status Mode'),
          const SizedBox(height: 8),
          _buildSimpleStatusCard(colorScheme),
          const SizedBox(height: 24),

          // Animation section
          _buildSectionHeader('Sprite Animation Mode'),
          const SizedBox(height: 8),
          _buildSpritePreviewCard(colorScheme),
          const SizedBox(height: 12),
          _buildAnimationSelector(colorScheme),
          const SizedBox(height: 12),
          _buildFpsSlider(colorScheme),
          const SizedBox(height: 12),
          _buildAnimateButton(colorScheme),
          const SizedBox(height: 24),

          // Stop button
          if (_isActivityRunning) _buildStopButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSupportCard(ColorScheme colorScheme) {
    final IconData icon;
    final String label;
    final Color bgColor;

    if (_isSupported == null) {
      icon = Icons.hourglass_empty_rounded;
      label = 'Checking Dynamic Island support...';
      bgColor = colorScheme.surfaceContainerHighest;
    } else if (_isSupported!) {
      icon = Icons.check_circle_rounded;
      label = 'Dynamic Island Supported ✓';
      bgColor = Colors.green.withValues(alpha: 0.15);
    } else {
      icon = Icons.cancel_rounded;
      label = 'Dynamic Island Not Available';
      bgColor = Colors.red.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSimpleStatusCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(
          Icons.text_fields_rounded,
          color: colorScheme.primary,
        ),
        title: const Text('Start Simple Status'),
        subtitle: const Text('Display text & icon in the Dynamic Island'),
        trailing: FilledButton.tonal(
          onPressed: _isActivityRunning ? null : _startSimpleStatus,
          child: const Text('Start'),
        ),
      ),
    );
  }

  Widget _buildSpritePreviewCard(ColorScheme colorScheme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/icon/RetroCatsFree.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sprite sheet not found',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationSelector(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: _selectedAnimation,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(16),
        items: _animations.map((anim) {
          return DropdownMenuItem(
            value: anim.name,
            child: Text(anim.label),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedAnimation = value);
          }
        },
      ),
    );
  }

  Widget _buildFpsSlider(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animation Speed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${_fps.round()} FPS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
          Slider(
            value: _fps,
            min: 5,
            max: 15,
            divisions: 10,
            label: '${_fps.round()} FPS',
            onChanged: (value) => setState(() => _fps = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimateButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _isActivityRunning || _isSlicing ? null : _sliceAndAnimate,
      icon: _isSlicing
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
      label: Text(
        _isSlicing
            ? 'Slicing Sprite Sheet...'
            : _slicedFrameCount > 0
                ? 'Slice & Animate ($_slicedFrameCount frames ready)'
                : 'Slice & Animate',
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildStopButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _stopActivity,
      icon: const Icon(Icons.stop_rounded),
      label: const Text('Stop Dynamic Island Activity'),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _AnimationOption {
  const _AnimationOption({
    required this.name,
    required this.label,
    required this.startRow,
    required this.endRow,
    required this.columns,
    required this.totalRows,
  });

  final String name;
  final String label;
  final int startRow;
  final int endRow;
  final int columns;
  final int totalRows;
}
