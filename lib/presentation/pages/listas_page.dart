import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/playlist.dart';
import '../../data/models/louvor.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/playlist_card.dart';
import '../widgets/save_playlist_dialog.dart';
import '../widgets/edit_playlist_dialog.dart';
import '../widgets/delete_playlist_dialog.dart';
import '../providers/dependencies_provider.dart';
import 'dart:async';
import '../widgets/app_text_field.dart';

/// Página de listas/playlists
class ListasPage extends ConsumerWidget {
  const ListasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(filteredPlaylistsProvider);
    final carouselLouvores = ref.watch(carouselLouvoresProvider);
    final favoritesFilter = ref.watch(playlistFavoritesFilterProvider);

    return AppScaffold(
      showHeader: true,
      title: 'Listas',
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _PlaylistSearchBar(),
          ),
          // Header com filtros e ações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                // Botão de filtro de favoritas
                IconButton(
                  icon: Icon(
                    favoritesFilter
                        ? Icons.star
                        : Icons.star_border,
                    color: favoritesFilter
                        ? AppColors.gold
                        : AppColors.textDark,
                  ),
                  onPressed: () {
                    ref.read(playlistFavoritesFilterProvider.notifier).state =
                        !favoritesFilter;
                  },
                  tooltip: favoritesFilter
                      ? 'Mostrar todas'
                      : 'Mostrar apenas favoritas',
                ),
                const Spacer(),
                // Botão de salvar carousel como playlist
                if (carouselLouvores.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _showSavePlaylistDialog(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Carousel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textDark,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Lista de playlists
          Expanded(
            child: playlists.isEmpty
                ? _buildEmptyState(context, carouselLouvores.isEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return PlaylistCard(
                        playlist: playlist,
                        onPlay: () => _handlePlayPlaylist(context, ref, playlist),
                        onEdit: () => _showEditPlaylistDialog(context, playlist),
                        onShare: () => _handleSharePlaylist(context, playlist),
                        onDelete: () => _showDeletePlaylistDialog(context, playlist),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState(BuildContext context, bool carouselEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play,
            size: 64,
            color: AppColors.textDark.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhuma playlist encontrada',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (carouselEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Adicione louvores ao carousel na página principal e salve como playlist',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Você tem louvores no carousel. Clique em "Salvar Carousel" para criar uma playlist',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Mostra dialog para salvar playlist
  void _showSavePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SavePlaylistDialog(),
    );
  }

  /// Mostra dialog para editar playlist
  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => EditPlaylistDialog(playlist: playlist),
    );
  }

  /// Mostra dialog para deletar playlist
  void _showDeletePlaylistDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => DeletePlaylistDialog(playlist: playlist),
    );
  }

  /// Reproduz playlist (carrega no carousel)
  Future<void> _handlePlayPlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final louvoresAsync = ref.read(louvoresProvider);
    final louvores = await louvoresAsync.valueOrNull;

    if (louvores == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar louvores'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Mapear PDF IDs para louvores
    final carouselLouvores = <Louvor>[];
    for (final pdfId in playlist.pdfIds) {
      try {
        final louvor = louvores.firstWhere((l) => l.pdfId == pdfId);
        carouselLouvores.add(louvor);
      } catch (e) {
        // Louvor não encontrado (pode ter sido removido do manifest)
        debugPrint('Louvor não encontrado: $pdfId');
      }
    }

    // Limpar carousel atual
    final carouselNotifier = ref.read(carouselLouvoresProvider.notifier);
    await carouselNotifier.clear();

    // Adicionar louvores da playlist ao carousel
    for (final louvor in carouselLouvores) {
      await carouselNotifier.addLouvor(louvor);
    }

    // Navegar para home
    if (context.mounted) {
      context.go('/');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist "${playlist.nome}" carregada no carousel'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Compartilha playlist
  Future<void> _handleSharePlaylist(
    BuildContext context,
    Playlist playlist,
  ) async {
    try {
      // Gerar link compartilhável
      final pdfIdsString = playlist.pdfIds.join(',');
      final shareName = Uri.encodeComponent(playlist.nome);
      final link = '?sharepdfs=$pdfIdsString&sharename=$shareName';

      // Compartilhar
      await Share.share(
        'Compartilho a playlist "${playlist.nome}" do PLPCG:\n$link',
        subject: 'Playlist: ${playlist.nome}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Barra de pesquisa customizada para playlists
class _PlaylistSearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PlaylistSearchBar> createState() => _PlaylistSearchBarState();
}

class _PlaylistSearchBarState extends ConsumerState<_PlaylistSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(playlistSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(playlistSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(playlistSearchQueryProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppTextField(
        controller: _controller,
        hint: 'Pesquisar playlists...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textDark,
        ),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textDark,
                ),
                onPressed: _clearSearch,
              )
            : null,
        onChanged: _onSearchChanged,
      ),
    );
  }
}

