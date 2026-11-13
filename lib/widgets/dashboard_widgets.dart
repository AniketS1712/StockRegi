import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/format_utils.dart';
import 'activity_tile.dart';
import 'app_loading_indicator.dart';
import 'empty_state_card.dart';
import 'metric_card.dart';

class DashboardMetricsRow extends StatelessWidget {
  final bool isLoading;
  final int totalItems;
  final int lowStockCount;

  const DashboardMetricsRow({
    super.key,
    required this.isLoading,
    required this.totalItems,
    required this.lowStockCount,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            label: 'Total Items',
            value: isLoading ? '...' : '$totalItems',
          ),
        ),
        const SizedBox(width: AppSpacing.gutterMobile),
        Expanded(
          child: MetricCard(
            icon: Icons.warning_amber_rounded,
            iconColor: lowStockCount > 0 ? AppColors.error : AppColors.primary,
            label: 'Low Stock',
            value: isLoading ? '...' : '$lowStockCount',
            valueStyle: textTheme.headlineLarge?.copyWith(
              color: lowStockCount > 0 ? AppColors.error : AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardActionsRow extends StatelessWidget {
  final String role;

  const DashboardActionsRow({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isProducer = role.toLowerCase() == 'producer';

    if (isProducer) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/purchase'),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Purchase', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/production'),
              icon: const Icon(
                Icons.precision_manufacturing_outlined,
                size: 18,
              ),
              label: const Text('Production', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/create-order'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('New Order', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/add-stock'),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Stock'),
          ),
        ),
        const SizedBox(width: AppSpacing.gutterMobile),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/create-order'),
            icon: const Icon(Icons.receipt_long),
            label: const Text('New Order'),
          ),
        ),
      ],
    );
  }
}

class DashboardActivityList extends StatelessWidget {
  final bool isLoading;
  final List<Transaction> recentActivity;

  const DashboardActivityList({
    super.key,
    required this.isLoading,
    required this.recentActivity,
  });

  ({IconData icon, Color color}) _transactionVisuals(String type) {
    switch (type) {
      case 'purchase':
        return (icon: Icons.add_circle_outline, color: AppColors.primary);
      case 'order':
        return (icon: Icons.remove_circle_outline, color: AppColors.tertiary);
      case 'production':
        return (
          icon: Icons.precision_manufacturing_outlined,
          color: AppColors.secondary,
        );
      default:
        return (icon: Icons.tune, color: AppColors.onSurfaceVariant);
    }
  }

  String _formatDate(DateTime dt) {
    return FormatUtils.formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: AppLoadingIndicator(),
        ),
      );
    }
    if (recentActivity.isEmpty) {
      return const EmptyStateCard(message: 'No recent transactions found.');
    }
    return Column(
      children: recentActivity.map((tx) {
        final lineCount = tx.lines?.length ?? 0;
        final firstLine = (tx.lines != null && tx.lines!.isNotEmpty)
            ? tx.lines!.first
            : null;
        final itemName = firstLine?.item?.name ?? 'Items';
        final typeUpper = tx.type.toUpperCase();
        final visuals = _transactionVisuals(tx.type);

        return ActivityTile(
          icon: visuals.icon,
          iconColor: visuals.color,
          title:
              '$typeUpper: $itemName${lineCount > 1 ? ' +${lineCount - 1} more' : ''}',
          subtitle: tx.createdAt != null ? _formatDate(tx.createdAt!) : null,
        );
      }).toList(),
    );
  }
}
