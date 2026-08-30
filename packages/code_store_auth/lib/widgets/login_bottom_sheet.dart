import 'dart:io';

import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import '../login_bloc/login_bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A modern, customizable bottom sheet login widget for contextual authentication.
///
/// Designed to be triggered anywhere in user flows (e.g. before taking an action)
/// rather than forcing a full-screen login upfront.
class LoginBottomSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? headerIcon;
  final VoidCallback? onLoginSuccess;
  final void Function(String message, {bool isError})? onShowToast;
  final Color? backgroundColor;
  final bool autoPopOnSuccess;
  final LoginBloc? loginBloc;
  final AuthenticationBloc? authenticationBloc;

  const LoginBottomSheet({
    super.key,
    this.title = 'Sign in to continue',
    this.subtitle,
    this.headerIcon,
    this.onLoginSuccess,
    this.onShowToast,
    this.backgroundColor,
    this.autoPopOnSuccess = true,
    this.loginBloc,
    this.authenticationBloc,
  });

  /// Static helper to display the [LoginBottomSheet] as a modal bottom sheet.
  ///
  /// Returns `true` if authentication succeeded and the sheet was popped.
  static Future<bool> show(
    BuildContext context, {
    String title = 'Sign in to continue',
    String? subtitle,
    Widget? headerIcon,
    VoidCallback? onLoginSuccess,
    void Function(String message, {bool isError})? onShowToast,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    bool autoPopOnSuccess = true,
    LoginBloc? loginBloc,
    AuthenticationBloc? authenticationBloc,
  }) async {
    bool didAuthenticate = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (sheetContext) {
        return LoginBottomSheet(
          title: title,
          subtitle: subtitle,
          headerIcon: headerIcon,
          backgroundColor: backgroundColor,
          autoPopOnSuccess: autoPopOnSuccess,
          loginBloc: loginBloc,
          authenticationBloc: authenticationBloc,
          onLoginSuccess: () {
            didAuthenticate = true;
            onLoginSuccess?.call();
          },
          onShowToast: onShowToast,
        );
      },
    );

    return didAuthenticate;
  }

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _notify(String message, {bool isError = false}) {
    if (widget.onShowToast != null) {
      widget.onShowToast!(message, isError: isError);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  LoginBloc? _getLoginBloc(BuildContext context) {
    if (widget.loginBloc != null) return widget.loginBloc;
    try {
      return context.read<LoginBloc>();
    } catch (_) {
      return null;
    }
  }

  AuthenticationBloc? _getAuthBloc(BuildContext context) {
    if (widget.authenticationBloc != null) return widget.authenticationBloc;
    try {
      return context.read<AuthenticationBloc>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = widget.backgroundColor ??
        (isDark ? colors.surfaceContainerHigh : colors.surface);

    final authBloc = _getAuthBloc(context);
    final loginBloc = _getLoginBloc(context);

    Widget content = Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHeader(theme, colors),
              const SizedBox(height: 24),
              _buildEmailForm(theme, colors, loginBloc),
              const SizedBox(height: 20),
              _buildDivider(theme, colors),
              const SizedBox(height: 20),
              _buildSocialButtons(theme, colors, loginBloc),
            ],
          ),
        ),
      ),
    );

    if (loginBloc != null) {
      content = BlocListener<LoginBloc, LoginState>(
        bloc: loginBloc,
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.failure &&
              state.errorMessage != null) {
            _notify(state.errorMessage!, isError: true);
          }
        },
        child: content,
      );
    }

    if (authBloc != null) {
      content = BlocListener<AuthenticationBloc, AuthenticationBlocState>(
        bloc: authBloc,
        listener: (context, state) {
          if (state.status == AuthenticationStatus.authenticated &&
              state.user.isNotEmpty) {
            widget.onLoginSuccess?.call();
            if (widget.autoPopOnSuccess && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.headerIcon != null) ...[
              widget.headerIcon!,
              const SizedBox(width: 10),
            ] else ...[
              Icon(
                Icons.lock_person_rounded,
                color: colors.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle ??
              'Sign in or create an account to continue and sync your data.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(
    ThemeData theme,
    ColorScheme colors,
    LoginBloc? loginBloc,
  ) {
    Widget formContent(bool isLoading) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Email',
                icon: Icons.email_outlined,
                colors: colors,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!v.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onChanged: (v) {
                loginBloc?.add(LoginEmailChanged(v));
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                colors: colors,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter your password';
                }
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onChanged: (v) {
                loginBloc?.add(LoginPasswordChanged(v));
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _handleEmailContinue(context, loginBloc),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor:
                      colors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: colors.onPrimary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Continue with Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    if (loginBloc != null) {
      return BlocBuilder<LoginBloc, LoginState>(
        bloc: loginBloc,
        builder: (context, state) {
          final isLoading = state.status == FormzSubmissionStatus.inProgress;
          return formContent(isLoading);
        },
      );
    }

    return formContent(false);
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required ColorScheme colors,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colors.onSurfaceVariant, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.8),
      ),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildDivider(ThemeData theme, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(
    ThemeData theme,
    ColorScheme colors,
    LoginBloc? loginBloc,
  ) {
    final showApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    return Column(
      children: [
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          iconColor: Colors.redAccent,
          iconSize: 28,
          label: 'Continue with Google',
          onTap: () {
            loginBloc?.add(const LoginWithGoogle());
          },
        ),
        if (showApple) ...[
          const SizedBox(height: 12),
          _SocialButton(
            icon: Icons.apple_rounded,
            iconColor: colors.onSurface,
            iconSize: 22,
            label: 'Continue with Apple',
            onTap: () {
              loginBloc?.add(const LoginWithApple());
            },
          ),
        ],
      ],
    );
  }

  void _handleEmailContinue(BuildContext context, LoginBloc? loginBloc) {
    if (_formKey.currentState?.validate() ?? false) {
      loginBloc?.add(
        ContinueWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        ),
      );
    }
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.iconColor,
    this.iconSize = 24,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: iconSize),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              colors.surfaceContainerHighest.withValues(alpha: 0.25),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Convenience top-level function to trigger the bottom sheet login flow.
Future<bool> showLoginBottomSheet(
  BuildContext context, {
  String title = 'Sign in to continue',
  String? subtitle,
  Widget? headerIcon,
  VoidCallback? onLoginSuccess,
  void Function(String message, {bool isError})? onShowToast,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  bool autoPopOnSuccess = true,
  LoginBloc? loginBloc,
  AuthenticationBloc? authenticationBloc,
}) {
  return LoginBottomSheet.show(
    context,
    title: title,
    subtitle: subtitle,
    headerIcon: headerIcon,
    onLoginSuccess: onLoginSuccess,
    onShowToast: onShowToast,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    autoPopOnSuccess: autoPopOnSuccess,
    loginBloc: loginBloc,
    authenticationBloc: authenticationBloc,
  );
}
