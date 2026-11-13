import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The visual style of an [InlineBanner].
enum BannerVariant { info, error }

/// A rounded container banner for inline messages (info or error).
///
/// Uses [AppColors.primaryContainer] for info and [AppColors.errorContainer]
/// for error variants.
class InlineBanner extends StatelessWidget {
  final String message;
  final BannerVariant variant;

  const InlineBanner({
    super.key,
    required this.message,
    this.variant = BannerVariant.info,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Color backgroundColor;
    final Color textColor;

    switch (variant) {
      case BannerVariant.info:
        backgroundColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
      case BannerVariant.error:
        backgroundColor = AppColors.errorContainer;
        textColor = AppColors.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        message,
        style: textTheme.labelSmall?.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
