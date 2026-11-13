import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class ItemRepository {
  final SupabaseClient _supabase;

  ItemRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  Future<List<Item>> getItems(String businessId) async {
    final response = await _supabase
        .from('items')
        .select('*, categories(*), item_attributes(*, attribute_keys(*))')
        .eq('business_id', businessId)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Item>> getRawMaterialItems(String businessId) async {
    final response = await _supabase
        .from('items')
        .select('*, categories(*), item_attributes(*, attribute_keys(*))')
        .eq('business_id', businessId)
        .eq('is_raw_material', true)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns an existing item if one matches by normalized name, unit, and
  /// attribute values — otherwise creates a new one.
  ///
  /// Comparison is case-insensitive (trim + lowercase). Original casing is
  /// preserved when inserting new rows.
  Future<Item> getOrCreateItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String unit,
    bool isRawMaterial = false,
    bool isFinishedGood = true,
    Map<String, String> attributes = const {},
  }) async {
    final normName = name.trim().toLowerCase();
    final normUnit = unit.trim().toLowerCase();

    // Build a normalized version of the incoming attributes for comparison.
    // Key = attributeKeyId, Value = trimmed+lowercased value.
    final Map<String, String> normIncoming = {
      for (final e in attributes.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim().toLowerCase(),
    };

    // Fetch candidate items that share the same business, category,
    // and case-insensitive name + unit.
    final candidates = await _supabase
        .from('items')
        .select('*, categories(*), item_attributes(*, attribute_keys(*))')
        .eq('business_id', businessId)
        .eq('category_id', categoryId)
        .ilike('name', normName)
        .ilike('unit', normUnit);

    for (final row in (candidates as List)) {
      final candidateJson = row as Map<String, dynamic>;
      final candidate = Item.fromJson(candidateJson);

      // Build a normalized map from the candidate's existing attributes.
      final candAttrs = <String, String>{};
      if (candidate.attributes != null) {
        for (final a in candidate.attributes!) {
          candAttrs[a.attributeKeyId] = a.value.trim().toLowerCase();
        }
      }

      // Same number of attribute keys?
      if (candAttrs.length != normIncoming.length) continue;

      // All keys present and values match?
      bool allMatch = true;
      for (final key in normIncoming.keys) {
        if (candAttrs[key] != normIncoming[key]) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) return candidate; // ← exact match, reuse existing item
    }

    // ── No match found — insert new item + attributes ──

    final insertedItem = await _supabase
        .from('items')
        .insert({
          'business_id': businessId,
          'category_id': categoryId,
          'name': name.trim(),
          'unit': unit.trim(),
          'is_raw_material': isRawMaterial,
          'is_finished_good': isFinishedGood,
        })
        .select()
        .single();

    final itemId = insertedItem['id'] as String;

    if (attributes.isNotEmpty) {
      final attributeRows = attributes.entries
          .where((entry) => entry.value.trim().isNotEmpty)
          .map((entry) => {
                'item_id': itemId,
                'attribute_key_id': entry.key,
                'value': entry.value.trim(),
              })
          .toList();

      if (attributeRows.isNotEmpty) {
        await _supabase.from('item_attributes').insert(attributeRows);
      }
    }

    final fullItem = await _supabase
        .from('items')
        .select('*, categories(*), item_attributes(*, attribute_keys(*))')
        .eq('id', itemId)
        .single();

    return Item.fromJson(fullItem);
  }
}
