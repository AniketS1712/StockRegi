import 'item.dart';

class StockLevel {
  final String itemId;
  final String businessId;
  final double quantity;
  final DateTime? updatedAt;
  final Item? item;

  StockLevel({
    required this.itemId,
    required this.businessId,
    required this.quantity,
    this.updatedAt,
    this.item,
  });

  factory StockLevel.fromJson(Map<String, dynamic> json) {
    Item? itemObj;
    if (json['items'] != null && json['items'] is Map<String, dynamic>) {
      itemObj = Item.fromJson(json['items'] as Map<String, dynamic>);
    }

    return StockLevel(
      itemId: json['item_id'] as String,
      businessId: json['business_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      item: itemObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'business_id': businessId,
      'quantity': quantity,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
