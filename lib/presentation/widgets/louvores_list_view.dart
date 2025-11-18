import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  final ValueChanged<Louvor>? onLouvorTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final louvoresAsync = ref.watch(louvoresProvider);

    return louvoresAsync.when(
      data: (louvores) {
        if (louvores.isEmpty) {
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
                    'Nenhum louvor encontrado',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return _buildGridView(context, louvores);
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
        );
      },
    );
  }
}

