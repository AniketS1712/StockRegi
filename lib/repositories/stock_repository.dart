import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_level.dart';

class StockRepository {
  final SupabaseClient _supabase;

  StockRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  Future<List<StockLevel>> getStockLevels(String businessId) async {
    final response = await _supabase
        .from('stock_levels')
        .select(
            '*, items(*, categories(*), item_attributes(*, attribute_keys(*)))')
        .eq('business_id', businessId);

    return (response as List)
        .map((json) => StockLevel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getDistinctAttributeValues(String attributeKeyId) async {
    final response = await _supabase
        .from('item_attributes')
        .select('value')
        .eq('attribute_key_id', attributeKeyId);

    final values = (response as List)
        .map((row) => (row['value'] as String).trim())
        .where((val) => val.isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }
}
