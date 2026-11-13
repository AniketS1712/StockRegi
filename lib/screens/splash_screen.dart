import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_branding.dart';
import '../widgets/app_loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppLogo(),
            SizedBox(height: AppSpacing.md),
            AppBranding(),
            SizedBox(height: AppSpacing.xl),
            AppLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
