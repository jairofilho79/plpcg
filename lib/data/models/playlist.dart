import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

/// Modelo de dados para uma Playlist
@freezed
@HiveType(typeId: 0)
class Playlist with _$Playlist {
  const factory Playlist({
    @HiveField(0) required String id,
    @HiveField(1) required String nome,
    @HiveField(2) required List<String> pdfIds,
    @HiveField(3) @Default(false) bool favorita,
    @HiveField(4) required DateTime createdAt,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}

