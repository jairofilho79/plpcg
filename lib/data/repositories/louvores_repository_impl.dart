import 'package:hive_flutter/hive_flutter.dart';
import '../../core/errors/result.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/louvores_repository.dart';
import '../models/louvor.dart';
import '../datasources/louvores_api_service.dart';
import '../datasources/local_storage_service.dart';

/// Implementação do repositório de louvores com cache e fallback
class LouvoresRepositoryImpl implements LouvoresRepository {
  LouvoresRepositoryImpl({
    required LouvoresApiService apiService,
    required LocalStorageService localStorage,
    required Box louvoresBox,
  })  : _apiService = apiService,
        _localStorage = localStorage,
        _louvoresBox = louvoresBox;

  final LouvoresApiService _apiService;
  final LocalStorageService _localStorage;
  final Box _louvoresBox;

  static const String _cacheKey = 'louvores_list';
  static const String _cacheTimestampKey = 'louvores_cache_timestamp';

  @override
  Future<Result<List<Louvor>>> getLouvores() async {
    // Tentar buscar da rede primeiro
    final networkResult = await _apiService.getLouvores();

    if (networkResult.isSuccess) {
      final louvores = networkResult.dataOrNull!;
      // Salvar no cache
      await cacheLouvores(louvores);
      return Success(louvores);
    }

    // Se falhar, tentar buscar do cache
    final cacheResult = await getCachedLouvores();
    if (cacheResult.isSuccess && cacheResult.dataOrNull!.isNotEmpty) {
      // Retornar cache com aviso de que pode estar desatualizado
      return Success(cacheResult.dataOrNull!);
    }

    // Se não houver cache, retornar erro da rede
    return networkResult.mapError((error) => error);
  }

  @override
  Future<Result<void>> cacheLouvores(List<Louvor> louvores) async {
    try {
      // Converter louvores para JSON e salvar no Hive
      final jsonList = louvores.map((louvor) => louvor.toJson()).toList();
      await _louvoresBox.put(_cacheKey, jsonList);
      
      // Salvar timestamp do cache
      await _localStorage.saveInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Erro ao salvar cache: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Louvor>>> getCachedLouvores() async {
    try {
      final cached = _louvoresBox.get(_cacheKey);
      
      if (cached == null) {
        return Success([]);
      }

      if (cached is! List) {
        return Error(CacheFailure('Formato de cache inválido'));
      }

      final List<dynamic> jsonList = cached;
      final louvores = jsonList
          .map((json) => Louvor.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(louvores);
    } catch (e) {
      return Error(CacheFailure('Erro ao ler cache: ${e.toString()}'));
    }
  }

  /// Limpa o cache de louvores
  Future<Result<void>> clearCache() async {
    try {
      await _louvoresBox.delete(_cacheKey);
      await _localStorage.remove(_cacheTimestampKey);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Erro ao limpar cache: ${e.toString()}'));
    }
  }

  /// Obtém o timestamp do último cache
  Future<DateTime?> getCacheTimestamp() async {
    final timestamp = await _localStorage.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}

