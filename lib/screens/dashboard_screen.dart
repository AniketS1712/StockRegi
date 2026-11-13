import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../theme/app_spacing.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final business = ref.watch(currentBusinessProvider).valueOrNull;
    final businessId = business?.id ?? '';
    final businessName = business?.name ?? 'Dashboard';
    final role = business?.role ?? 'Seller';

    final stockAsync = ref.watch(stockLevelsProvider(businessId));
    final activityAsync = ref.watch(recentActivityProvider(businessId));

    final stockLevels = stockAsync.valueOrNull ?? [];
    final recentActivity = activityAsync.valueOrNull ?? [];
    final isLoading = stockAsync.isLoading || activityAsync.isLoading;

    final totalItems = stockLevels.length;
    final lowStockCount = stockLevels
        .where((s) => s.quantity < AppConstants.lowStockThreshold)
        .length;

    Future<void> refreshData() async {
      if (businessId.isNotEmpty) {
        ref.invalidate(stockLevelsProvider(businessId));
        ref.invalidate(recentActivityProvider(businessId));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName,
              style: textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            Text(role.toUpperCase(), style: textTheme.labelSmall),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardMetricsRow(
                isLoading: isLoading,
                totalItems: totalItems,
                lowStockCount: lowStockCount,
              ),
              const SizedBox(height: AppSpacing.marginMobile),
              DashboardActionsRow(role: role),
              const SizedBox(height: AppSpacing.lg),
              Text('Recent Activity', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              DashboardActivityList(
                isLoading: isLoading,
                recentActivity: recentActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
