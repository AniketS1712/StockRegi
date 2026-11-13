import 'package:flutter/material.dart';
import '../models/attribute_row_model.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'empty_state_card.dart';
import 'form_autocomplete_fields.dart';
import 'primary_action_button.dart';

class ConsumedItemRowModel {
  Item? selectedItem;
  final TextEditingController quantityController;

  ConsumedItemRowModel({
    this.selectedItem,
    required this.quantityController,
  });

  void dispose() {
    quantityController.dispose();
  }
}

class ProductionPartACard extends StatelessWidget {
  final List<Item> rawMaterialItems;
  final Map<String, double> stockMap;
  final List<ConsumedItemRowModel> consumedRows;
  final VoidCallback onAddConsumedRow;
  final ValueChanged<int> onRemoveConsumedRow;
  final void Function(int index, Item? item) onItemSelected;

  const ProductionPartACard({
    super.key,
    required this.rawMaterialItems,
    required this.stockMap,
    required this.consumedRows,
    required this.onAddConsumedRow,
    required this.onRemoveConsumedRow,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondaryContainer, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.precision_manufacturing_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Part A: Raw Material Used',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select raw materials consumed during this production run.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (rawMaterialItems.isEmpty) ...[
              const EmptyStateCard(
                message:
                    'No raw materials found. Purchase raw materials first before running production.',
              ),
            ] else ...[
              ...List.generate(consumedRows.length, (index) {
                final row = consumedRows[index];
                final availableStock = row.selectedItem != null
                    ? (stockMap[row.selectedItem!.id] ?? 0.0)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<Item>(
                          initialValue: row.selectedItem,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Raw Material *',
                            helperText: row.selectedItem != null
                                ? 'In stock: ${availableStock.toStringAsFixed(1)} ${row.selectedItem!.unit}'
                                : null,
                          ),
                          items: rawMaterialItems.map((item) {
                            return DropdownMenuItem<Item>(
                              value: item,
                              child: Text(
                                '${item.name} (${item.unit})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => onItemSelected(index, val),
                          validator: (val) =>
                              val == null ? 'Select material' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gutterMobile),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: row.quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(labelText: 'Qty Used *'),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Qty required';
                            }
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                      if (consumedRows.length > 1)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => onRemoveConsumedRow(index),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onAddConsumedRow,
                icon: const Icon(Icons.add),
                label: const Text('Add Consumed Material'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProductionTransformDivider extends StatelessWidget {
  const ProductionTransformDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1.5)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TRANSFORMS INTO',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: AppColors.onPrimaryContainer,
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(thickness: 1.5)),
        ],
      ),
    );
  }
}

class ProductionPartBCard extends StatelessWidget {
  final TextEditingController categoryController;
  final List<Category> categories;
  final Category? matchedCategory;
  final VoidCallback onCategoryChanged;

  final List<AttributeRowModel> attributeRows;
  final Set<String> knownKeyNames;
  final VoidCallback onAddAttribute;
  final ValueChanged<int> onRemoveAttribute;
  final VoidCallback onAttributeChanged;

  final TextEditingController itemNameController;
  final TextEditingController unitController;
  final List<String> existingUnits;
  final TextEditingController quantityController;

  const ProductionPartBCard({
    super.key,
    required this.categoryController,
    required this.categories,
    required this.matchedCategory,
    required this.onCategoryChanged,
    required this.attributeRows,
    required this.knownKeyNames,
    required this.onAddAttribute,
    required this.onRemoveAttribute,
    required this.onAttributeChanged,
    required this.itemNameController,
    required this.unitController,
    required this.existingUnits,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Part B: Stock Produced',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Specify the finished good item and quantity produced.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CategoryAutocompleteField(
              controller: categoryController,
              categories: categories,
              matchedCategory: matchedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            AttributesSectionWidget(
              attributeRows: attributeRows,
              knownKeyNames: knownKeyNames,
              onAddAttribute: onAddAttribute,
              onRemoveAttribute: onRemoveAttribute,
              onChanged: onAttributeChanged,
            ),
            TextFormField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name *'),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Item name required' : null,
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            UnitAutocompleteField(
              controller: unitController,
              existingUnits: existingUnits,
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            TextFormField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(labelText: 'Quantity Produced *'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Quantity required';
                }
                final parsed = double.tryParse(val.trim());
                if (parsed == null || parsed <= 0) return 'Must be > 0';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductionFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;

  final List<Item> rawMaterialItems;
  final Map<String, double> stockMap;
  final List<ConsumedItemRowModel> consumedRows;
  final VoidCallback onAddConsumedRow;
  final ValueChanged<int> onRemoveConsumedRow;
  final void Function(int index, Item? item) onItemSelected;

  final TextEditingController categoryController;
  final List<Category> categories;
  final Category? matchedCategory;
  final VoidCallback onCategoryChanged;
  final List<AttributeRowModel> attributeRows;
  final Set<String> knownKeyNames;
  final VoidCallback onAddAttribute;
  final ValueChanged<int> onRemoveAttribute;
  final VoidCallback onAttributeChanged;
  final TextEditingController itemNameController;
  final TextEditingController unitController;
  final List<String> existingUnits;
  final TextEditingController quantityController;

  const ProductionFormBody({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
    required this.rawMaterialItems,
    required this.stockMap,
    required this.consumedRows,
    required this.onAddConsumedRow,
    required this.onRemoveConsumedRow,
    required this.onItemSelected,
    required this.categoryController,
    required this.categories,
    required this.matchedCategory,
    required this.onCategoryChanged,
    required this.attributeRows,
    required this.knownKeyNames,
    required this.onAddAttribute,
    required this.onRemoveAttribute,
    required this.onAttributeChanged,
    required this.itemNameController,
    required this.unitController,
    required this.existingUnits,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductionPartACard(
              rawMaterialItems: rawMaterialItems,
              stockMap: stockMap,
              consumedRows: consumedRows,
              onAddConsumedRow: onAddConsumedRow,
              onRemoveConsumedRow: onRemoveConsumedRow,
              onItemSelected: onItemSelected,
            ),
            const ProductionTransformDivider(),
            ProductionPartBCard(
              categoryController: categoryController,
              categories: categories,
              matchedCategory: matchedCategory,
              onCategoryChanged: onCategoryChanged,
              attributeRows: attributeRows,
              knownKeyNames: knownKeyNames,
              onAddAttribute: onAddAttribute,
              onRemoveAttribute: onRemoveAttribute,
              onAttributeChanged: onAttributeChanged,
              itemNameController: itemNameController,
              unitController: unitController,
              existingUnits: existingUnits,
              quantityController: quantityController,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryActionButton(
              label: 'Record Production',
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
