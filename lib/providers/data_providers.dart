import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/stock_level.dart';
import '../models/transaction.dart';
import 'repository_providers.dart';

final stockLevelsProvider =
    FutureProvider.family<List<StockLevel>, String>((ref, businessId) async {
  final stockRepo = ref.watch(stockRepositoryProvider);
  return stockRepo.getStockLevels(businessId);
});

final categoriesProvider =
    FutureProvider.family<List<Category>, String>((ref, businessId) async {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  return categoryRepo.getCategories(businessId);
});

final itemsProvider =
    FutureProvider.family<List<Item>, String>((ref, businessId) async {
  final itemRepo = ref.watch(itemRepositoryProvider);
  return itemRepo.getItems(businessId);
});

final recentActivityProvider =
    FutureProvider.family<List<Transaction>, String>((ref, businessId) async {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return transactionRepo.getRecentActivity(businessId, limit: 5);
});

final orderHistoryProvider =
    FutureProvider.family<List<Transaction>, String>((ref, businessId) async {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return transactionRepo.getOrderHistory(businessId);
});

