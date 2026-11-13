import 'category.dart';
import 'item_attribute.dart';

class Item {
  final String id;
  final String businessId;
  final String categoryId;
  final String name;
  final String unit;
  final bool isRawMaterial;
  final bool isFinishedGood;
  final DateTime? createdAt;

  final Category? category;
  final List<ItemAttribute>? attributes;

  Item({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    required this.unit,
    this.isRawMaterial = false,
    this.isFinishedGood = true,
    this.createdAt,
    this.category,
    this.attributes,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    Category? cat;
    if (json['categories'] != null && json['categories'] is Map<String, dynamic>) {
      cat = Category.fromJson(json['categories'] as Map<String, dynamic>);
    }

    List<ItemAttribute>? attrs;
    if (json['item_attributes'] != null && json['item_attributes'] is List) {
      attrs = (json['item_attributes'] as List)
          .map((a) => ItemAttribute.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return Item(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      isRawMaterial: json['is_raw_material'] as bool? ?? false,
      isFinishedGood: json['is_finished_good'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      category: cat,
      attributes: attrs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'category_id': categoryId,
      'name': name,
      'unit': unit,
      'is_raw_material': isRawMaterial,
      'is_finished_good': isFinishedGood,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
