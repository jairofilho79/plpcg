import 'package:hive_flutter/hive_flutter.dart';
import '../../core/errors/result.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist.dart';

/// Implementação do repositório de playlists usando Hive
class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl({required Box box}) : _box = box;

  final Box _box;
  static const String _playlistsKey = 'playlists_list';

  @override
  Future<Result<List<Playlist>>> getPlaylists() async {
    try {
      final cached = _box.get(_playlistsKey);
      
      if (cached == null) {
        return const Success([]);
      }

      if (cached is! List) {
        return Error(CacheFailure('Formato de playlists inválido'));
      }

      final List<dynamic> jsonList = cached;
      final playlists = jsonList
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(playlists);
    } catch (e) {
      return Error(CacheFailure('Erro ao ler playlists: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Playlist>> getPlaylistById(String id) async {
    try {
      final result = await getPlaylists();
      if (result.isError) {
        return Error(result.failureOrNull ?? CacheFailure('Erro desconhecido'));
      }

      final playlists = result.dataOrNull!;
      final playlist = playlists.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Playlist não encontrada'),
      );

      return Success(playlist);
    } catch (e) {
      return Error(CacheFailure('Erro ao buscar playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Playlist>> createPlaylist(Playlist playlist) async {
    try {
      final result = await getPlaylists();
      if (result.isError) {
        return Error(result.failureOrNull ?? CacheFailure('Erro desconhecido'));
      }

      final playlists = List<Playlist>.from(result.dataOrNull!);
      
      // Verificar se já existe playlist com mesmo nome
      if (playlists.any((p) => p.nome == playlist.nome && p.id != playlist.id)) {
        return Error(CacheFailure('Já existe uma playlist com este nome'));
      }

      playlists.add(playlist);
      final saveResult = await savePlaylists(playlists);
      if (saveResult.isError) {
        return Error(saveResult.failureOrNull ?? CacheFailure('Erro ao salvar'));
      }

      return Success(playlist);
    } catch (e) {
      return Error(CacheFailure('Erro ao criar playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Playlist>> updatePlaylist(Playlist playlist) async {
    try {
      final result = await getPlaylists();
      if (result.isError) {
        return Error(result.failureOrNull ?? CacheFailure('Erro desconhecido'));
      }

      final playlists = List<Playlist>.from(result.dataOrNull!);
      final index = playlists.indexWhere((p) => p.id == playlist.id);
      
      if (index == -1) {
        return Error(CacheFailure('Playlist não encontrada'));
      }

      // Verificar se já existe playlist com mesmo nome (exceto a atual)
      if (playlists.any((p) => p.nome == playlist.nome && p.id != playlist.id)) {
        return Error(CacheFailure('Já existe uma playlist com este nome'));
      }

      playlists[index] = playlist;
      final saveResult = await savePlaylists(playlists);
      if (saveResult.isError) {
        return Error(saveResult.failureOrNull ?? CacheFailure('Erro ao salvar'));
      }

      return Success(playlist);
    } catch (e) {
      return Error(CacheFailure('Erro ao atualizar playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> deletePlaylist(String id) async {
    try {
      final result = await getPlaylists();
      if (result.isError) {
        return result.mapError((error) => error);
      }

      final playlists = result.dataOrNull!
          .where((p) => p.id != id)
          .toList();
      
      await savePlaylists(playlists);

      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Erro ao deletar playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> savePlaylists(List<Playlist> playlists) async {
    try {
      final jsonList = playlists.map((p) => p.toJson()).toList();
      await _box.put(_playlistsKey, jsonList);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Erro ao salvar playlists: ${e.toString()}'));
    }
  }
}

