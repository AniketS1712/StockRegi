import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attribute_row_model.dart';
import '../models/stock_form_state.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../providers/repository_providers.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/form_autocomplete_fields.dart';
import '../widgets/stock_item_form_fields.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  final String businessId;

  const PurchaseScreen({
    super.key,
    this.businessId = '00000000-0000-0000-0000-000000000000',
  });

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formState = StockFormState();

  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isRawMaterial = true;

  @override
  void initState() {
    super.initState();
    _formState.categoryController.addListener(_onCategoryTextChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _formState.categoryController.removeListener(_onCategoryTextChanged);
    _formState.dispose();
    super.dispose();
  }

  String get _effectiveBusinessId {
    if (widget.businessId != '00000000-0000-0000-0000-000000000000' && widget.businessId.isNotEmpty) {
      return widget.businessId;
    }
    return ref.read(currentBusinessProvider).valueOrNull?.id ?? widget.businessId;
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitialLoading = true);
    final busId = _effectiveBusinessId;
    try {
      await _formState.loadInitialData(
        businessId: busId,
        categoryRepo: ref.read(categoryRepositoryProvider),
        itemRepo: ref.read(itemRepositoryProvider),
        attributeKeyRepo: ref.read(attributeKeyRepositoryProvider),
      );
    } catch (_) {} finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _onCategoryTextChanged() async {
    await _formState.updateCategoryMatch(
      attributeKeyRepo: ref.read(attributeKeyRepositoryProvider),
      stockRepo: ref.read(stockRepositoryProvider),
    );
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    final categoryName = _formState.categoryController.text.trim();
    final itemName = _formState.itemNameController.text.trim();
    final unit = _formState.unitController.text.trim();
    final quantity = double.tryParse(_formState.quantityController.text.trim()) ?? 0;
    final unitPrice = double.tryParse(_formState.unitPriceController.text.trim());
    final busId = _effectiveBusinessId;

    final error = AttributeRowModel.validateStockForm(
      isValid: isValid,
      categoryName: categoryName,
      itemName: itemName,
      unit: unit,
      quantity: quantity,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final item = await AttributeRowModel.recordPurchaseItem(
        businessId: busId,
        categoryName: categoryName,
        itemName: itemName,
        unit: unit,
        isRawMaterial: _isRawMaterial,
        quantity: quantity,
        unitPrice: unitPrice,
        attributeRows: _formState.attributeRows,
        categoryRepo: ref.read(categoryRepositoryProvider),
        attributeKeyRepo: ref.read(attributeKeyRepositoryProvider),
        itemRepo: ref.read(itemRepositoryProvider),
        transactionRepo: ref.read(transactionRepositoryProvider),
      );

      ref.invalidate(stockLevelsProvider(busId));
      ref.invalidate(categoriesProvider(busId));
      ref.invalidate(itemsProvider(busId));
      ref.invalidate(recentActivityProvider(busId));

      if (mounted) {
        final typeLabel = _isRawMaterial ? 'raw material' : 'finished good';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchased "${item.name}" as $typeLabel successfully!')),
        );
        _formKey.currentState?.reset();
        _formState.reset();
        _isRawMaterial = true;
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to record purchase: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) return const Scaffold(body: Center(child: AppLoadingIndicator()));
    final existingUnits = _formState.existingItems.map((i) => i.unit).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Text('Purchase Stock', style: Theme.of(context).textTheme.headlineMedium)),
      body: StockEntryFormBody(
        formKey: _formKey,
        submitLabel: 'Record Purchase',
        isLoading: _isLoading,
        onSubmit: _submit,
        formFields: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItemTypeToggle(
              isRawMaterial: _isRawMaterial,
              onTypeChanged: (val) => setState(() => _isRawMaterial = val),
            ),
            const SizedBox(height: 16),
            StockItemFormFields(
              categoryController: _formState.categoryController,
              categories: _formState.categories,
              matchedCategory: _formState.matchedCategory,
              onCategoryChanged: _onCategoryTextChanged,
              attributeRows: _formState.attributeRows,
              knownKeyNames: _formState.knownKeyNames,
              onAddAttribute: () => setState(() => _formState.addAttributeRow()),
              onRemoveAttribute: (i) => setState(() => _formState.removeAttributeRow(i)),
              onAttributeChanged: () => setState(() {}),
              itemNameController: _formState.itemNameController,
              unitController: _formState.unitController,
              existingUnits: existingUnits,
              quantityController: _formState.quantityController,
              unitPriceController: _formState.unitPriceController,
            ),
          ],
        ),
      ),
    );
  }
}
