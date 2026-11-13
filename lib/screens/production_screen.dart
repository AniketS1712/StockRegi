import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attribute_row_model.dart';
import '../models/production_form_state.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../providers/repository_providers.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/production_cards.dart';

class ProductionScreen extends ConsumerStatefulWidget {
  final String businessId;

  const ProductionScreen({
    super.key,
    this.businessId = '00000000-0000-0000-0000-000000000000',
  });

  @override
  ConsumerState<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends ConsumerState<ProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formState = ProductionFormState();

  bool _isLoading = false;
  bool _isInitialLoading = true;

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
        itemRepo: ref.read(itemRepositoryProvider),
        categoryRepo: ref.read(categoryRepositoryProvider),
        attributeKeyRepo: ref.read(attributeKeyRepositoryProvider),
        stockRepo: ref.read(stockRepositoryProvider),
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
    final error = _formState.validateForm(isValid);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final categoryName = _formState.categoryController.text.trim();
    final producedItemName = _formState.itemNameController.text.trim();
    final unit = _formState.unitController.text.trim();
    final producedQuantity = double.tryParse(_formState.quantityController.text.trim()) ?? 0;
    final busId = _effectiveBusinessId;

    setState(() => _isLoading = true);

    try {
      final consumedInputs = _formState.consumedRows.map((r) => ProductionItemInput(
        itemId: r.selectedItem!.id,
        quantity: double.parse(r.quantityController.text.trim()),
      )).toList();

      final producedItem = await AttributeRowModel.recordProductionRun(
        businessId: busId,
        consumed: consumedInputs,
        categoryName: categoryName,
        producedItemName: producedItemName,
        unit: unit,
        producedQuantity: producedQuantity,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recorded production of $producedQuantity $unit of "${producedItem.name}"!')),
        );
        _formKey.currentState?.reset();
        _formState.reset();
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        final raw = e.toString();
        final stockMatch = RegExp(r'Not enough (.+?) in stock', caseSensitive: false).firstMatch(raw);
        final userMessage = stockMatch != null
            ? 'Not enough ${stockMatch.group(1)} in stock. Purchase more before running production.'
            : 'Failed to record production: $e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(userMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) return const Scaffold(body: Center(child: AppLoadingIndicator()));
    final existingUnits = _formState.existingItems.map((i) => i.unit).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Text('Record Production', style: Theme.of(context).textTheme.headlineMedium)),
      body: ProductionFormBody(
        formKey: _formKey,
        isLoading: _isLoading,
        onSubmit: _submit,
        rawMaterialItems: _formState.rawMaterialItems,
        stockMap: _formState.stockMap,
        consumedRows: _formState.consumedRows,
        onAddConsumedRow: () => setState(() => _formState.addConsumedRow()),
        onRemoveConsumedRow: (i) => setState(() => _formState.removeConsumedRow(i)),
        onItemSelected: (i, item) => setState(() => _formState.consumedRows[i].selectedItem = item),
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
      ),
    );
  }
}
