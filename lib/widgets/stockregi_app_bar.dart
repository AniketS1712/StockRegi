import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable branded top AppBar for auth, onboarding, and setup screens.
class StockRegiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? stepText;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  const StockRegiAppBar({
    super.key,
    this.stepText,
    this.leading,
    this.automaticallyImplyLeading = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            alignment: Alignment.center,
            child: const Text(
              'SR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'StockRegi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        if (stepText != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            alignment: Alignment.center,
            child: Text(
              stepText!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}
