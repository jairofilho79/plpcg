import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/playlist.dart';
import '../../core/errors/result.dart';
import '../providers/dependencies_provider.dart';
import 'app_card.dart';

/// Card de exibição de playlist
class PlaylistCard extends ConsumerWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onPlay,
    this.onEdit,
    this.onShare,
    this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback? onPlay;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      elevation: AppCardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com nome e favorita
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nome da playlist
              Expanded(
                child: Row(
                  children: [
                    if (playlist.favorita)
                      const Icon(
                        Icons.star,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    if (playlist.favorita) const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        playlist.nome,
                        style: AppTextStyles.heading4,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Botão de favoritar
              IconButton(
                icon: Icon(
                  playlist.favorita ? Icons.star : Icons.star_border,
                  color: playlist.favorita ? AppColors.gold : AppColors.textDark,
                ),
                onPressed: () => _handleToggleFavorita(context, ref),
                tooltip: playlist.favorita ? 'Desfavoritar' : 'Favoritar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Informações da playlist
          Row(
            children: [
              // Quantidade de louvores
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeBlue,
                  borderRadius: AppBorderRadius.smallRadius,
                ),
                child: Text(
                  '${playlist.pdfIds.length} ${playlist.pdfIds.length == 1 ? 'louvor' : 'louvores'}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Data de criação
              Flexible(
                child: Text(
                  _formatDate(playlist.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Botões de ação
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botão Reproduzir
              TextButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Reproduzir'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Botão Editar
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: AppColors.textDark,
                onPressed: onEdit,
                tooltip: 'Editar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Botão Compartilhar
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: AppColors.textDark,
                onPressed: onShare,
                tooltip: 'Compartilhar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Botão Remover
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                onPressed: onDelete,
                tooltip: 'Remover',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formata data de criação
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }

  /// Toggle favorita
  Future<void> _handleToggleFavorita(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(playlistsProvider.notifier);
    final result = await notifier.toggleFavorita(playlist.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (result) {
              Success() => playlist.favorita ? 'Removida dos favoritos' : 'Adicionada aos favoritos',
              Error() => 'Erro ao atualizar favorito',
            },
          ),
          backgroundColor: switch (result) {
            Success() => AppColors.success,
            Error() => AppColors.error,
          },
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

