import 'package:flutter/material.dart';
import '../models/attribute_row_model.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../repositories/attribute_key_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/stock_repository.dart';
import '../widgets/production_cards.dart';

class ProductionFormState {
  List<Item> rawMaterialItems = [];
  Map<String, double> stockMap = {};
  final List<ConsumedItemRowModel> consumedRows = [];

  final categoryController = TextEditingController();
  final itemNameController = TextEditingController();
  final unitController = TextEditingController();
  final quantityController = TextEditingController();

  List<Category> categories = [];
  List<Item> existingItems = [];
  Category? matchedCategory;
  final List<AttributeRowModel> attributeRows = [];
  final Set<String> knownKeyNames = {};

  void dispose() {
    categoryController.dispose();
    itemNameController.dispose();
    unitController.dispose();
    quantityController.dispose();
    for (final row in consumedRows) {
      row.dispose();
    }
    for (final row in attributeRows) {
      row.dispose();
    }
  }

  void reset() {
    categoryController.clear();
    itemNameController.clear();
    unitController.clear();
    quantityController.clear();
    matchedCategory = null;
    for (final row in consumedRows) {
      row.dispose();
    }
    consumedRows.clear();
    for (final row in attributeRows) {
      row.dispose();
    }
    attributeRows.clear();
  }

  void addConsumedRow() {
    if (rawMaterialItems.isEmpty) return;
    consumedRows.add(
      ConsumedItemRowModel(
        selectedItem: rawMaterialItems.first,
        quantityController: TextEditingController(),
      ),
    );
  }

  void removeConsumedRow(int index) {
    consumedRows.removeAt(index).dispose();
  }

  void addAttributeRow() {
    attributeRows.add(
      AttributeRowModel(
        keyController: TextEditingController(),
        valueController: TextEditingController(),
      ),
    );
  }

  void removeAttributeRow(int index) {
    attributeRows.removeAt(index).dispose();
  }

  Future<void> loadInitialData({
    required String businessId,
    required ItemRepository itemRepo,
    required CategoryRepository categoryRepo,
    required AttributeKeyRepository attributeKeyRepo,
    required StockRepository stockRepo,
  }) async {
    final rawItems = await itemRepo.getRawMaterialItems(businessId);
    final stockLevels = await stockRepo.getStockLevels(businessId);
    final formData = await AttributeRowModel.loadInitialFormData(
      businessId: businessId,
      categoryRepo: categoryRepo,
      itemRepo: itemRepo,
      attributeKeyRepo: attributeKeyRepo,
    );

    rawMaterialItems = rawItems;
    stockMap = {for (final s in stockLevels) s.itemId: s.quantity};
    categories = formData.categories;
    existingItems = formData.items;
    knownKeyNames.addAll(formData.knownKeyNames);

    if (consumedRows.isEmpty && rawMaterialItems.isNotEmpty) {
      consumedRows.add(
        ConsumedItemRowModel(
          selectedItem: rawMaterialItems.first,
          quantityController: TextEditingController(),
        ),
      );
    }
  }

  Future<void> updateCategoryMatch({
    required AttributeKeyRepository attributeKeyRepo,
    required StockRepository stockRepo,
  }) async {
    final text = categoryController.text.trim().toLowerCase();
    Category? match;
    for (final cat in categories) {
      if (cat.name.toLowerCase() == text) {
        match = cat;
        break;
      }
    }

    if (matchedCategory?.id == match?.id) return;
    matchedCategory = match;
    attributeRows.removeWhere((row) => row.isPredefined);

    if (match != null) {
      final rows = await AttributeRowModel.loadPredefinedRows(
        categoryId: match.id,
        attributeKeyRepo: attributeKeyRepo,
        stockRepo: stockRepo,
      );
      attributeRows.insertAll(0, rows);
    }
  }

  String? validateForm(bool isValid) {
    final missing = <String>[];
    if (consumedRows.isEmpty) {
      missing.add('At least 1 raw material');
    } else {
      for (int i = 0; i < consumedRows.length; i++) {
        if (consumedRows[i].selectedItem == null) {
          missing.add('Material #${i + 1}');
        }
        final q = double.tryParse(consumedRows[i].quantityController.text.trim()) ?? 0;
        if (q <= 0) missing.add('Material #${i + 1} qty (> 0)');
      }
    }
    if (categoryController.text.trim().isEmpty) missing.add('Category');
    if (itemNameController.text.trim().isEmpty) missing.add('Produced Item Name');
    if (unitController.text.trim().isEmpty) missing.add('Unit');
    final pQty = double.tryParse(quantityController.text.trim()) ?? 0;
    if (pQty <= 0) missing.add('Produced Qty (> 0)');

    if (!isValid || missing.isNotEmpty) {
      return missing.isNotEmpty
          ? 'Please fill required field(s): ${missing.join(', ')}'
          : 'Please fix errors';
    }
    return null;
  }
}
