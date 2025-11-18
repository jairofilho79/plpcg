import '../../data/models/louvor.dart';
import '../../core/errors/result.dart';

/// Interface abstrata para repositório de louvores
abstract class LouvoresRepository {
  /// Busca todos os louvores (rede → cache → erro)
  Future<Result<List<Louvor>>> getLouvores();

  /// Salva louvores no cache local
  Future<Result<void>> cacheLouvores(List<Louvor> louvores);

  /// Busca louvores do cache local
  Future<Result<List<Louvor>>> getCachedLouvores();
}

