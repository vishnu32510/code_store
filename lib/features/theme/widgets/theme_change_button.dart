import 'package:code_store/features/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeChangeDropdownButton extends StatelessWidget {
  const ThemeChangeDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return DropdownButtonHideUnderline(
          child: DropdownButton(
            elevation: 0,
            dropdownColor: Theme.of(context).colorScheme.inversePrimary,
            focusColor: Theme.of(context).colorScheme.inversePrimary,
            enableFeedback: false,
            value: state.themeEventType,
            icon: const SizedBox(),
            items:
                ThemeType.values.map((ThemeType items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Row(
                      children: [
                        Icon(items.iconData),
                        const SizedBox(width: 10),
                        Text(items.themeName),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (ThemeType? newValue) {
              if (newValue != null) {
                BlocProvider.of<ThemeBloc>(
                  context,
                ).add(ThemeEventChange(newValue));
              }
            },
          ),
        );
      },
    );
  }
}
