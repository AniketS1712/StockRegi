import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/inline_banner.dart';
import '../widgets/password_form_field.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/stockregi_app_bar.dart';

enum SetPasswordMode { reset }

class SetPasswordScreen extends ConsumerStatefulWidget {
  final SetPasswordMode mode;

  const SetPasswordScreen({
    super.key,
    this.mode = SetPasswordMode.reset,
  });

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final password = _passwordController.text;

    try {
      final userAttributes = UserAttributes(
        password: password,
      );

      await Supabase.instance.client.auth.updateUser(userAttributes);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to set password: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                        'Set Your Password',
                        style: textTheme.headlineLarge?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Create a password to secure your account and log back in easily.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      PasswordFormField(
                        controller: _passwordController,
                        labelText: 'New Password',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Password is required';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (widget.mode == SetPasswordMode.reset) ...[
                        const SizedBox(height: AppSpacing.marginMobile),
                        PasswordFormField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        InlineBanner(
                          message: _errorMessage!,
                          variant: BannerVariant.error,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryActionButton(
                        label: 'Save Password',
                        isLoading: _isLoading,
                        onPressed: _submitPassword,
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
