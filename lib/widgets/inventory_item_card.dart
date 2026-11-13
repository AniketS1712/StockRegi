import 'package:flutter/material.dart';
import '../models/stock_level.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../utils/format_utils.dart';

class InventoryItemCard extends StatelessWidget {
  final StockLevel stock;

  const InventoryItemCard({super.key, required this.stock});

  String _formatAttributes(StockLevel stock) {
    final attrs = stock.item?.attributes;
    if (attrs == null || attrs.isEmpty) return '';
    return attrs
        .map((a) => '${a.attributeKeyName ?? "Attr"}: ${a.value}')
        .join(' • ');
  }

  IconData _getItemIcon(StockLevel stock) {
    final item = stock.item;
    if (item == null) return Icons.inventory_2_outlined;
    if (item.isRawMaterial) return Icons.precision_manufacturing_outlined;
    if (item.isFinishedGood) return Icons.category_outlined;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = stock.item;
    final itemName = item?.name ?? 'Unknown Item';
    final unit = item?.unit ?? 'Units';
    final categoryName = item?.category?.name;
    final attrText = _formatAttributes(stock);
    final isLowStock = stock.quantity < AppConstants.lowStockThreshold;
    final itemIcon = _getItemIcon(stock);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
        side: BorderSide(
          color: isLowStock
              ? AppColors.errorContainer
              : AppColors.outlineVariant,
          width: isLowStock ? 1.5 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
        child: Stack(
          children: [
            if (isLowStock)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: AppColors.error),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: isLowStock ? AppSpacing.md + 4 : AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(itemIcon, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                itemName,
                                style:
                                    textTheme.labelLarge?.copyWith(fontSize: 16),
                              ),
                            ),
                            if (categoryName != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer
                                      .withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text(
                                  categoryName.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (attrText.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            attrText,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (isLowStock) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Low Stock (< ${AppConstants.lowStockThreshold})',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.formatQuantity(stock.quantity),
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              isLowStock ? AppColors.error : AppColors.primary,
                        ),
                      ),
                      Text(
                        unit.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
