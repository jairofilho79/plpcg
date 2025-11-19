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

/// Widget para exibir lista paginada de louvores
class LouvoresPaginatedListView extends ConsumerWidget {
  const LouvoresPaginatedListView({
    super.key,
    this.onLouvorTap,
  });

  final ValueChanged<Louvor>? onLouvorTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedLouvoresAsync = ref.watch(paginatedLouvoresProvider);
    final sortedLouvoresAsync = ref.watch(sortedLouvoresProvider);

    return paginatedLouvoresAsync.when(
      data: (paginatedLouvores) {
        // Obter total de louvores filtrados para contador
        final totalLouvores = sortedLouvoresAsync.valueOrNull?.length ?? 0;

        if (paginatedLouvores.isEmpty && totalLouvores == 0) {
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tente ajustar os filtros ou a busca',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.placeholder,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Contador de resultados
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Mostrando ${paginatedLouvores.length} de $totalLouvores louvores',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Grid de louvores - ocupa todo o espaço disponível
            Expanded(
              child: _buildGridView(context, paginatedLouvores),
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
    
    // Breakpoints responsivos com tamanho fixo para garantir cards visíveis
    double maxCrossAxisExtent;
    if (width < 600) {
      // Mobile: 1 coluna
      maxCrossAxisExtent = width - (AppSpacing.md * 2);
    } else if (width < 1024) {
      // Tablet: 2 colunas
      maxCrossAxisExtent = ((width - (AppSpacing.md * 3)) / 2).clamp(200.0, 300.0);
    } else {
      // Desktop: 3 colunas
      maxCrossAxisExtent = ((width - (AppSpacing.md * 4)) / 3).clamp(200.0, 350.0);
    }

    // childAspectRatio ajustado para garantir altura adequada
    // 0.65 significa que a largura é 65% da altura (cards com altura razoável)
    const aspectRatio = 0.65;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      // Garantir que pelo menos 2 linhas sejam visíveis
      // Altura mínima = (altura de 1 card + spacing) * 2 linhas
      cacheExtent: (maxCrossAxisExtent / aspectRatio + AppSpacing.md) * 2,
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

