import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_level.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../providers/repository_providers.dart';
import '../repositories/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/order_widgets.dart';
import '../widgets/selected_items_header.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final String businessId;

  const CreateOrderScreen({
    super.key,
    this.businessId = '00000000-0000-0000-0000-000000000000',
  });

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final Map<String, OrderLineState> _selectedItems = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    for (final line in _selectedItems.values) {
      line.dispose();
    }
    super.dispose();
  }

  String get _effectiveBusinessId {
    if (widget.businessId != '00000000-0000-0000-0000-000000000000' && widget.businessId.isNotEmpty) {
      return widget.businessId;
    }
    return ref.read(currentBusinessProvider).valueOrNull?.id ?? widget.businessId;
  }

  void _toggleItemSelection(StockLevel stock) {
    setState(() {
      if (_selectedItems.containsKey(stock.itemId)) {
        _selectedItems.remove(stock.itemId)?.dispose();
      } else {
        _selectedItems[stock.itemId] = OrderLineState(
          stockLevel: stock,
          qtyController: TextEditingController(text: '1'),
          unitPriceController: TextEditingController(),
        );
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final line in _selectedItems.values) {
        line.dispose();
      }
      _selectedItems.clear();
    });
  }

  Future<void> _submitOrder() async {
    if (_selectedItems.isEmpty) return;

    final orderLines = <OrderItemInput>[];
    final busId = _effectiveBusinessId;

    for (final entry in _selectedItems.entries) {
      final qty = double.tryParse(entry.value.qtyController.text.trim());
      if (qty == null || qty <= 0) {
        final itemName = entry.value.stockLevel.item?.name ?? 'Item';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter a valid quantity > 0 for "$itemName"')),
        );
        return;
      }
      final unitPrice = double.tryParse(entry.value.unitPriceController.text.trim());
      orderLines.add(OrderItemInput(
        itemId: entry.key,
        quantity: qty,
        unitPrice: unitPrice,
      ));
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(transactionRepositoryProvider).createOrder(
        businessId: busId,
        items: orderLines,
      );

      ref.invalidate(stockLevelsProvider(busId));
      ref.invalidate(recentActivityProvider(busId));
      ref.invalidate(orderHistoryProvider(busId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        _clearAll();
      }
    } catch (e) {
      if (mounted) {
        final raw = e.toString();
        final stockMatch = RegExp(r'Not enough (.+?) in stock', caseSensitive: false).firstMatch(raw);
        final userMessage = stockMatch != null
            ? 'Not enough ${stockMatch.group(1)} in stock to fulfil this order.'
            : 'Failed to create order: $e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(userMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final busId = _effectiveBusinessId;
    final stockAsync = ref.watch(stockLevelsProvider(busId));

    if (stockAsync.isLoading && !stockAsync.hasValue) {
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
    }

    final stockLevels = stockAsync.valueOrNull ?? [];
    final filteredStock = stockLevels.where((stock) {
      final itemName = stock.item?.name.toLowerCase() ?? '';
      final catName = stock.item?.category?.name.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return itemName.contains(q) || catName.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Create Order', style: textTheme.headlineMedium)),
      body: Column(
        children: [
          OrderSearchField(onChanged: (query) => setState(() => _searchQuery = query)),
          OrderStockPicker(
            filteredStock: filteredStock,
            selectedItems: _selectedItems,
            onToggleItem: _toggleItemSelection,
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          SelectedItemsHeader(
            count: _selectedItems.length,
            onClearAll: _clearAll,
          ),
          Expanded(
            child: OrderSelectedItemsList(
              selectedItems: _selectedItems,
              onRemoveItem: _toggleItemSelection,
            ),
          ),
          OrderSubmitFooter(
            itemCount: _selectedItems.length,
            isLoading: _isLoading,
            onSubmit: _submitOrder,
          ),
        ],
      ),
    );
  }
}
