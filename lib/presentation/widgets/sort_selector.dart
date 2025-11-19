import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/sort_order.dart' show SortOrder, SortOrderExtension;
import '../providers/dependencies_provider.dart';

/// Widget para seleção de ordenação de louvores
class SortSelector extends ConsumerWidget {
  const SortSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOrderProvider);
    final notifier = ref.read(sortOrderProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.mediumRadius,
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícone
          const Icon(
            Icons.sort,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Label
          Text(
            'Ordenar por:',
            style: AppTextStyles.label,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SortOrder>(
                value: currentSort,
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.gold,
                ),
                style: AppTextStyles.body,
                dropdownColor: AppColors.card,
                items: SortOrder.values.map((order) {
                  return DropdownMenuItem<SortOrder>(
                    value: order,
                    child: Row(
                      children: [
                        Icon(
                          _getSortIcon(order),
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          order.displayName,
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (SortOrder? newOrder) {
                  if (newOrder != null && newOrder != currentSort) {
                    notifier.setSortOrder(newOrder);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna o ícone apropriado para cada tipo de ordenação
  IconData _getSortIcon(SortOrder order) {
    switch (order) {
      case SortOrder.number:
        return Icons.numbers;
      case SortOrder.name:
        return Icons.sort_by_alpha;
    }
  }
}

