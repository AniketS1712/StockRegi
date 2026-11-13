import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/section_label.dart';
import '../widgets/settings_cards.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('https://saniket.vercel.app/stockregi-privacy');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Privacy Policy URL.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Privacy Policy: $e')),
        );
      }
    }
  }

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete Account'),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account?\n\n'
            'This action is irreversible. All your business data, inventory, transactions, and account details will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Show non-dismissible loading dialog during deletion
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        return const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: AppColors.error),
                SizedBox(width: 20),
                Expanded(child: Text('Deleting account & data...')),
              ],
            ),
          ),
        );
      },
    );

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user != null) {
        // 1. Delete business row (cascades to child tables per schema)
        await client.from('businesses').delete().eq('owner_id', user.id);

        // 2. Delete Supabase Auth user via Edge Function (using service_role key server-side)
        final res = await client.functions.invoke('delete-account');
        if (res.status != 200 && res.status != 204) {
          final errorMsg =
              res.data is Map ? res.data['error'] : 'Failed to delete user account';
          throw Exception(errorMsg ?? 'Failed to delete auth user');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // 3. Sign out - GoRouter will detect auth state change and redirect to login
      await client.auth.signOut();
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final businessAsync = ref.watch(currentBusinessProvider);
    final business = businessAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Settings', style: textTheme.headlineMedium)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionLabel('Account'),
            const SizedBox(height: AppSpacing.xs),
            SettingsAccountCard(businessName: business?.name),
            const SizedBox(height: AppSpacing.lg),

            const SectionLabel('Business Workspace'),
            const SizedBox(height: AppSpacing.xs),
            SettingsBusinessCard(
              isLoading: businessAsync.isLoading,
              business: business,
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionLabel('Legal & About'),
            const SizedBox(height: AppSpacing.xs),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Privacy Policy'),
                subtitle: const Text('View privacy policy & data practices'),
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: AppColors.outline,
                ),
                onTap: () => _openPrivacyPolicy(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            OutlinedButton.icon(
              onPressed: () => _confirmAndSignOut(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
              ),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Log Out'),
            ),
            const SizedBox(height: AppSpacing.sm),

            FilledButton.icon(
              onPressed: () => _confirmAndDeleteAccount(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.onError,
              ),
              label: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
