import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A header row displaying the selected item count with an optional
/// "Clear All" action button.
class SelectedItemsHeader extends StatelessWidget {
  final int count;
  final VoidCallback? onClearAll;

  const SelectedItemsHeader({
    super.key,
    required this.count,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Selected Items ($count)', style: textTheme.labelLarge),
          if (count > 0 && onClearAll != null)
            TextButton(
              onPressed: onClearAll,
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }
}
