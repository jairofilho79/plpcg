import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/storage_keys.dart';
import '../../../core/utils/text_normalization.dart';
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

/// Provider para carregar categorias salvas do storage
final savedCategoriesProvider = FutureProvider<Set<String>>((ref) async {
  final localStorage = ref.watch(localStorageProvider);
  final saved = await localStorage.getStringList(StorageKeys.selectedCategories);
  return saved?.toSet() ?? <String>{};
});

/// Provider para categorias selecionadas (StateProvider)
final selectedCategoriesProvider = StateNotifierProvider<SelectedCategoriesNotifier, Set<String>>((ref) {
  final saved = ref.watch(savedCategoriesProvider);
  final notifier = SelectedCategoriesNotifier(ref, saved.valueOrNull ?? <String>{});
  // Carregar do storage quando o provider for criado
  saved.whenData((_) {
    notifier.loadFromStorage();
  });
  return notifier;
});

/// Notifier para gerenciar categorias selecionadas com persistência
class SelectedCategoriesNotifier extends StateNotifier<Set<String>> {
  SelectedCategoriesNotifier(this.ref, Set<String> initial) : super(initial);

  final Ref ref;

  Future<void> loadFromStorage() async {
    final localStorage = ref.read(localStorageProvider);
    final saved = await localStorage.getStringList(StorageKeys.selectedCategories);
    if (saved != null && saved.isNotEmpty) {
      state = saved.toSet();
    }
  }

  Future<void> toggleCategory(String category) async {
    final newState = Set<String>.from(state);
    if (newState.contains(category)) {
      newState.remove(category);
    } else {
      newState.add(category);
    }
    state = newState;
    await _saveToStorage();
  }

  Future<void> clear() async {
    state = <String>{};
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.saveStringList(StorageKeys.selectedCategories, state.toList());
  }
}

/// Provider para carregar classificações salvas do storage
final savedClassificationsProvider = FutureProvider<Set<String>>((ref) async {
  final localStorage = ref.watch(localStorageProvider);
  final saved = await localStorage.getStringList(StorageKeys.selectedClassifications);
  return saved?.toSet() ?? <String>{};
});

/// Provider para classificações selecionadas (StateProvider)
final selectedClassificationsProvider = StateNotifierProvider<SelectedClassificationsNotifier, Set<String>>((ref) {
  final saved = ref.watch(savedClassificationsProvider);
  final notifier = SelectedClassificationsNotifier(ref, saved.valueOrNull ?? <String>{});
  // Carregar do storage quando o provider for criado
  saved.whenData((_) {
    notifier.loadFromStorage();
  });
  return notifier;
});

/// Notifier para gerenciar classificações selecionadas com persistência
class SelectedClassificationsNotifier extends StateNotifier<Set<String>> {
  SelectedClassificationsNotifier(this.ref, Set<String> initial) : super(initial);

  final Ref ref;

  Future<void> loadFromStorage() async {
    final localStorage = ref.read(localStorageProvider);
    final saved = await localStorage.getStringList(StorageKeys.selectedClassifications);
    if (saved != null && saved.isNotEmpty) {
      state = saved.toSet();
    }
  }

  Future<void> toggleClassification(String classification) async {
    final newState = Set<String>.from(state);
    if (newState.contains(classification)) {
      newState.remove(classification);
    } else {
      newState.add(classification);
    }
    state = newState;
    await _saveToStorage();
  }

  Future<void> clear() async {
    state = <String>{};
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.saveStringList(StorageKeys.selectedClassifications, state.toList());
  }
}

/// Provider para louvores filtrados (computed)
/// Combina busca, categorias e classificações
final filteredLouvoresProvider = Provider<AsyncValue<List<Louvor>>>((ref) {
  final louvoresAsync = ref.watch(louvoresProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategories = ref.watch(selectedCategoriesProvider);
  final selectedClassifications = ref.watch(selectedClassificationsProvider);

  return louvoresAsync.when(
    data: (louvores) {
      var filtered = louvores;

      // Aplicar busca por query
      if (searchQuery.isNotEmpty) {
        final normalizedQuery = TextNormalization.normalizeText(searchQuery);
        filtered = filtered.where((louvor) {
          // Busca por número (exata)
          if (louvor.numero == searchQuery.trim()) {
            return true;
          }
          // Busca por nome (normalizada, parcial)
          return TextNormalization.containsNormalized(louvor.nome, searchQuery);
        }).toList();
      }

      // Aplicar filtro por categorias
      if (selectedCategories.isNotEmpty) {
        filtered = filtered.where((louvor) {
          // Lógica especial: "Cifra" inclui automaticamente "Cifra nível I" e "Cifra nível II"
          if (selectedCategories.contains('Cifra')) {
            return selectedCategories.contains(louvor.categoria) ||
                louvor.categoria == 'Cifra nível I' ||
                louvor.categoria == 'Cifra nível II';
          }
          return selectedCategories.contains(louvor.categoria);
        }).toList();
      }

      // Aplicar filtro por classificações
      if (selectedClassifications.isNotEmpty) {
        filtered = filtered.where((louvor) {
          // Normalizar classificação (remover parênteses se necessário)
          final normalizedClassification = _normalizeClassification(louvor.classificacao);
          return selectedClassifications.any((selected) {
            final normalizedSelected = _normalizeClassification(selected);
            return normalizedClassification == normalizedSelected;
          });
        }).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Normaliza classificação removendo parênteses e espaços extras
String _normalizeClassification(String classification) {
  return classification
      .replaceAll(RegExp(r'[()]'), '')
      .trim()
      .toLowerCase();
}

/// Provider para extrair classificações únicas dos louvores
final availableClassificationsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final louvoresAsync = ref.watch(louvoresProvider);
  
  return louvoresAsync.when(
    data: (louvores) {
      final classifications = louvores
          .map((l) => l.classificacao)
          .toSet()
          .toList()
        ..sort();
      return AsyncValue.data(classifications);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

