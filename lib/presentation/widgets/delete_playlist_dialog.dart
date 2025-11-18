import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/playlist.dart';
import '../../core/errors/result.dart';
import '../providers/dependencies_provider.dart';

/// Dialog para confirmar remoção de playlist
class DeletePlaylistDialog extends ConsumerWidget {
  const DeletePlaylistDialog({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Remover Playlist'),
      content: Text('Tem certeza que deseja remover a playlist "${playlist.nome}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _handleDelete(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textLight,
          ),
          child: const Text('Remover'),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(playlistsProvider.notifier);
    final result = await notifier.deletePlaylist(playlist.id);

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            switch (result) {
              Success() => 'Playlist removida com sucesso!',
              Error() => 'Erro ao remover playlist',
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

