import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/order_history_card.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final businessId = business?.id ?? '';

    final ordersAsync = ref.watch(orderHistoryProvider(businessId));

    Future<void> refreshOrders() async {
      if (businessId.isNotEmpty) {
        ref.invalidate(orderHistoryProvider(businessId));
      }
    }

    final orders = ordersAsync.valueOrNull ?? [];
    final isLoading = ordersAsync.isLoading && !ordersAsync.hasValue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Orders', style: textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: AppLoadingIndicator())
          : RefreshIndicator(
              onRefresh: refreshOrders,
              child: orders.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(AppSpacing.marginMobile),
                      children: const [
                        EmptyStateCard(message: 'No orders found.'),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.marginMobile),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return OrderHistoryCard(transaction: orders[index]);
                      },
                    ),
            ),
    );
  }
}
