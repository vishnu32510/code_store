import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_theme_config.dart';
import '../theme_bloc/theme_bloc.dart';

class ThemeChangeDropdownButton extends StatelessWidget {
  const ThemeChangeDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            elevation: 2,
            dropdownColor: colors.surface,
            focusColor: colors.surface,
            enableFeedback: false,
            value: state.currentTheme.id,
            icon: const SizedBox(),
            items: state.availableThemes.map((AppThemeConfig item) {
              return DropdownMenuItem<String>(
                value: item.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon is IconData)
                      Icon(
                        item.icon as IconData,
                        size: 18,
                        color: colors.primary,
                      )
                    else if (item.icon is Widget)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: item.icon as Widget,
                      )
                    else
                      Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                    const SizedBox(width: 10),
                    Text(
                      item.name,
                      style: TextStyle(color: colors.onSurface, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newThemeId) {
              if (newThemeId != null) {
                context.read<ThemeBloc>().add(ThemeEventChangeById(newThemeId));
              }
            },
          ),
        );
      },
    );
  }
}
