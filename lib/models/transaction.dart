import 'transaction_line.dart';

class Transaction {
  final String id;
  final String businessId;
  final String type; // 'purchase' | 'production' | 'order' | 'adjustment'
  final String? notes;
  final DateTime? createdAt;
  final List<TransactionLine>? lines;

  Transaction({
    required this.id,
    required this.businessId,
    required this.type,
    this.notes,
    this.createdAt,
    this.lines,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<TransactionLine>? transactionLines;
    if (json['transaction_lines'] != null &&
        json['transaction_lines'] is List) {
      transactionLines = (json['transaction_lines'] as List)
          .map((line) => TransactionLine.fromJson(line as Map<String, dynamic>))
          .toList();
    }

    return Transaction(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      type: json['type'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lines: transactionLines,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'type': type,
      'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
