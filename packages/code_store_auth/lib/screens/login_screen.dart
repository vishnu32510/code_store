import 'dart:io';

import '../authentication_bloc/authentication_bloc.dart';
import '../authentication_enums.dart';
import '../login_bloc/login_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  final String appTitle;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onNavigateToSignup;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onPrivacyPolicy;
  final void Function(String message, {bool isError})? onShowToast;

  const LoginScreen({
    super.key,
    this.appTitle = 'Welcome Back',
    this.onLoginSuccess,
    this.onNavigateToSignup,
    this.onTermsOfService,
    this.onPrivacyPolicy,
    this.onShowToast,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (widget.onShowToast != null) {
      widget.onShowToast!(message, isError: isError);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
      listener: (context, authState) {
        if (authState.status == AuthenticationStatus.authenticated &&
            authState.user.isNotEmpty) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            _showNotification('Signed in successfully.');
          } else if (state.status == FormzSubmissionStatus.failure) {
            _showNotification(state.errorMessage ?? 'Sign in failed.', isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == FormzSubmissionStatus.inProgress;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.appTitle),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.appTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to sync your preferences and access all features.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Email Login Button
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    context.read<LoginBloc>().add(
                                          LoginWithEmailAndPassword(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign In with Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.outline,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Google Sign In
                        OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<LoginBloc>()
                                  .add(const LoginWithGoogle()),
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ...[
                          const SizedBox(height: 12),
                          // Apple Sign In
                          OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<LoginBloc>()
                                    .add(const LoginWithApple()),
                            icon: const Icon(Icons.apple_rounded, size: 24),
                            label: const Text('Continue with Apple'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
