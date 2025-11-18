import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/storage_keys.dart';
import '../../../data/datasources/api_client.dart';
import '../../../data/datasources/local_storage_service.dart';
import '../../../data/datasources/shared_prefs_service.dart';
import '../../../data/datasources/hive_storage_service.dart';
import '../../../data/datasources/louvores_api_service.dart';
import '../../../domain/repositories/louvores_repository.dart';
import '../../../data/repositories/louvores_repository_impl.dart';
import '../../../data/models/louvor.dart';
import '../../../core/errors/result.dart';

/// Provider para SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider para LocalStorageService (SharedPreferences)
final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences não inicializado');
  }
  return SharedPrefsService(prefs);
});

/// Provider para Hive Box de playlists
final playlistsBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox(StorageKeys.playlistsBox);
});

/// Provider para HiveStorageService
final hiveStorageProvider = Provider<HiveStorageService>((ref) {
  final box = ref.watch(playlistsBoxProvider).value;
  if (box == null) {
    throw Exception('Hive Box não inicializado');
  }
  return HiveStorageService(box);
});

/// Provider para ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider para LouvoresApiService
final louvoresApiServiceProvider = Provider<LouvoresApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LouvoresApiService(apiClient);
});

/// Provider para Hive Box de louvores
final louvoresBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox(StorageKeys.louvoresBox);
});

/// Provider para LouvoresRepository
final louvoresRepositoryProvider = Provider<LouvoresRepository>((ref) {
  final apiService = ref.watch(louvoresApiServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  final box = ref.watch(louvoresBoxProvider).value;
  if (box == null) {
    throw Exception('Louvores Box não inicializado');
  }
  return LouvoresRepositoryImpl(
    apiService: apiService,
    localStorage: localStorage,
    louvoresBox: box,
  );
});

/// Provider para buscar todos os louvores (FutureProvider)
final louvoresProvider = FutureProvider<List<Louvor>>((ref) async {
  final repository = ref.watch(louvoresRepositoryProvider);
  final result = await repository.getLouvores();
  return switch (result) {
    Success(data: final louvores) => louvores,
    Error(failure: final failure) => throw failure,
  };
});

/// Provider para query de busca (StateProvider)
final searchQueryProvider = StateProvider<String>((ref) => '');

