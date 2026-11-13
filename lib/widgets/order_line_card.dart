import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A card for a single order line item with qty and price input fields.
///
/// [itemName] is shown as the title (with unit). [qtyController] and
/// [unitPriceController] are the text controllers for the input fields.
/// [onRemove] is called when the close button is tapped.
class OrderLineCard extends StatelessWidget {
  final String itemName;
  final String unit;
  final TextEditingController qtyController;
  final TextEditingController unitPriceController;
  final VoidCallback? onRemove;

  const OrderLineCard({
    super.key,
    required this.itemName,
    required this.unit,
    required this.qtyController,
    required this.unitPriceController,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$itemName ($unit)',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Order Qty *',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.gutterMobile),
                Expanded(
                  child: TextField(
                    controller: unitPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
