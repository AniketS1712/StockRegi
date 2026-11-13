import 'package:flutter/material.dart';
import '../models/attribute_row_model.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../repositories/attribute_key_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/stock_repository.dart';

class StockFormState {
  final categoryController = TextEditingController();
  final itemNameController = TextEditingController();
  final unitController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();

  final List<AttributeRowModel> attributeRows = [];
  final Set<String> knownKeyNames = {};
  List<Category> categories = [];
  List<Item> existingItems = [];
  Category? matchedCategory;

  void dispose() {
    categoryController.dispose();
    itemNameController.dispose();
    unitController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    for (final row in attributeRows) {
      row.dispose();
    }
  }

  void reset() {
    categoryController.clear();
    itemNameController.clear();
    unitController.clear();
    quantityController.clear();
    unitPriceController.clear();
    matchedCategory = null;
    for (final row in attributeRows) {
      row.dispose();
    }
    attributeRows.clear();
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
    required CategoryRepository categoryRepo,
    required ItemRepository itemRepo,
    required AttributeKeyRepository attributeKeyRepo,
  }) async {
    final data = await AttributeRowModel.loadInitialFormData(
      businessId: businessId,
      categoryRepo: categoryRepo,
      itemRepo: itemRepo,
      attributeKeyRepo: attributeKeyRepo,
    );
    categories = data.categories;
    existingItems = data.items;
    knownKeyNames.addAll(data.knownKeyNames);
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
}
