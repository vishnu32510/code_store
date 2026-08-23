import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme_bloc/theme_bloc.dart';

class ThemeHeaderButton extends StatefulWidget {
  final VoidCallback? onToggled;

  const ThemeHeaderButton({
    super.key,
    this.onToggled,
  });

  @override
  State<ThemeHeaderButton> createState() => _ThemeHeaderButtonState();
}

class _ThemeHeaderButtonState extends State<ThemeHeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentTheme = state.currentTheme;
        final nextTheme = state.nextTheme;
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final isDarkTheme = theme.brightness == Brightness.dark;

        return Tooltip(
          message: 'Switch to ${nextTheme.name} Theme',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () {
                widget.onToggled?.call();
                context.read<ThemeBloc>().add(const ThemeEventCycleNext());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkTheme
                      ? (_isHovered
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.06))
                      : (_isHovered
                            ? Colors.black.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04)),
                  border: Border.all(
                    color: _isHovered
                        ? primaryColor.withValues(alpha: 0.8)
                        : (isDarkTheme
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.1)),
                    width: 1.2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 14,
                            spreadRadius: 1.5,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: Tween<double>(
                          begin: 0.75,
                          end: 1.0,
                        ).animate(animation),
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _buildIconWidget(currentTheme.icon, primaryColor, currentTheme.id),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconWidget(dynamic iconData, Color primaryColor, String key) {
    if (iconData is IconData) {
      return Icon(
        iconData,
        key: ValueKey<String>(key),
        size: 22,
        color: primaryColor,
      );
    } else if (iconData is Widget) {
      return KeyedSubtree(
        key: ValueKey<String>(key),
        child: iconData,
      );
    } else if (iconData is Widget Function(BuildContext)) {
      return KeyedSubtree(
        key: ValueKey<String>(key),
        child: iconData(context),
      );
    }
    return Icon(
      Icons.palette_outlined,
      key: ValueKey<String>(key),
      size: 22,
      color: primaryColor,
    );
  }
}

typedef ThemeHeader = ThemeHeaderButton;
