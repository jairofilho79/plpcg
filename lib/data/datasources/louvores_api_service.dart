import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/result.dart';
import '../models/louvor.dart';
import '../models/offline_package.dart';
import 'api_client.dart';

/// Serviço para endpoints relacionados a louvores
class LouvoresApiService {
  LouvoresApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Busca o manifesto de louvores
  Future<Result<List<Louvor>>> getLouvores() async {
    final result = await _apiClient.get(ApiConstants.louvoresManifest);

    return result.map((response) {
      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList
            .map((json) => Louvor.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw FormatException('Resposta inválida: esperado List');
    });
  }

  /// Busca o manifesto offline
  Future<Result<OfflineManifest>> getOfflineManifest() async {
    final result = await _apiClient.get(ApiConstants.offlineManifest);

    return result.map((response) {
      return OfflineManifest.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Busca um pacote ZIP
  Future<Result<Response>> downloadPackage(
    String filename,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final urlPath = '${ApiConstants.packagesPath}/$filename';
    return _apiClient.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Busca um PDF individual
  Future<Result<Response>> getPdf(
    String classificacao,
    String filename, {
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    final urlPath = '${ApiConstants.assetsPath}/$classificacao/$filename';
    return _apiClient.get(
      urlPath,
      options: options ??
          Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
    );
  }
}

