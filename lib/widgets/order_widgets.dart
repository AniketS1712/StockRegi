import 'package:flutter/material.dart';
import '../models/stock_level.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/format_utils.dart';
import 'order_line_card.dart';
import 'primary_action_button.dart';
import 'stock_picker_chip.dart';

class OrderLineState {
  final StockLevel stockLevel;
  final TextEditingController qtyController;
  final TextEditingController unitPriceController;

  OrderLineState({
    required this.stockLevel,
    required this.qtyController,
    required this.unitPriceController,
  });

  void dispose() {
    qtyController.dispose();
    unitPriceController.dispose();
  }
}

class OrderSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const OrderSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search Items',
          hintText: 'Search items to add...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class OrderStockPicker extends StatelessWidget {
  final List<StockLevel> filteredStock;
  final Map<String, OrderLineState> selectedItems;
  final ValueChanged<StockLevel> onToggleItem;

  const OrderStockPicker({
    super.key,
    required this.filteredStock,
    required this.selectedItems,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      child: filteredStock.isEmpty
          ? Center(
              child: Text(
                'No matching items found',
                style: textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredStock.length,
              itemBuilder: (context, index) {
                final stock = filteredStock[index];
                final itemName = stock.item?.name ?? 'Unknown Item';
                final unit = stock.item?.unit ?? '';
                final qtyAvailable = stock.quantity;

                return StockPickerChip(
                  itemName: itemName,
                  stockInfo:
                      '${FormatUtils.formatQuantity(qtyAvailable)} $unit in stock',
                  isSelected: selectedItems.containsKey(stock.itemId),
                  onSelected: () => onToggleItem(stock),
                );
              },
            ),
    );
  }
}

class OrderSelectedItemsList extends StatelessWidget {
  final Map<String, OrderLineState> selectedItems;
  final ValueChanged<StockLevel> onRemoveItem;

  const OrderSelectedItemsList({
    super.key,
    required this.selectedItems,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (selectedItems.isEmpty) {
      return Center(
        child: Text(
          'Select items from above to create an order',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: selectedItems.entries.map((entry) {
        final line = entry.value;
        return OrderLineCard(
          itemName: line.stockLevel.item?.name ?? 'Item',
          unit: line.stockLevel.item?.unit ?? '',
          qtyController: line.qtyController,
          unitPriceController: line.unitPriceController,
          onRemove: () => onRemoveItem(line.stockLevel),
        );
      }).toList(),
    );
  }
}

class OrderSubmitFooter extends StatelessWidget {
  final int itemCount;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const OrderSubmitFooter({
    super.key,
    required this.itemCount,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        child: PrimaryActionButton(
          label: 'Submit Order ($itemCount items)',
          isLoading: isLoading,
          onPressed: itemCount == 0 ? null : onSubmit,
        ),
      ),
    );
  }
}
