import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';
import '../../data/models/playlist.dart';
import '../../core/errors/result.dart';

/// Dialog para salvar carousel como playlist
class SavePlaylistDialog extends ConsumerStatefulWidget {
  const SavePlaylistDialog({super.key});

  @override
  ConsumerState<SavePlaylistDialog> createState() => _SavePlaylistDialogState();
}

class _SavePlaylistDialogState extends ConsumerState<SavePlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salvar Playlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da playlist',
                hintText: 'Digite o nome da playlist',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome é obrigatório';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.textDark,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final carouselLouvores = ref.read(carouselLouvoresProvider);

    if (carouselLouvores.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O carousel está vazio'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Verificar se já existe playlist com mesmo nome
      final playlists = ref.read(playlistsProvider);
      if (playlists.any((p) => p.nome == nome)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Já existe uma playlist com este nome'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // Criar playlist
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: nome,
        pdfIds: carouselLouvores.map((l) => l.pdfId).toList(),
        favorita: false,
        createdAt: DateTime.now(),
      );

      final notifier = ref.read(playlistsProvider.notifier);
      final result = await notifier.createPlaylist(playlist);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              switch (result) {
                Success() => 'Playlist "$nome" salva com sucesso!',
                Error() => 'Erro ao salvar playlist',
              },
            ),
            backgroundColor: switch (result) {
              Success() => AppColors.success,
              Error() => AppColors.error,
            },
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar playlist: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

