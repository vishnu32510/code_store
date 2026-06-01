import 'package:code_store/features/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:code_store/features/flashlight/flashlight_screen.dart';
import 'package:code_store/features/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab == 0 ? 'Dashboard' : 'Flashlight Controls'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: () {
              final bloc = context.read<ThemeBloc>();
              final current = bloc.state.themeEventType;
              final next =
                  current == ThemeType.darkMode
                      ? ThemeType.lightMode
                      : ThemeType.darkMode;
              bloc.add(ThemeEventChange(next));
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: const CircleBorder(),
        elevation: 6,
        onPressed: () => _showArchitectureGuide(context),
        child: const Icon(Icons.info_outline_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: IndexedStack(
        index: _currentTab,
        children: const [_DashboardProfileView(), FlashlightScreen()],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        color: colors.surfaceContainer,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tab 0 button
            Semantics(
              label: "Home Dashboard",
              button: true,
              selected: _currentTab == 0,
              child: IconButton(
                icon: Icon(
                  Icons.dashboard_rounded,
                  color:
                      _currentTab == 0
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.65),
                  size: 28,
                ),
                onPressed: () => setState(() => _currentTab = 0),
              ),
            ),
            const SizedBox(width: 48), // spacer for central FAB
            // Tab 1 button
            Semantics(
              label: "Flashlight Demo",
              button: true,
              selected: _currentTab == 1,
              child: IconButton(
                icon: Icon(
                  Icons.flashlight_on_rounded,
                  color:
                      _currentTab == 1
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.65),
                  size: 28,
                ),
                onPressed: () => setState(() => _currentTab = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArchitectureGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Template Architecture',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Your fully loaded clean codebase checklist',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildGuideItem(
                context,
                Icons.folder_copy_rounded,
                'Clean Structure',
                'Modular folders separating authentication, themes, and services.',
              ),
              const SizedBox(height: 16),
              _buildGuideItem(
                context,
                Icons.rocket_launch_rounded,
                'CI/CD & Fastlane',
                'Ready-made actions for PR analysis and secure store deployment lanes.',
              ),
              const SizedBox(height: 16),
              _buildGuideItem(
                context,
                Icons.supervised_user_circle_rounded,
                'GetIt & BLoC',
                'State-of-the-art state management and global dependency injection.',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardProfileView extends StatelessWidget {
  const _DashboardProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, auth) {
        final user = auth.user;
        final email = user.email ?? user.id;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Signed in profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome back,',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Template Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOverviewRow(
                      context,
                      Icons.security_rounded,
                      'Authentication',
                      'Firebase Auth fully configured.',
                    ),
                    const Divider(height: 24),
                    _buildOverviewRow(
                      context,
                      Icons.palette_rounded,
                      'Theme Support',
                      'ThemeBloc controls light/dark modes.',
                      trailing: const ThemeChangeDropdownButton(),
                    ),
                    const Divider(height: 24),
                    _buildOverviewRow(
                      context,
                      Icons.offline_bolt_rounded,
                      'Services & DI',
                      'Singletons resolved dynamically.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<AuthenticationBloc>().add(const LogoutRequested());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewRow(
    BuildContext context,
    IconData icon,
    String title,
    String desc, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing],
      ],
    );
  }
}
