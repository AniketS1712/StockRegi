import 'package:flutter/material.dart';
import '../models/attribute_row_model.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'attribute_row_widget.dart';
import 'new_badge.dart';
import 'section_label.dart';

class ItemTypeToggle extends StatelessWidget {
  final bool isRawMaterial;
  final ValueChanged<bool> onTypeChanged;

  const ItemTypeToggle({
    super.key,
    required this.isRawMaterial,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Item Type *'),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('Raw Material'),
              icon: Icon(Icons.precision_manufacturing_outlined),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('Finished Good'),
              icon: Icon(Icons.inventory_2_outlined),
            ),
          ],
          selected: {isRawMaterial},
          onSelectionChanged: (Set<bool> newSelection) {
            onTypeChanged(newSelection.first);
          },
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.onPrimary;
              }
              return AppColors.onSurfaceVariant;
            }),
          ),
        ),
      ],
    );
  }
}

class CategoryAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final List<Category> categories;
  final Category? matchedCategory;
  final VoidCallback onCategoryChanged;

  const CategoryAutocompleteField({
    super.key,
    required this.controller,
    required this.categories,
    required this.matchedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showNewBadge =
        controller.text.trim().isNotEmpty && matchedCategory == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Category *'),
        const SizedBox(height: AppSpacing.xs),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: controller.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) {
              return categories.map((c) => c.name);
            }
            return categories
                .map((c) => c.name)
                .where((name) => name.toLowerCase().contains(query));
          },
          onSelected: (String selection) {
            controller.text = selection;
            onCategoryChanged();
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Select or type new category',
                suffixIcon: showNewBadge ? const NewBadge() : null,
              ),
              onChanged: (val) {
                controller.text = val;
                onCategoryChanged();
              },
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Category required' : null,
            );
          },
        ),
      ],
    );
  }
}

class UnitAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> existingUnits;

  const UnitAutocompleteField({
    super.key,
    required this.controller,
    required this.existingUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Unit *'),
        const SizedBox(height: AppSpacing.xs),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: controller.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) return existingUnits;
            return existingUnits.where(
              (u) => u.toLowerCase().contains(query),
            );
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g. kg, pcs, liters, box',
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Unit required' : null,
              onChanged: (val) {
                controller.text = val;
              },
            );
          },
        ),
      ],
    );
  }
}

class AttributesSectionWidget extends StatelessWidget {
  final List<AttributeRowModel> attributeRows;
  final Set<String> knownKeyNames;
  final VoidCallback onAddAttribute;
  final ValueChanged<int> onRemoveAttribute;
  final VoidCallback onChanged;

  const AttributesSectionWidget({
    super.key,
    required this.attributeRows,
    required this.knownKeyNames,
    required this.onAddAttribute,
    required this.onRemoveAttribute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (attributeRows.isNotEmpty) ...[
          const SectionLabel('Category Attributes'),
          const SizedBox(height: AppSpacing.base),
          ...List.generate(attributeRows.length, (index) {
            final row = attributeRows[index];
            return AttributeRowWidget(
              keyController: row.keyController,
              valueController: row.valueController,
              isPredefined: row.isPredefined,
              knownKeyNames: knownKeyNames,
              valueSuggestions: row.valueSuggestions,
              onChanged: onChanged,
              onRemove:
                  row.isPredefined ? null : () => onRemoveAttribute(index),
            );
          }),
        ],
        OutlinedButton.icon(
          onPressed: onAddAttribute,
          icon: const Icon(Icons.add),
          label: const Text('Add Attribute'),
        ),
        const SizedBox(height: AppSpacing.marginMobile),
      ],
    );
  }
}

class QuantityPriceRow extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final String quantityLabel;
  final String unitPriceLabel;

  const QuantityPriceRow({
    super.key,
    required this.quantityController,
    required this.unitPriceController,
    this.quantityLabel = 'Quantity *',
    this.unitPriceLabel = 'Unit Price',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(labelText: quantityLabel),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Qty required';
              }
              final parsed = double.tryParse(val.trim());
              if (parsed == null || parsed <= 0) return 'Must be > 0';
              return null;
            },
          ),
        ),
        const SizedBox(width: AppSpacing.gutterMobile),
        Expanded(
          child: TextFormField(
            controller: unitPriceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(labelText: unitPriceLabel),
          ),
        ),
      ],
    );
  }
}
