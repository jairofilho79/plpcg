import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';
import 'classification_filter_chip.dart';
import 'loading_indicator.dart';

/// Widget para exibir filtros de classificação
class ClassificationFilters extends ConsumerWidget {
  const ClassificationFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classificationsAsync = ref.watch(availableClassificationsProvider);
    final selectedClassifications = ref.watch(selectedClassificationsProvider);
    final hasActiveFilters = selectedClassifications.isNotEmpty;

    return classificationsAsync.when(
      data: (classifications) {
        if (classifications.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    'Classificações',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        ref.read(selectedClassificationsProvider.notifier).clear();
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
                children: classifications
                    .map((classification) => ClassificationFilterChip(
                          classification: classification,
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: LoadingIndicator(),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

