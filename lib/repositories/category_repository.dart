import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryRepository {
  final SupabaseClient _supabase;

  CategoryRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  Future<List<Category>> getCategories(String businessId) async {
    final response = await _supabase
        .from('categories')
        .select()
        .eq('business_id', businessId)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Category> getOrCreateCategory(String businessId, String name) async {
    final trimmedName = name.trim();

    final existing = await _supabase
        .from('categories')
        .select()
        .eq('business_id', businessId)
        .ilike('name', trimmedName)
        .maybeSingle();

    if (existing != null) {
      return Category.fromJson(existing);
    }

    final inserted = await _supabase
        .from('categories')
        .insert({
          'business_id': businessId,
          'name': trimmedName,
        })
        .select()
        .single();

    return Category.fromJson(inserted);
  }
}
