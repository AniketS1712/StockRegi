import 'package:flutter/material.dart';
import '../models/attribute_row_model.dart';
import '../models/category.dart';
import '../theme/app_spacing.dart';
import 'form_autocomplete_fields.dart';
import 'primary_action_button.dart';

class StockItemFormFields extends StatelessWidget {
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
  final TextEditingController unitPriceController;
  final String quantityLabel;

  const StockItemFormFields({
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
    required this.unitPriceController,
    this.quantityLabel = 'Quantity *',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        QuantityPriceRow(
          quantityController: quantityController,
          unitPriceController: unitPriceController,
          quantityLabel: quantityLabel,
        ),
      ],
    );
  }
}

class StockEntryFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget? header;
  final Widget formFields;
  final String submitLabel;
  final bool isLoading;
  final VoidCallback onSubmit;

  const StockEntryFormBody({
    super.key,
    required this.formKey,
    this.header,
    required this.formFields,
    required this.submitLabel,
    required this.isLoading,
    required this.onSubmit,
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
            if (header != null) ...[
              header!,
              const SizedBox(height: AppSpacing.marginMobile),
            ],
            formFields,
            const SizedBox(height: AppSpacing.lg),
            PrimaryActionButton(
              label: submitLabel,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
