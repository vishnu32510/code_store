import '../../core/config/routes.dart';
import 'package:code_store_core/code_store_core.dart';
import 'flashlight_control_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Demo screen for [FlashlightControlService] (torch, strobe, SOS).
class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  static const String routeName = AppRoutes.flashlight;

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  late final FlashlightControlService _flash;

  @override
  void initState() {
    super.initState();
    _flash = getIt<FlashlightControlService>();
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  Future<void> _onMainTap() async {
    final outcome = await _flash.handleMainTap();
    switch (outcome) {
      case TorchMainTapOutcome.stoppedEffects:
        HapticFeedback.lightImpact();
        break;
      case TorchMainTapOutcome.turnedOn:
        HapticFeedback.mediumImpact();
        break;
      case TorchMainTapOutcome.turnedOff:
        HapticFeedback.lightImpact();
        break;
      case TorchMainTapOutcome.unchanged:
        break;
    }
  }

  void _onStrobeTap() {
    _flash.toggleStrobe();
    HapticFeedback.selectionClick();
  }

  Future<void> _onSosTap() async {
    final outcome = await _flash.toggleSos();
    switch (outcome) {
      case TorchSosOutcome.started:
        HapticFeedback.heavyImpact();
        break;
      case TorchSosOutcome.stopped:
        HapticFeedback.lightImpact();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _flash,
      builder: (context, _) {
        return _FlashlightBody(
          theme: theme,
          flash: _flash,
          onMainTap: _onMainTap,
          onStrobeTap: _onStrobeTap,
          onSosTap: _onSosTap,
        );
      },
    );
  }
}

class _FlashlightBody extends StatelessWidget {
  const _FlashlightBody({
    required this.theme,
    required this.flash,
    required this.onMainTap,
    required this.onStrobeTap,
    required this.onSosTap,
  });

  final ThemeData theme;
  final FlashlightControlService flash;
  final Future<void> Function() onMainTap;
  final VoidCallback onStrobeTap;
  final Future<void> Function() onSosTap;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final raised = colors.surface;
    final onSurface = colors.onSurface;
    final iconOn = isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black;
    final iconOff = onSurface.withValues(alpha: 0.7);
    final borderOn =
        isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87;
    final borderOff = onSurface.withValues(alpha: 0.52);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final isOn = flash.isTorchOn;
    final strobe = flash.strobeActive;
    final sos = flash.sosActive;
    final normalMode = !strobe && !sos;

    final torch = Semantics(
      label: strobe || sos ? 'Flashlight, stop strobe or SOS' : 'Flashlight',
      button: true,
      toggled: isOn && normalMode,
      child: AnimatedScale(
        scale: isOn && normalMode ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: raised,
            boxShadow: [
              if (isOn)
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.62)
                      : const Color(0xFFFFC107).withValues(alpha: 0.45),
                  blurRadius: 52,
                  spreadRadius: 6,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                offset: const Offset(14, 14),
                blurRadius: 28,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.8),
                offset: const Offset(-10, -10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onMainTap,
              child: Center(
                child: AnimatedScale(
                  scale: isOn ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest,
                      border: Border.all(
                        color: isOn ? borderOn : borderOff,
                        width: isOn ? 2.2 : 2.4,
                      ),
                      boxShadow: isOn
                          ? [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0xFFFFFFFF).withValues(alpha: 0.75)
                                    : const Color(0xFFFFC107).withValues(alpha: 0.5),
                                blurRadius: 36,
                                spreadRadius: 2,
                              ),
                            ]
                          : const [],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.92,
                                end: 1,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isOn
                              ? Icons.flashlight_on_rounded
                              : Icons.flashlight_off_rounded,
                          key: ValueKey<bool>(isOn),
                          size: 46,
                          color: isOn ? iconOn : iconOff,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: torch,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Strobe',
                    button: true,
                    toggled: strobe,
                    child: OutlinedButton.icon(
                      onPressed: onStrobeTap,
                      icon: Icon(
                        strobe
                            ? Icons.flash_on_rounded
                            : Icons.flash_on_outlined,
                        size: 20,
                      ),
                      label: Text(strobe ? 'Strobe on' : 'Strobe'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Semantics(
                    label: 'SOS distress signal',
                    button: true,
                    toggled: sos,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        elevation: sos ? 6 : 2,
                      ),
                      onPressed: onSosTap,
                      child: Text(
                        sos ? 'Stop SOS' : 'SOS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Strobe flashes about once per second. Not for people with photosensitive epilepsy.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.55),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
