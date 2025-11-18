import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';
import 'category_filter_chip.dart';

/// Widget para exibir filtros de categoria
class CategoryFilters extends ConsumerWidget {
  const CategoryFilters({super.key});

  // Categorias disponíveis conforme especificado no plano
  static const List<String> availableCategories = [
    'Partitura',
    'Cifra',
    'Gestos em Gravura',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final hasActiveFilters = selectedCategories.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título e botão limpar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorias',
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(selectedCategoriesProvider.notifier).clear();
                  },
                  child: Text(
                    'Limpar',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.goldLight,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Chips de filtro
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: availableCategories
                .map((category) => CategoryFilterChip(category: category))
                .toList(),
          ),
        ),
      ],
    );
  }
}

