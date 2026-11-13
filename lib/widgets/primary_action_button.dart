import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An [ElevatedButton] that shows a small spinner when [isLoading] is true.
///
/// [onPressed] is ignored while loading. [label] is the text shown when idle.
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            )
          : Text(label),
    );
  }
}
