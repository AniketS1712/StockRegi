import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/inline_banner.dart';
import '../widgets/password_form_field.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/stockregi_app_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String?> _resolveEmail(String username) async {
    for (final paramKey in ['input_username', 'p_username', 'username']) {
      try {
        final res = await Supabase.instance.client.rpc(
          'get_email_for_username',
          params: {paramKey: username},
        );
        if (res is String && res.isNotEmpty) return res;
        if (res is Map && res['email'] != null) return res['email'] as String;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final resolvedEmail = await _resolveEmail(username);
      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        throw Exception('User not found');
      }

      await Supabase.instance.client.auth.signInWithPassword(
        email: resolvedEmail,
        password: password,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Incorrect username or password');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const StockRegiAppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Log in to StockRegi',
                        style: textTheme.headlineLarge?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username (Business Name)',
                          hintText: 'e.g. My Store',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Username is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.marginMobile),
                      PasswordFormField(
                        controller: _passwordController,
                        showVisibilityToggle: false,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Password is required'
                            : null,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        InlineBanner(
                          message: _errorMessage!,
                          variant: BannerVariant.error,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryActionButton(
                        label: 'Log in',
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/signup'),
                            child: Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
