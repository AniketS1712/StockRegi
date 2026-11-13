import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextStyle get headlineLarge => GoogleFonts.beVietnamPro(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.02 * 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMedium => GoogleFonts.beVietnamPro(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLarge => GoogleFonts.publicSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 26 / 18,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get labelBold => GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSmall => GoogleFonts.publicSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 18 / 13,
        color: AppColors.onSurfaceVariant,
      );
}
