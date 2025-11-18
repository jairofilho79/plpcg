import 'package:freezed_annotation/freezed_annotation.dart';

part 'offline_package.freezed.dart';
part 'offline_package.g.dart';

/// Modelo de dados para um pacote ZIP offline
@freezed
class OfflinePackage with _$OfflinePackage {
  const factory OfflinePackage({
    required String filename,
    required String url,
    required int size,
    required String category,
  }) = _OfflinePackage;

  factory OfflinePackage.fromJson(Map<String, dynamic> json) =>
      _$OfflinePackageFromJson(json);
}

/// Modelo de dados para a estrutura de pacotes por categoria
@freezed
class OfflinePackageCategory with _$OfflinePackageCategory {
  const factory OfflinePackageCategory({
    required List<OfflinePackage> parts,
    @JsonKey(name: 'totalSize') required int totalSize,
  }) = _OfflinePackageCategory;

  factory OfflinePackageCategory.fromJson(Map<String, dynamic> json) =>
      _$OfflinePackageCategoryFromJson(json);
}

/// Modelo de dados para o manifesto offline completo
@freezed
class OfflineManifest with _$OfflineManifest {
  const factory OfflineManifest({
    required Map<String, OfflinePackageCategory> packages,
  }) = _OfflineManifest;

  factory OfflineManifest.fromJson(Map<String, dynamic> json) =>
      _$OfflineManifestFromJson(json);
}

