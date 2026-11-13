import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/format_utils.dart';

class OrderHistoryCard extends StatelessWidget {
  final Transaction transaction;

  const OrderHistoryCard({super.key, required this.transaction});

  String _formatDate(DateTime dt) {
    return FormatUtils.formatDate(dt);
  }

  double _calculateTotalAmount(Transaction tx) {
    if (tx.lines == null) return 0.0;
    double total = 0.0;
    for (final line in tx.lines!) {
      total += line.quantity * (line.unitPrice ?? 0.0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lines = transaction.lines ?? [];
    final lineCount = lines.length;
    final totalAmount = _calculateTotalAmount(transaction);
    final dateStr = transaction.createdAt != null
        ? _formatDate(transaction.createdAt!)
        : 'Unknown Date';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(
          Icons.receipt_long_rounded,
          color: AppColors.tertiary,
          size: 28,
        ),
        title: Text(
          'Order ${transaction.id.substring(0, 8)}...',
          style: textTheme.labelLarge,
        ),
        subtitle: Text(
          '$dateStr • $lineCount item${lineCount == 1 ? '' : 's'}',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          totalAmount > 0
              ? '\$${totalAmount.toStringAsFixed(2)}'
              : 'No Price',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
          ),
        ),
        children: [
          const Divider(height: 1, color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Lines',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...lines.map((line) {
                  final itemName = line.item?.name ?? 'Item';
                  final unit = line.item?.unit ?? '';
                  final price = line.unitPrice;
                  final lineTotal = line.quantity * (price ?? 0.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$itemName (${FormatUtils.formatQuantity(line.quantity)} $unit)',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          price != null
                              ? '\$${lineTotal.toStringAsFixed(2)} (@ \$${price.toStringAsFixed(2)})'
                              : '-',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  );
                }),
                if (transaction.notes != null &&
                    transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Notes: ${transaction.notes}',
                    style: textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
