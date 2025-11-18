import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/playlist.dart';
import '../../core/errors/result.dart';
import '../providers/dependencies_provider.dart';

/// Dialog para editar nome da playlist
class EditPlaylistDialog extends ConsumerStatefulWidget {
  const EditPlaylistDialog({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  ConsumerState<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends ConsumerState<EditPlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.playlist.nome);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Playlist'),
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

    // Se o nome não mudou, apenas fechar
    if (nome == widget.playlist.nome) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = widget.playlist.copyWith(nome: nome);
      final notifier = ref.read(playlistsProvider.notifier);
      final result = await notifier.updatePlaylist(updated);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              switch (result) {
                Success() => 'Playlist atualizada com sucesso!',
                Error() => 'Erro ao atualizar playlist',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar playlist: $e'),
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

