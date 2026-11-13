import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/attribute_key_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/stock_repository.dart';
import '../repositories/transaction_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(client: Supabase.instance.client);
});

final attributeKeyRepositoryProvider = Provider<AttributeKeyRepository>((ref) {
  return AttributeKeyRepository(client: Supabase.instance.client);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(client: Supabase.instance.client);
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(client: Supabase.instance.client);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(client: Supabase.instance.client);
});
