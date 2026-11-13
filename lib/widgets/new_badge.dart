import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A small rounded "new" badge for inline suffix indicators.
///
/// Used inside autocomplete fields to indicate that the typed value
/// doesn't match any existing entry.
class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          'new',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
