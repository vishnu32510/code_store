import '../../../core/config/routes.dart';
import '../../../core/utils/app_constants.dart';

import 'package:code_store_auth/code_store_auth.dart';
import 'package:code_store_theme/code_store_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.navigationShell,
    required this.onShowArchitectureGuide,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onShowArchitectureGuide;

  @override
  Widget build(BuildContext context) {
    final currentTab = navigationShell.currentIndex;

    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _buildNavHeader(context, 'Navigation'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'Dashboard',
                    subtitle: 'Overview & profile details',
                    isSelected: currentTab == 0,
                    onTap: () {
                      Navigator.of(context).pop();
                      navigationShell.goBranch(0);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildDrawerItem(
                    context,
                    icon: Icons.flashlight_on_rounded,
                    title: 'Flashlight',
                    subtitle: 'Torch, strobe & SOS controls',
                    isSelected: currentTab == 1,
                    onTap: () {
                      Navigator.of(context).pop();
                      navigationShell.goBranch(1);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildDrawerItem(
                    context,
                    icon: Icons.widgets_rounded,
                    title: 'Home Widgets',
                    subtitle: 'iOS WidgetKit & Android Glance sync',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.homeWidget);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Permissions, token & local alerts',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.notifications);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildDrawerItem(
                    context,
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Auth',
                    subtitle: 'Face ID, Touch ID & App Lock',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.biometrics);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _buildNavHeader(context, 'Appearance & Theme'),
                  _buildThemeTile(context),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _buildNavHeader(context, 'About & Info'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.architecture_rounded,
                    title: 'Architecture Guide',
                    subtitle: 'Modular packages & structure',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      onShowArchitectureGuide();
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, auth) {
        final user = auth.user;
        final email = user.email ?? user.id;
        final isSignedIn =
            auth.status == AuthenticationStatus.authenticated &&
            auth.user.isNotEmpty;
        final displayName = isSignedIn && email.isNotEmpty
            ? email
            : 'Guest User';

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(
                      isSignedIn
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSignedIn
                                ? Colors.greenAccent
                                : Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSignedIn ? 'Signed In' : 'Guest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appDisplayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? colors.primary : colors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      selected: isSelected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.palette_rounded,
          color: colors.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        'Theme Mode',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Switch color theme',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      trailing: const ThemeChangeDropdownButton(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, auth) {
        final isSignedIn =
            auth.status == AuthenticationStatus.authenticated &&
            auth.user.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: isSignedIn
              ? OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthenticationBloc>().add(
                      const LogoutRequested(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        LoginBottomSheet.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text(
                        'Sign In (Bottom Sheet)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.login);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.fullscreen_rounded, size: 20),
                      label: const Text(
                        'Push Login Screen',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
