/// Interface abstrata para serviços de armazenamento local
abstract class LocalStorageService {
  /// Salva um valor String
  Future<void> saveString(String key, String value);

  /// Obtém um valor String
  Future<String?> getString(String key);

  /// Salva um valor int
  Future<void> saveInt(String key, int value);

  /// Obtém um valor int
  Future<int?> getInt(String key);

  /// Salva um valor bool
  Future<void> saveBool(String key, bool value);

  /// Obtém um valor bool
  Future<bool?> getBool(String key);

  /// Salva uma lista de Strings
  Future<void> saveStringList(String key, List<String> value);

  /// Obtém uma lista de Strings
  Future<List<String>?> getStringList(String key);

  /// Remove um valor
  Future<void> remove(String key);

  /// Remove todos os valores
  Future<void> clear();

  /// Verifica se uma chave existe
  Future<bool> containsKey(String key);
}

