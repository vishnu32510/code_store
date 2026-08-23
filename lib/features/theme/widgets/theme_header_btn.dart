import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme_bloc/theme_bloc.dart';
import '../theme_enums.dart';

/// Circular animated theme toggle button with smooth micro-interactions,
/// rotation, and glowing hover states.
class ThemeHeaderButton extends StatefulWidget {
  const ThemeHeaderButton({super.key});

  @override
  State<ThemeHeaderButton> createState() => _ThemeHeaderButtonState();
}

class _ThemeHeaderButtonState extends State<ThemeHeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentType = state.themeEventType;
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        final IconData currentIcon = currentType.iconData;
        final String tooltip = 'Switch from ${currentType.themeName} theme';

        // Cycle through all available ThemeType enum values
        final currentIndex = ThemeType.values.indexOf(currentType);
        final nextTheme =
            ThemeType.values[(currentIndex + 1) % ThemeType.values.length];

        final isDarkTheme = theme.brightness == Brightness.dark;

        return Tooltip(
          message: tooltip,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () {
                context.read<ThemeBloc>().add(ThemeEventChange(nextTheme));
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
                    child: Icon(
                      currentIcon,
                      key: ValueKey<ThemeType>(currentType),
                      size: 22,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Alias for convenience
typedef ThemeHeader = ThemeHeaderButton;
