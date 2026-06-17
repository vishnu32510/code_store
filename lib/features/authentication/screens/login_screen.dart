import 'dart:io';

import '../../../core/config/routes.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/services_barrel.dart';
import '../../../core/utils/app_constants.dart';
import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import '../login_bloc/login_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isSmallScreen = size.width < 600;

    return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
      listener: (context, state) {
        setState(() => _isLoading = false);

        if (state.status == AuthenticationStatus.authenticated &&
            state.user.isNotEmpty) {
          context.go(AppRoutes.dashboard);
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          setState(
            () => _isLoading = state.status == FormzSubmissionStatus.inProgress,
          );

          if (state.status == FormzSubmissionStatus.failure &&
              state.errorMessage != null) {
            getIt<IToastService>().showError(state.errorMessage!);
          }
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to dashboard',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo and app name
                        _buildLogoSection(context, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 18 : 24),

                        // Form section
                        _buildFormSection(context, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // iOS: email + Google + Apple; other platforms: email + Google
                        (!kIsWeb && Platform.isIOS)
                            ? _buildRoundedSocialLoginButtonsForiOS(
                              context,
                              isSmallScreen,
                            )
                            : _buildSocialLoginButtonsForOtherPlatforms(
                              context,
                              isSmallScreen,
                            ),

                        const SizedBox(height: 24),

                        _buildTermsSection(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, bool isSmallScreen) {
    final size = MediaQuery.of(context).size;
    final logoSize = isSmallScreen ? size.width * 0.22 : size.width * 0.12;
    final theme = Theme.of(context);

    return Column(
      children: [
        Hero(tag: 'app_logo', child: CustomAnimatedLogo(size: logoSize)),
        const SizedBox(height: 18),
        Text(
          AppConstants.appDisplayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Code · Release · Maintain',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final formWidth = isSmallScreen ? size.width : size.width * 0.44;

    return Container(
      width: formWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'your.email@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator:
                  (v) =>
                      (v == null || !v.contains('@'))
                          ? 'Please enter a valid email'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              validator:
                  (v) =>
                      (v == null || v.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () => _handleLogin(context, LoginMethod.email),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.6,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Continue with Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtonsForOtherPlatforms(
    BuildContext context,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final buttonWidth = isSmallScreen ? size.width : size.width * 0.44;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: buttonWidth,
          child: _buildLoginButton(
            context,
            'Continue with Google',
            Icons.g_mobiledata,
            Colors.red,
            () => _handleLogin(context, LoginMethod.google),
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
            textColor: theme.colorScheme.onSurface,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildRoundedSocialLoginButtonsForiOS(
    BuildContext context,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconOnlyButton(
              context,
              Icons.g_mobiledata,
              Colors.red,
              () => _handleLogin(context, LoginMethod.google),
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 16),
            _buildIconOnlyButton(
              context,
              Icons.apple,
              theme.colorScheme.onSurface,
              () => _handleLogin(context, LoginMethod.apple),
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconOnlyButton(
    BuildContext context,
    IconData icon,
    Color iconColor,
    VoidCallback onPressed, {
    required Color backgroundColor,
    required Color? borderColor,
  }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side:
                borderColor != null
                    ? BorderSide(color: borderColor)
                    : BorderSide.none,
          ),
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.7),
        ),
        child: Icon(
          icon,
          color: _isLoading ? iconColor.withValues(alpha: 0.7) : iconColor,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    final link = AppConstants.termsUrl;
                    if (link.isEmpty) return;
                    getIt<OpenLinkService>().openUrl(link: link);
                  },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    final link = AppConstants.privacyPolicyUrl;
                    if (link.isEmpty) return;
                    getIt<OpenLinkService>().openUrl(link: link);
                  },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    String text,
    IconData icon,
    Color iconColor,
    VoidCallback onPressed, {
    required Color backgroundColor,
    required Color? borderColor,
    required Color textColor,
    required bool isSmallScreen,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              borderColor != null
                  ? BorderSide(color: borderColor)
                  : BorderSide.none,
        ),
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.7),
        disabledForegroundColor: textColor.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _isLoading ? iconColor.withValues(alpha: 0.7) : iconColor,
            size: isSmallScreen ? 24 : 28,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(BuildContext context, LoginMethod method) {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final bloc = context.read<LoginBloc>();

    if (method == LoginMethod.google) {
      bloc.add(const LoginWithGoogle());
    } else if (method == LoginMethod.apple) {
      bloc.add(const LoginWithApple());
    } else if (method == LoginMethod.email) {
      if (_formKey.currentState?.validate() ?? false) {
        bloc.add(
          ContinueWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    }
  }
}

enum LoginMethod { email, google, apple }

class CustomAnimatedLogo extends StatefulWidget {
  const CustomAnimatedLogo({super.key, required this.size});
  final double size;

  @override
  State<CustomAnimatedLogo> createState() => _CustomAnimatedLogoState();
}

class _CustomAnimatedLogoState extends State<CustomAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159265,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6B8E5A), Color(0xFF4A7FA5), Color(0xFFD4A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B8E5A).withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.offline_bolt_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
