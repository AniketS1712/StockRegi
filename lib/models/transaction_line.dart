import 'item.dart';

class TransactionLine {
  final String id;
  final String transactionId;
  final String itemId;
  final String direction; // 'in' | 'out'
  final double quantity;
  final double? unitPrice;
  final DateTime? createdAt;
  final Item? item;

  TransactionLine({
    required this.id,
    required this.transactionId,
    required this.itemId,
    required this.direction,
    required this.quantity,
    this.unitPrice,
    this.createdAt,
    this.item,
  });

  factory TransactionLine.fromJson(Map<String, dynamic> json) {
    Item? itemObj;
    if (json['items'] != null && json['items'] is Map<String, dynamic>) {
      itemObj = Item.fromJson(json['items'] as Map<String, dynamic>);
    }

    return TransactionLine(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      itemId: json['item_id'] as String,
      direction: json['direction'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: json['unit_price'] != null
          ? (json['unit_price'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      item: itemObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_id': itemId,
      'direction': direction,
      'quantity': quantity,
      'unit_price': unitPrice,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
