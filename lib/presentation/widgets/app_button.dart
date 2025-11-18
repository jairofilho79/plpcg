import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Botão customizado seguindo o design system
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: _getButtonStyle(variant, size),
      child: isLoading
          ? SizedBox(
              height: size == AppButtonSize.small ? 16 : 20,
              width: size == AppButtonSize.small ? 16 : 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: size == AppButtonSize.small
                      ? AppTextStyles.buttonSmall
                      : AppTextStyles.button,
                ),
              ],
            ),
    );
  }

  ButtonStyle _getButtonStyle(AppButtonVariant variant, AppButtonSize size) {
    final backgroundColor = variant == AppButtonVariant.primary
        ? AppColors.btnBackground
        : AppColors.gold;

    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      AppButtonSize.large => const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
    };

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: AppColors.textLight,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.mediumRadius,
      ),
      elevation: 0,
    );
  }
}

enum AppButtonVariant {
  primary,
  secondary,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

