import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';

/// Widget para seleção de itens por página
class ItemsPerPageSelector extends ConsumerWidget {
  const ItemsPerPageSelector({super.key});

  static const List<int> _options = [10, 20, 30, 50, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItemsPerPage = ref.watch(itemsPerPageProvider);
    final notifier = ref.read(itemsPerPageProvider.notifier);
    final currentPageNotifier = ref.read(currentPageProvider.notifier);

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
            Icons.view_list,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Label
          Text(
            'Itens por página:',
            style: AppTextStyles.label,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: currentItemsPerPage,
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.gold,
                ),
                style: AppTextStyles.body,
                dropdownColor: AppColors.card,
                items: _options.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      '$value',
                      style: AppTextStyles.body,
                    ),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null && newValue != currentItemsPerPage) {
                    notifier.setItemsPerPage(newValue);
                    // Resetar para página 1 ao mudar itens por página
                    currentPageNotifier.state = 1;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

