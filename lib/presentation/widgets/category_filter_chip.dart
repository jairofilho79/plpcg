import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';

/// Chip reutilizável para filtro de categoria
class CategoryFilterChip extends ConsumerWidget {
  const CategoryFilterChip({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final isSelected = selectedCategories.contains(category);

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoriesProvider.notifier).toggleCategory(category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.card,
          borderRadius: AppBorderRadius.largeRadius,
          border: Border.all(
            color: isSelected ? AppColors.goldLight : AppColors.textDark.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.textDark,
              )
            else
              const Icon(
                Icons.circle_outlined,
                size: 18,
                color: AppColors.textDark,
              ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              category,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

