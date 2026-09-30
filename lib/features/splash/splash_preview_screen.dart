import 'package:code_store_splash/code_store_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive showcase screen allowing users and developers to test, preview,
/// and configure splash animations, footer branding, and audio chimes.
class SplashPreviewScreen extends StatefulWidget {
  const SplashPreviewScreen({super.key});

  @override
  State<SplashPreviewScreen> createState() => _SplashPreviewScreenState();
}

class _SplashPreviewScreenState extends State<SplashPreviewScreen> {
  SplashAnimationType _animationType = SplashAnimationType.scale;
  bool _enableFooter = true;
  bool _enableAudio = true;
  double _volume = 0.8;
  int _animationDurationMs = 1200;
  int _stayDurationMs = 1800;
  bool _isDarkMode = true;
  int _previewKeyCounter = 0;

  void _triggerPreviewReplay() {
    setState(() {
      _previewKeyCounter++;
    });
  }

  void _launchFullscreenSplash() {
    final config = SplashConfig(
      logoAsset: _isDarkMode
          ? 'assets/icon/app_logo.png'
          : 'assets/icon/app_logo_black.png',
      logoSize: 130,
      animationType: _animationType,
      animationDuration: Duration(milliseconds: _animationDurationMs),
      stayDuration: Duration(milliseconds: _stayDurationMs),
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      darkBackgroundColor: const Color(0xFF121212),
      footerLogoAsset: _enableFooter ? 'assets/icon/branding.png' : null,
      footerText: _enableFooter ? 'Powered by Nungu' : null,
      footerLogoHeight: 44,
      audioConfig: _enableAudio
          ? SplashAudioConfig(
              assetPath: 'assets/audio/splash_chime.wav',
              volume: _volume,
            )
          : null,
      onFinished: () {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Splash transition finished successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Stack(
            children: [
              NativeSplashView(config: config),
              Positioned(
                top: 40,
                right: 20,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                    tooltip: 'Dismiss Splash',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showNativeYamlDialog() {
    final yaml = NativeSplashConfigHelper.generateYaml(
      colorHex: _isDarkMode ? '#121212' : '#ffffff',
      colorDarkHex: '#121212',
      imagePath: 'assets/icon/app_icon.png',
      imageDarkPath: 'assets/icon/app_icon.png',
      brandingPath: _enableFooter ? 'assets/icon/branding.png' : null,
      brandingDarkPath: _enableFooter ? 'assets/icon/branding.png' : null,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text('Native Config (YAML)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Copy this configuration into flutter_native_splash.yaml to generate native Android XML and iOS LaunchScreen:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    yaml,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Terminal command to apply:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    NativeSplashConfigHelper.generateCliCommand,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: yaml));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('YAML copied to clipboard!')),
                );
              },
              child: const Text('Copy YAML'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Splash Package'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded),
            tooltip: 'View Native YAML Config',
            onPressed: _showNativeYamlDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Replay Embedded Preview',
            onPressed: _triggerPreviewReplay,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Embedded Preview Card
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 240,
                color: _isDarkMode ? const Color(0xFF121212) : Colors.white,
                child: Stack(
                  key: ValueKey(_previewKeyCounter),
                  children: [
                    Center(
                      child: AnimatedSplashLogo(
                        logoAsset: _isDarkMode
                            ? 'assets/icon/app_logo.png'
                            : 'assets/icon/app_logo_black.png',
                        size: 90,
                        animationType: _animationType,
                        duration: Duration(milliseconds: _animationDurationMs),
                      ),
                    ),
                    if (_enableFooter)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: SplashFooterLogo(
                          footerLogoAsset: 'assets/icon/branding.png',
                          footerText: 'Powered by Nungu',
                          footerLogoHeight: 32,
                          textColor: _isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _animationType.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _launchFullscreenSplash,
                    icon: const Icon(Icons.fullscreen_rounded),
                    label: const Text('Play Fullscreen'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _triggerPreviewReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Replay'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Controls Section Header
            Text(
              'Configuration & Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Animation Style Selection
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Logo Animation Style',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose between a static logo (zero motion handover) or entrance animations.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SplashAnimationType.values
                          .where((t) => t != SplashAnimationType.custom)
                          .map((type) {
                            final isSelected = _animationType == type;
                            return ChoiceChip(
                              label: Text(type.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _animationType = type;
                                    _previewKeyCounter++;
                                  });
                                }
                              },
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Footer / Branding Option
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Native Footer / Branding Logo'),
                subtitle: const Text(
                  'Pins branding logo and tagline to the bottom safe area.',
                ),
                secondary: const Icon(
                  Icons.branding_watermark_rounded,
                  color: Colors.indigo,
                ),
                value: _enableFooter,
                onChanged: (val) {
                  setState(() {
                    _enableFooter = val;
                    _previewKeyCounter++;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            // Audio Chime Option
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Audio Chime / Entrance Tune'),
                      subtitle: const Text(
                        'Plays entrance sound (assets/audio/splash_chime.wav).',
                      ),
                      secondary: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.deepPurple,
                      ),
                      value: _enableAudio,
                      onChanged: (val) {
                        setState(() {
                          _enableAudio = val;
                        });
                      },
                    ),
                    if (_enableAudio) ...[
                      const Divider(),
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          const Text('Volume:', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: '${(_volume * 100).toInt()}%',
                              onChanged: (val) {
                                setState(() {
                                  _volume = val;
                                });
                              },
                            ),
                          ),
                          Text(
                            '${(_volume * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Duration & Theme Controls
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Dark Mode Background'),
                      subtitle: const Text(
                        'Preview against #121212 native dark background.',
                      ),
                      secondary: Icon(
                        _isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Colors.amber[700],
                      ),
                      value: _isDarkMode,
                      onChanged: (val) {
                        setState(() {
                          _isDarkMode = val;
                        });
                      },
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Animation Duration: ',
                          style: TextStyle(fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: _animationDurationMs.toDouble(),
                            min: 500,
                            max: 3000,
                            divisions: 25,
                            label: '${_animationDurationMs}ms',
                            onChanged: (val) {
                              setState(() {
                                _animationDurationMs = val.toInt();
                              });
                            },
                          ),
                        ),
                        Text(
                          '${_animationDurationMs}ms',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Stay Duration: ',
                          style: TextStyle(fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: _stayDurationMs.toDouble(),
                            min: 500,
                            max: 4000,
                            divisions: 35,
                            label: '${_stayDurationMs}ms',
                            onChanged: (val) {
                              setState(() {
                                _stayDurationMs = val.toInt();
                              });
                            },
                          ),
                        ),
                        Text(
                          '${_stayDurationMs}ms',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
