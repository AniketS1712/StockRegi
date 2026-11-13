import 'package:flutter/material.dart';
import '../models/stock_level.dart';
import '../theme/app_spacing.dart';
import 'app_loading_indicator.dart';
import 'empty_state_card.dart';
import 'inventory_item_card.dart';

enum InventoryFilter { all, rawMaterial, finishedGood }

class InventorySearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final InventoryFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<InventoryFilter> onFilterSelected;

  const InventorySearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearch,
                    )
                  : null,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: const Text('All'),
                labelPadding: EdgeInsets.zero,
                selected: selectedFilter == InventoryFilter.all,
                onSelected: (_) => onFilterSelected(InventoryFilter.all),
              ),
              FilterChip(
                label: const Text('Finished Goods'),
                labelPadding: EdgeInsets.zero,
                selected: selectedFilter == InventoryFilter.finishedGood,
                onSelected: (_) => onFilterSelected(InventoryFilter.finishedGood),
              ),
              FilterChip(
                label: const Text('Raw Material'),
                labelPadding: EdgeInsets.zero,
                selected: selectedFilter == InventoryFilter.rawMaterial,
                onSelected: (_) => onFilterSelected(InventoryFilter.rawMaterial),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryListView extends StatelessWidget {
  final bool isLoading;
  final List<StockLevel> filteredStock;
  final Future<void> Function() onRefresh;

  const InventoryListView({
    super.key,
    required this.isLoading,
    required this.filteredStock,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: filteredStock.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: const [
                EmptyStateCard(message: 'No inventory items found.'),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.xs,
              ),
              itemCount: filteredStock.length,
              itemBuilder: (context, index) {
                return InventoryItemCard(stock: filteredStock[index]);
              },
            ),
    );
  }
}
