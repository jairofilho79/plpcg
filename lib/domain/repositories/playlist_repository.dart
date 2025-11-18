import '../../data/models/playlist.dart';
import '../../core/errors/result.dart';

/// Interface abstrata para repositório de playlists
abstract class PlaylistRepository {
  /// Busca todas as playlists
  Future<Result<List<Playlist>>> getPlaylists();

  /// Busca uma playlist por ID
  Future<Result<Playlist>> getPlaylistById(String id);

  /// Cria uma nova playlist
  Future<Result<Playlist>> createPlaylist(Playlist playlist);

  /// Atualiza uma playlist existente
  Future<Result<Playlist>> updatePlaylist(Playlist playlist);

  /// Deleta uma playlist
  Future<Result<void>> deletePlaylist(String id);

  /// Salva todas as playlists (para persistência)
  Future<Result<void>> savePlaylists(List<Playlist> playlists);
}

