import 'package:code_store/core/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 404 Page displayed whenever an unknown or unmapped route is requested.
class NotFoundScreen extends StatelessWidget {
  final String? uri;

  const NotFoundScreen({super.key, this.uri});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore_off_rounded,
                      size: 48,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '404',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route Not Found',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uri != null && uri!.isNotEmpty
                        ? 'The path "$uri" could not be resolved.'
                        : 'The requested screen does not exist or has been moved.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.go(AppRoutes.dashboard);
                      },
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        'Back to Dashboard',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go(AppRoutes.homeWidget);
                      },
                      icon: const Icon(Icons.widgets_rounded, size: 20),
                      label: const Text('Open Home Widgets'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
