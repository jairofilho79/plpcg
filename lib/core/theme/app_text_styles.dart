import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto do design system usando Google Fonts
class AppTextStyles {
  AppTextStyles._();

  // Headings com EB Garamond
  static TextStyle get heading1 => GoogleFonts.ebGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.03,
        color: AppColors.textDark,
      );

  static TextStyle get heading2 => GoogleFonts.ebGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02,
        color: AppColors.textDark,
      );

  static TextStyle get heading3 => GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
        color: AppColors.textDark,
      );

  static TextStyle get heading4 => GoogleFonts.ebGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      );

  // Body com Open Sans
  static TextStyle get body => GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  static TextStyle get bodySmall => GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  static TextStyle get bodyLarge => GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  // Labels e captions
  static TextStyle get label => GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      );

  static TextStyle get caption => GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  // Botões
  static TextStyle get button => GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      );

  static TextStyle get buttonSmall => GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      );
}

