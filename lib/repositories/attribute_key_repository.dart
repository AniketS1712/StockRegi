import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attribute_key.dart';

class AttributeKeyRepository {
  final SupabaseClient _supabase;

  AttributeKeyRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  Future<List<AttributeKey>> getAttributeKeys(String categoryId) async {
    final response = await _supabase
        .from('attribute_keys')
        .select()
        .eq('category_id', categoryId)
        .order('key_name', ascending: true);

    return (response as List)
        .map((json) => AttributeKey.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AttributeKey> getOrCreateAttributeKey(
      String categoryId, String keyName) async {
    final trimmedKeyName = keyName.trim();

    final existing = await _supabase
        .from('attribute_keys')
        .select()
        .eq('category_id', categoryId)
        .ilike('key_name', trimmedKeyName)
        .maybeSingle();

    if (existing != null) {
      return AttributeKey.fromJson(existing);
    }

    final inserted = await _supabase
        .from('attribute_keys')
        .insert({
          'category_id': categoryId,
          'key_name': trimmedKeyName,
        })
        .select()
        .single();

    return AttributeKey.fromJson(inserted);
  }
}
