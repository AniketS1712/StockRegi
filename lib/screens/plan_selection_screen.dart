import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/stockregi_app_bar.dart';

class PlanSelectionScreen extends ConsumerStatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  ConsumerState<PlanSelectionScreen> createState() =>
      _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final isProducer = business?.role == 'producer';

    final planTitle = isProducer ? 'Producer Pro' : 'Seller Pro';
    final planSubtitle = isProducer
        ? 'Full inventory control, atomic production runs & raw material tracking'
        : 'Complete retail inventory management, product listing & order fulfillment';
    final planIcon = isProducer
        ? Icons.precision_manufacturing_rounded
        : Icons.storefront_rounded;

    final price = _isYearly
        ? (isProducer ? '\$29' : '\$15')
        : (isProducer ? '\$39' : '\$19');
    final period = _isYearly ? '/ month (billed yearly)' : '/ month';
    final savingsLabel = _isYearly ? 'Save 25%' : null;

    final features = isProducer
        ? const [
            'Raw materials & finished goods tracking',
            'Atomic multi-item production runs',
            'Automated stock conversion & yield monitoring',
            'Non-negative inventory safeguards',
            'Full transaction & audit log',
            'Multi-attribute category customization',
          ]
        : const [
            'Unlimited stock items & variants',
            'Instant customer order creation',
            'Real-time low stock indicators',
            'Purchase stock tracking with raw/finished flags',
            'Full transaction & order history',
            'Multi-attribute category customization',
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: StockRegiAppBar(
        stepText: 'Step 3 of 3',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unlock Your Full Potential',
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Simple, predictable pricing tailored for your business role.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Monthly / Yearly Billing Toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isYearly = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isYearly
                                ? AppColors.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            boxShadow: !_isYearly
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Monthly',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: !_isYearly
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !_isYearly
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isYearly = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isYearly
                                ? AppColors.surfaceContainerLowest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            boxShadow: _isYearly
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Yearly',
                                style: TextStyle(
                                  fontWeight: _isYearly
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _isYearly
                                      ? AppColors.onSurface
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (savingsLabel != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    savingsLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Plan Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  side: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: Icon(
                              planIcon,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planTitle,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  planSubtitle,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(color: AppColors.outlineVariant, height: 1),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            period,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Actions
              PrimaryActionButton(
                label: 'Continue',
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
