import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A horizontal ChoiceChip showing item name and stock availability.
///
/// [itemName] is the display name, [stockInfo] is the secondary line
/// (e.g. "10 kg in stock"). [isSelected] and [onSelected] control the chip.
class StockPickerChip extends StatelessWidget {
  final String itemName;
  final String stockInfo;
  final bool isSelected;
  final VoidCallback? onSelected;

  const StockPickerChip({
    super.key,
    required this.itemName,
    required this.stockInfo,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.base),
      child: ChoiceChip(
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(itemName, style: textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(stockInfo, style: textTheme.labelSmall),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onSelected?.call(),
      ),
    );
  }
}
