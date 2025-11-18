import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';

/// Widget para indicar filtros ativos
class ActiveFiltersIndicator extends ConsumerWidget {
  const ActiveFiltersIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final selectedClassifications = ref.watch(selectedClassificationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final hasActiveFilters = selectedCategories.isNotEmpty ||
        selectedClassifications.isNotEmpty ||
        searchQuery.isNotEmpty;

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    int activeCount = 0;
    if (selectedCategories.isNotEmpty) activeCount += selectedCategories.length;
    if (selectedClassifications.isNotEmpty) activeCount += selectedClassifications.length;
    if (searchQuery.isNotEmpty) activeCount += 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.2),
        borderRadius: AppBorderRadius.mediumRadius,
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.gold,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$activeCount filtro${activeCount > 1 ? 's' : ''} ativo${activeCount > 1 ? 's' : ''}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () {
              ref.read(selectedCategoriesProvider.notifier).clear();
              ref.read(selectedClassificationsProvider.notifier).clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Limpar todos',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0, duration: 300.ms);
  }
}

