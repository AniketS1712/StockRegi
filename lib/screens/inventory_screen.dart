import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/inventory_widgets.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  InventoryFilter _selectedFilter = InventoryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final businessId = business?.id ?? '';

    final stockAsync = ref.watch(stockLevelsProvider(businessId));

    Future<void> refreshStock() async {
      if (businessId.isNotEmpty) {
        ref.invalidate(stockLevelsProvider(businessId));
      }
    }

    final stockLevels = stockAsync.valueOrNull ?? [];
    final isLoading = stockAsync.isLoading && !stockAsync.hasValue;

    final filteredStock = stockLevels.where((s) {
      final name = s.item?.name.toLowerCase() ?? '';
      final category = s.item?.category?.name.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(q) || category.contains(q);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case InventoryFilter.all:
          return true;
        case InventoryFilter.rawMaterial:
          return s.item?.isRawMaterial ?? false;
        case InventoryFilter.finishedGood:
          return s.item?.isFinishedGood ?? false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: AppColors.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('StockRegi', style: textTheme.headlineMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshStock,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-stock'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          InventorySearchAndFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedFilter: _selectedFilter,
            onSearchChanged: (val) => setState(() => _searchQuery = val.trim()),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Stock', style: textTheme.headlineMedium),
                Text(
                  '${filteredStock.length} Items',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: InventoryListView(
              isLoading: isLoading,
              filteredStock: filteredStock,
              onRefresh: refreshStock,
            ),
          ),
        ],
      ),
    );
  }
}
