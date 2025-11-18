import 'package:hive_flutter/hive_flutter.dart';
import 'local_storage_service.dart';

/// Implementação de LocalStorageService usando Hive
/// Para dados estruturados complexos (como Playlists)
class HiveStorageService implements LocalStorageService {
  HiveStorageService(this._box);

  final Box _box;

  @override
  Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _box.get(key) as String?;
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _box.put(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _box.get(key) as int?;
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _box.put(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _box.get(key) as bool?;
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    await _box.put(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _box.get(key);
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  /// Método específico do Hive para obter uma Box
  Box get box => _box;
}

