import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/inline_banner.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/selectable_role_card.dart';
import '../widgets/stockregi_app_bar.dart';

class ChooseRoleScreen extends ConsumerStatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  ConsumerState<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends ConsumerState<ChooseRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  String _selectedRole = 'seller';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _submitBusiness() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final businessName = _businessNameController.text.trim();

    try {
      await Supabase.instance.client.from('businesses').insert({
        'owner_id': user.id,
        'name': businessName,
        'role': _selectedRole,
      });

      ref.invalidate(currentBusinessProvider);
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        setState(() {
          if (errStr.contains('23505') ||
              errStr.contains('unique') ||
              errStr.contains('duplicate')) {
            _errorMessage = 'That business name is already taken, try another';
          } else {
            _errorMessage = 'Failed to set role: $e';
          }
        });
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
      appBar: const StockRegiAppBar(stepText: 'Step 2 of 2'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Set up your business',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Let's configure your digital register tailored to how your business works.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Field 1: Business Name Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Business or Shop Name ',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          children: const [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Sharma Traders',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Business name is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 15,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'This name will also serve as your login username identifier.',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Section 2: Choose Business Role
                Text(
                  'Select your primary role *',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose the option that best matches your daily operations.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                SelectableRoleCard(
                  icon: Icons.storefront_rounded,
                  title: "I'm a Seller",
                  tag: 'RETAIL / WHOLESALE',
                  description:
                      'Buy stock from vendors & sell directly to customers or businesses.',
                  isSelected: _selectedRole == 'seller',
                  onTap: () => setState(() => _selectedRole = 'seller'),
                ),
                const SizedBox(height: AppSpacing.sm),

                SelectableRoleCard(
                  icon: Icons.factory_rounded,
                  title: "I'm a Producer",
                  tag: 'MANUFACTURER',
                  description:
                      'Buy raw materials, manufacture products & track inventory yields.',
                  isSelected: _selectedRole == 'producer',
                  onTap: () => setState(() => _selectedRole = 'producer'),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  InlineBanner(
                    message: _errorMessage!,
                    variant: BannerVariant.error,
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                PrimaryActionButton(
                  label: 'Continue',
                  isLoading: _isLoading,
                  onPressed: _submitBusiness,
                ),

                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
