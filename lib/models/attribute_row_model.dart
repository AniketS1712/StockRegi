import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../repositories/attribute_key_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/stock_repository.dart';
import '../repositories/transaction_repository.dart';

class InitialFormData {
  final List<Category> categories;
  final List<Item> items;
  final Set<String> knownKeyNames;

  InitialFormData({
    required this.categories,
    required this.items,
    required this.knownKeyNames,
  });
}

class AttributeRowModel {
  final String? keyId;
  final TextEditingController keyController;
  final TextEditingController valueController;
  final bool isPredefined;
  List<String> valueSuggestions;

  AttributeRowModel({
    this.keyId,
    required this.keyController,
    required this.valueController,
    this.isPredefined = false,
    this.valueSuggestions = const [],
  });

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }

  static Future<InitialFormData> loadInitialFormData({
    required String businessId,
    required CategoryRepository categoryRepo,
    required ItemRepository itemRepo,
    required AttributeKeyRepository attributeKeyRepo,
  }) async {
    final cats = await categoryRepo.getCategories(businessId);
    final items = await itemRepo.getItems(businessId);
    final keysSet = <String>{};
    for (final cat in cats) {
      final keys = await attributeKeyRepo.getAttributeKeys(cat.id);
      keysSet.addAll(keys.map((k) => k.keyName.toLowerCase()));
    }
    return InitialFormData(
      categories: cats,
      items: items,
      knownKeyNames: keysSet,
    );
  }

  static Future<List<AttributeRowModel>> loadPredefinedRows({
    required String categoryId,
    required AttributeKeyRepository attributeKeyRepo,
    required StockRepository stockRepo,
  }) async {
    final keys = await attributeKeyRepo.getAttributeKeys(categoryId);
    final List<AttributeRowModel> rows = [];
    for (final key in keys) {
      final suggestions = await stockRepo.getDistinctAttributeValues(key.id);
      rows.add(
        AttributeRowModel(
          keyId: key.id,
          keyController: TextEditingController(text: key.keyName),
          valueController: TextEditingController(),
          isPredefined: true,
          valueSuggestions: suggestions,
        ),
      );
    }
    return rows;
  }

  static Future<Map<String, String>> buildAttributeMap({
    required String categoryId,
    required List<AttributeRowModel> rows,
    required AttributeKeyRepository attributeKeyRepo,
  }) async {
    final Map<String, String> attributeMap = {};
    for (final row in rows) {
      final keyName = row.keyController.text.trim();
      final value = row.valueController.text.trim();
      if (keyName.isNotEmpty && value.isNotEmpty) {
        final attrKey = await attributeKeyRepo.getOrCreateAttributeKey(
          categoryId,
          keyName,
        );
        attributeMap[attrKey.id] = value;
      }
    }
    return attributeMap;
  }

  static String? validateStockForm({
    required bool isValid,
    required String categoryName,
    required String itemName,
    required String unit,
    required double quantity,
  }) {
    final missing = <String>[];
    if (categoryName.isEmpty) missing.add('Category');
    if (itemName.isEmpty) missing.add('Item Name');
    if (unit.isEmpty) missing.add('Unit');
    if (quantity <= 0) missing.add('Quantity (> 0)');
    if (!isValid || missing.isNotEmpty) {
      return missing.isNotEmpty
          ? 'Please fill required field(s): ${missing.join(', ')}'
          : 'Please fix the errors highlighted in red';
    }
    return null;
  }

  static Future<Item> recordPurchaseItem({
    required String businessId,
    required String categoryName,
    required String itemName,
    required String unit,
    required bool isRawMaterial,
    required double quantity,
    double? unitPrice,
    required List<AttributeRowModel> attributeRows,
    required CategoryRepository categoryRepo,
    required AttributeKeyRepository attributeKeyRepo,
    required ItemRepository itemRepo,
    required TransactionRepository transactionRepo,
  }) async {
    final category = await categoryRepo.getOrCreateCategory(businessId, categoryName);
    final attrMap = await buildAttributeMap(
      categoryId: category.id,
      rows: attributeRows,
      attributeKeyRepo: attributeKeyRepo,
    );
    final item = await itemRepo.getOrCreateItem(
      businessId: businessId,
      categoryId: category.id,
      name: itemName,
      unit: unit,
      isRawMaterial: isRawMaterial,
      isFinishedGood: !isRawMaterial,
      attributes: attrMap,
    );
    await transactionRepo.createPurchase(
      businessId: businessId,
      itemId: item.id,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    return item;
  }

  static Future<Item> recordProductionRun({
    required String businessId,
    required List<ProductionItemInput> consumed,
    required String categoryName,
    required String producedItemName,
    required String unit,
    required double producedQuantity,
    required List<AttributeRowModel> attributeRows,
    required CategoryRepository categoryRepo,
    required AttributeKeyRepository attributeKeyRepo,
    required ItemRepository itemRepo,
    required TransactionRepository transactionRepo,
  }) async {
    final category = await categoryRepo.getOrCreateCategory(businessId, categoryName);
    final attrMap = await buildAttributeMap(
      categoryId: category.id,
      rows: attributeRows,
      attributeKeyRepo: attributeKeyRepo,
    );
    final producedItem = await itemRepo.getOrCreateItem(
      businessId: businessId,
      categoryId: category.id,
      name: producedItemName,
      unit: unit,
      isRawMaterial: false,
      isFinishedGood: true,
      attributes: attrMap,
    );
    await transactionRepo.createProduction(
      businessId: businessId,
      consumed: consumed,
      produced: [ProductionItemInput(itemId: producedItem.id, quantity: producedQuantity)],
    );
    return producedItem;
  }
}
