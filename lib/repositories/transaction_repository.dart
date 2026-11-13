import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class OrderItemInput {
  final String itemId;
  final double quantity;
  final double? unitPrice;

  OrderItemInput({
    required this.itemId,
    required this.quantity,
    this.unitPrice,
  });
}

class ProductionItemInput {
  final String itemId;
  final double quantity;

  ProductionItemInput({
    required this.itemId,
    required this.quantity,
  });
}

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  /// Creates a purchase transaction (type='purchase') and one transaction_line (direction='in').
  Future<Transaction> createPurchase({
    required String businessId,
    required String itemId,
    required double quantity,
    double? unitPrice,
    String? notes,
  }) async {
    final txJson = await _supabase
        .from('transactions')
        .insert({
          'business_id': businessId,
          'type': 'purchase',
          'notes': notes,
        })
        .select()
        .single();

    final txId = txJson['id'] as String;

    await _supabase.from('transaction_lines').insert({
      'transaction_id': txId,
      'item_id': itemId,
      'direction': 'in',
      'quantity': quantity,
      'unit_price': unitPrice,
    });

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*)')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }

  /// Creates an order transaction atomically via the `create_order` Postgres RPC.
  /// Throws a [StockConstraintException] if any item has insufficient stock.
  Future<Transaction> createOrder({
    required String businessId,
    required List<OrderItemInput> items,
    String? notes,
  }) async {
    final linesJson = items
        .map((item) => {
              'item_id': item.itemId,
              'quantity': item.quantity,
              if (item.unitPrice != null) 'unit_price': item.unitPrice,
            })
        .toList();

    final txId = await _supabase.rpc<String>(
      'create_order',
      params: {
        'p_business_id': businessId,
        'p_lines': linesJson,
        'p_notes': notes,
      },
    );

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }

  /// Creates a production transaction atomically via the `create_production` Postgres RPC.
  /// Throws a [StockConstraintException] (wrapping the RPC error) if consumed quantities
  /// exceed available stock for any raw material.
  Future<Transaction> createProduction({
    required String businessId,
    required List<ProductionItemInput> consumed,
    required List<ProductionItemInput> produced,
    String? notes,
  }) async {
    final consumedJson =
        consumed.map((i) => {'item_id': i.itemId, 'quantity': i.quantity}).toList();
    final producedJson =
        produced.map((i) => {'item_id': i.itemId, 'quantity': i.quantity}).toList();

    final txId = await _supabase.rpc<String>(
      'create_production',
      params: {
        'p_business_id': businessId,
        'p_consumed': consumedJson,
        'p_produced': producedJson,
        'p_notes': notes,
      },
    );

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }

  /// Creates an inventory adjustment (type='adjustment') with direction 'in' or 'out'.
  Future<Transaction> createAdjustment({
    required String businessId,
    required String itemId,
    required double quantity,
    required String direction,
    String? notes,
  }) async {
    if (direction != 'in' && direction != 'out') {
      throw ArgumentError('direction must be "in" or "out", got: $direction');
    }

    final txJson = await _supabase
        .from('transactions')
        .insert({
          'business_id': businessId,
          'type': 'adjustment',
          'notes': notes,
        })
        .select()
        .single();

    final txId = txJson['id'] as String;

    await _supabase.from('transaction_lines').insert({
      'transaction_id': txId,
      'item_id': itemId,
      'direction': direction,
      'quantity': quantity,
    });

    final fullTx = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*)')
        .eq('id', txId)
        .single();

    return Transaction.fromJson(fullTx);
  }

  /// Fetches recent transactions for a business with joined transaction_lines and items.
  Future<List<Transaction>> getRecentActivity(String businessId,
      {int limit = 5}) async {
    final response = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all order transactions (type='order') for a business, joined with transaction_lines and items, ordered by created_at descending.
  Future<List<Transaction>> getOrderHistory(String businessId) async {
    final response = await _supabase
        .from('transactions')
        .select('*, transaction_lines(*, items(*))')
        .eq('business_id', businessId)
        .eq('type', 'order')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

