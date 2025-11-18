import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/louvor.dart';
import '../providers/dependencies_provider.dart';
import 'loading_shimmer.dart';
import 'error_widget.dart';
import 'louvor_card.dart';

/// Widget para exibir lista de louvores com estados (loading, error, success)
class LouvoresListView extends ConsumerWidget {
  const LouvoresListView({
    super.key,
    this.onLouvorTap,
    this.showResultCount = true,
  });

  final ValueChanged<Louvor>? onLouvorTap;
  final bool showResultCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredLouvoresAsync = ref.watch(filteredLouvoresProvider);
    final louvoresAsync = ref.watch(louvoresProvider);

    return filteredLouvoresAsync.when(
      data: (filteredLouvores) {
        // Obter total de louvores para contador
        final totalLouvores = louvoresAsync.valueOrNull?.length ?? 0;

        if (filteredLouvores.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 64,
                    color: AppColors.placeholder,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Nenhum resultado encontrado',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (showResultCount && totalLouvores > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tente ajustar os filtros ou a busca',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.placeholder,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Contador de resultados
            if (showResultCount)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Mostrando ${filteredLouvores.length} de $totalLouvores louvores',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            // Grid de louvores
            Expanded(
              child: _buildGridView(context, filteredLouvores),
            ),
          ],
        );
      },
      loading: () => const LouvoresLoadingShimmer(),
      error: (error, stackTrace) => AppErrorWidget(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(louvoresProvider);
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<Louvor> louvores) {
    final width = MediaQuery.of(context).size.width;
    
    // Breakpoints responsivos
    double maxCrossAxisExtent;
    if (width < 600) {
      // Mobile: 1 coluna
      maxCrossAxisExtent = width - (AppSpacing.md * 2);
    } else if (width < 1024) {
      // Tablet: 2 colunas
      maxCrossAxisExtent = (width - (AppSpacing.md * 3)) / 2;
    } else {
      // Desktop: 3+ colunas
      maxCrossAxisExtent = (width - (AppSpacing.md * 4)) / 3;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: louvores.length,
      itemBuilder: (context, index) {
        final louvor = louvores[index];
        return LouvorCard(
          louvor: louvor,
          onTap: () => onLouvorTap?.call(louvor),
        )
            .animate()
            .fadeIn(duration: 200.ms, delay: (index * 30).ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: (index * 30).ms);
      },
    );
  }
}

