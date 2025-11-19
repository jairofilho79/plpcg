import 'package:flutter/foundation.dart';
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
import '../../../domain/repositories/playlist_repository.dart';
import '../../../data/repositories/playlist_repository_impl.dart';
import '../../../data/models/louvor.dart';
import '../../../data/models/playlist.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/failures.dart';
import '../../../core/models/pdf_viewer_mode.dart';
import '../../../core/services/pdf_action_service.dart';
import '../../../core/models/sort_order.dart' show SortOrder, SortOrderExtension, sortOrderFromStorageString;

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

/// Provider para modo preferido de visualização de PDF (StateNotifierProvider)
final preferredPdfViewerModeProvider = StateNotifierProvider<PreferredPdfViewerModeNotifier, PdfViewerMode>((ref) {
  final notifier = PreferredPdfViewerModeNotifier(ref);
  // Carregar do storage na inicialização (não bloqueia)
  Future.microtask(() => notifier.loadFromStorage());
  return notifier;
});

/// Notifier para gerenciar modo preferido de visualização com persistência
class PreferredPdfViewerModeNotifier extends StateNotifier<PdfViewerMode> {
  PreferredPdfViewerModeNotifier(this.ref) : super(PdfViewerMode.online) {
    // Inicializar com valor padrão, será atualizado pelo loadFromStorage
  }

  final Ref ref;
  bool _isLoading = false;

  Future<void> loadFromStorage() async {
    if (_isLoading || !mounted) return; // Evitar múltiplas chamadas simultâneas
    _isLoading = true;
    
    try {
      // Aguardar SharedPreferences estar pronto
      final prefsAsync = ref.read(sharedPreferencesProvider);
      final prefs = prefsAsync.valueOrNull;
      
      if (prefs != null) {
        try {
          final localStorage = ref.read(localStorageProvider);
          final saved = await localStorage.getString(StorageKeys.preferredPdfViewerMode);
          if (saved != null && mounted) {
            final mode = PdfViewerModeExtension.fromJson(saved);
            // Só atualizar se for diferente do estado atual
            if (state != mode) {
              debugPrint('Carregando modo preferido do storage: ${mode.toJson()}');
              state = mode;
            }
          }
        } catch (e) {
          debugPrint('Erro ao carregar modo preferido: $e');
        }
      } else {
        // Se não estiver pronto, aguardar um pouco e tentar novamente
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isLoading && mounted) {
          // Se ainda não estiver carregando (não foi cancelado), tentar novamente
          _isLoading = false;
          loadFromStorage();
          return;
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar modo preferido: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setMode(PdfViewerMode mode) async {
    if (!mounted) {
      debugPrint('Tentativa de alterar modo após dispose');
      return;
    }
    
    if (state == mode) {
      // Já está no modo selecionado, não precisa fazer nada
      return;
    }
    
    debugPrint('Alterando modo de visualização de ${state.toJson()} para ${mode.toJson()}');
    
    // Atualizar estado imediatamente (síncrono)
    if (mounted) {
      state = mode;
    }
    
    // Salvar de forma assíncrona
    if (mounted) {
      await _saveToStorage();
      if (mounted) {
        debugPrint('Modo salvo: ${state.toJson()}');
      }
    }
  }

  Future<void> _saveToStorage() async {
    if (!mounted) {
      debugPrint('Tentativa de salvar após dispose');
      return;
    }
    
    try {
      // Aguardar SharedPreferences estar pronto
      final prefsAsync = ref.read(sharedPreferencesProvider);
      final prefs = prefsAsync.valueOrNull;
      
      if (prefs != null && mounted) {
        try {
          final localStorage = ref.read(localStorageProvider);
          await localStorage.saveString(StorageKeys.preferredPdfViewerMode, state.toJson());
        } catch (e) {
          debugPrint('Erro ao salvar modo preferido: $e');
        }
      } else if (mounted) {
        // Se não estiver pronto, tentar novamente após um delay
        debugPrint('SharedPreferences ainda carregando, tentando novamente...');
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _saveToStorage();
          }
        });
      }
    } catch (e) {
      // Log do erro mas não interrompe a atualização do estado
      debugPrint('Erro ao salvar modo preferido: $e');
    }
  }
}

/// Provider para PdfActionService
final pdfActionServiceProvider = Provider<PdfActionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PdfActionService(apiClient);
});

/// Provider para carregar PDF IDs do carousel salvos do storage
final savedCarouselPdfIdsProvider = FutureProvider<List<String>>((ref) async {
  final localStorage = ref.watch(localStorageProvider);
  final saved = await localStorage.getStringList(StorageKeys.carouselPdfIds);
  return saved ?? <String>[];
});

/// Provider para louvores do carousel (StateNotifierProvider)
final carouselLouvoresProvider = StateNotifierProvider<CarouselLouvoresNotifier, List<Louvor>>((ref) {
  final notifier = CarouselLouvoresNotifier(ref, <Louvor>[]);
  
  // Carregar do storage quando os dados estiverem prontos
  final saved = ref.watch(savedCarouselPdfIdsProvider);
  final louvoresAsync = ref.watch(louvoresProvider);
  
  // Aguardar ambos estarem prontos antes de carregar
  saved.whenData((pdfIds) {
    louvoresAsync.whenData((louvores) {
      // Usar Future.microtask para evitar chamadas durante build
      Future.microtask(() {
        notifier.loadFromStorage(pdfIds, louvores);
      });
    });
  });
  
  return notifier;
});

/// Notifier para gerenciar louvores do carousel com persistência
class CarouselLouvoresNotifier extends StateNotifier<List<Louvor>> {
  CarouselLouvoresNotifier(this.ref, List<Louvor> initial) : super(initial);

  final Ref ref;
  bool _hasLoaded = false;

  /// Carrega louvores do carousel baseado nos PDF IDs salvos
  void loadFromStorage(List<String> pdfIds, List<Louvor> allLouvores) {
    if (_hasLoaded) return; // Evitar recarregar múltiplas vezes
    _hasLoaded = true;

    if (pdfIds.isEmpty) {
      state = <Louvor>[];
      return;
    }

    // Mapear PDF IDs para louvores, filtrando apenas os que existem
    final carouselLouvores = <Louvor>[];
    for (final pdfId in pdfIds) {
      try {
        final louvor = allLouvores.firstWhere(
          (l) => l.pdfId == pdfId,
        );
        carouselLouvores.add(louvor);
      } catch (e) {
        // Louvor não encontrado (pode ter sido removido do manifest)
        debugPrint('Louvor não encontrado no manifest: $pdfId');
      }
    }

    state = carouselLouvores;
  }

  /// Adiciona um louvor ao carousel
  Future<void> addLouvor(Louvor louvor) async {
    // Verificar se já existe (evitar duplicatas)
    if (state.any((l) => l.pdfId == louvor.pdfId)) {
      debugPrint('Louvor já está no carousel: ${louvor.pdfId}');
      return;
    }

    final newState = List<Louvor>.from(state)..add(louvor);
    state = newState;
    await _saveToStorage();
  }

  /// Remove um louvor do carousel
  Future<void> removeLouvor(String pdfId) async {
    final newState = state.where((l) => l.pdfId != pdfId).toList();
    state = newState;
    await _saveToStorage();
  }

  /// Limpa todos os louvores do carousel
  Future<void> clear() async {
    state = <Louvor>[];
    await _saveToStorage();
  }

  /// Salva PDF IDs no storage
  Future<void> _saveToStorage() async {
    try {
      final localStorage = ref.read(localStorageProvider);
      final pdfIds = state.map((l) => l.pdfId).toList();
      await localStorage.saveStringList(StorageKeys.carouselPdfIds, pdfIds);
      debugPrint('Carousel salvo: ${pdfIds.length} louvores');
    } catch (e) {
      debugPrint('Erro ao salvar carousel: $e');
    }
  }
}

/// Provider para PlaylistRepository
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final box = ref.watch(playlistsBoxProvider).value;
  if (box == null) {
    throw Exception('Playlists Box não inicializado');
  }
  return PlaylistRepositoryImpl(box: box);
});

/// Provider para playlists (StateNotifierProvider)
final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  final notifier = PlaylistsNotifier(ref, <Playlist>[]);
  
  // Carregar do storage quando o repository estiver pronto
  final repository = ref.watch(playlistRepositoryProvider);
  Future.microtask(() async {
    final result = await repository.getPlaylists();
    if (result.isSuccess) {
      notifier.loadFromStorage(result.dataOrNull!);
    }
  });
  
  return notifier;
});

/// Notifier para gerenciar playlists com persistência
class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  PlaylistsNotifier(this.ref, List<Playlist> initial) : super(initial);

  final Ref ref;
  bool _hasLoaded = false;

  /// Carrega playlists do storage
  void loadFromStorage(List<Playlist> playlists) {
    if (_hasLoaded) return; // Evitar recarregar múltiplas vezes
    _hasLoaded = true;
    state = playlists;
  }

  /// Cria uma nova playlist
  Future<Result<Playlist>> createPlaylist(Playlist playlist) async {
    try {
      final repository = ref.read(playlistRepositoryProvider);
      final result = await repository.createPlaylist(playlist);
      
      if (result.isSuccess) {
        final newState = List<Playlist>.from(state)..add(result.dataOrNull!);
        state = newState;
      }
      
      return result;
    } catch (e) {
      return Error(CacheFailure('Erro ao criar playlist: ${e.toString()}'));
    }
  }

  /// Atualiza uma playlist existente
  Future<Result<Playlist>> updatePlaylist(Playlist playlist) async {
    try {
      final repository = ref.read(playlistRepositoryProvider);
      final result = await repository.updatePlaylist(playlist);
      
      if (result.isSuccess) {
        final index = state.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          final newState = List<Playlist>.from(state);
          newState[index] = result.dataOrNull!;
          state = newState;
        }
      }
      
      return result;
    } catch (e) {
      return Error(CacheFailure('Erro ao atualizar playlist: ${e.toString()}'));
    }
  }

  /// Deleta uma playlist
  Future<Result<void>> deletePlaylist(String id) async {
    try {
      final repository = ref.read(playlistRepositoryProvider);
      final result = await repository.deletePlaylist(id);
      
      if (result.isSuccess) {
        final newState = state.where((p) => p.id != id).toList();
        state = newState;
      }
      
      return result;
    } catch (e) {
      return Error(CacheFailure('Erro ao deletar playlist: ${e.toString()}'));
    }
  }

  /// Toggle favorita de uma playlist
  Future<Result<Playlist>> toggleFavorita(String id) async {
    try {
      final playlist = state.firstWhere((p) => p.id == id);
      final updated = playlist.copyWith(favorita: !playlist.favorita);
      return await updatePlaylist(updated);
    } catch (e) {
      return Error(CacheFailure('Erro ao favoritar playlist: ${e.toString()}'));
    }
  }
}

/// Provider para query de busca de playlists (StateProvider)
final playlistSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para filtro de favoritas (StateProvider)
final playlistFavoritesFilterProvider = StateProvider<bool>((ref) => false);

/// Provider para playlists filtradas (computed)
final filteredPlaylistsProvider = Provider<List<Playlist>>((ref) {
  final playlists = ref.watch(playlistsProvider);
  final searchQuery = ref.watch(playlistSearchQueryProvider);
  final favoritesOnly = ref.watch(playlistFavoritesFilterProvider);

  var filtered = playlists;

  // Aplicar busca por nome
  if (searchQuery.isNotEmpty) {
    final normalizedQuery = TextNormalization.normalizeText(searchQuery);
    filtered = filtered.where((playlist) {
      return TextNormalization.containsNormalized(playlist.nome, searchQuery);
    }).toList();
  }

  // Aplicar filtro de favoritas
  if (favoritesOnly) {
    filtered = filtered.where((playlist) => playlist.favorita).toList();
  }

  // Ordenar: favoritas primeiro, depois por data de criação (mais recente primeiro)
  filtered.sort((a, b) {
    if (a.favorita && !b.favorita) return -1;
    if (!a.favorita && b.favorita) return 1;
    return b.createdAt.compareTo(a.createdAt);
  });

  return filtered;
});

// ========== FASE 7: Providers de Ordenação e Paginação ==========

/// Provider para carregar ordenação salva do storage
final savedSortOrderProvider = FutureProvider<SortOrder>((ref) async {
  final localStorage = ref.watch(localStorageProvider);
  final saved = await localStorage.getString(StorageKeys.sortOrder);
  return saved != null 
      ? sortOrderFromStorageString(saved)
      : SortOrder.number;
});

/// Provider para ordenação (StateNotifierProvider)
final sortOrderProvider = StateNotifierProvider<SortOrderNotifier, SortOrder>((ref) {
  final saved = ref.watch(savedSortOrderProvider);
  final notifier = SortOrderNotifier(ref, saved.valueOrNull ?? SortOrder.number);
  // Carregar do storage quando o provider for criado
  saved.whenData((order) {
    notifier.loadFromStorage();
  });
  return notifier;
});

/// Notifier para gerenciar ordenação com persistência
class SortOrderNotifier extends StateNotifier<SortOrder> {
  SortOrderNotifier(this.ref, SortOrder initial) : super(initial);

  final Ref ref;

  Future<void> loadFromStorage() async {
    final localStorage = ref.read(localStorageProvider);
    final saved = await localStorage.getString(StorageKeys.sortOrder);
    if (saved != null) {
      state = sortOrderFromStorageString(saved);
    }
  }

  Future<void> setSortOrder(SortOrder order) async {
    state = order;
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.saveString(StorageKeys.sortOrder, state.toStorageString());
  }
}

/// Provider para carregar itens por página salvos do storage
final savedItemsPerPageProvider = FutureProvider<int>((ref) async {
  final localStorage = ref.watch(localStorageProvider);
  final saved = await localStorage.getInt(StorageKeys.itemsPerPage);
  return (saved != null && saved > 0) ? saved : 20; // Padrão: 20 itens por página
});

/// Provider para itens por página (StateNotifierProvider)
final itemsPerPageProvider = StateNotifierProvider<ItemsPerPageNotifier, int>((ref) {
  final saved = ref.watch(savedItemsPerPageProvider);
  final notifier = ItemsPerPageNotifier(ref, saved.valueOrNull ?? 20);
  // Carregar do storage quando o provider for criado
  saved.whenData((_) {
    notifier.loadFromStorage();
  });
  return notifier;
});

/// Notifier para gerenciar itens por página com persistência
class ItemsPerPageNotifier extends StateNotifier<int> {
  ItemsPerPageNotifier(this.ref, int initial) : super(initial);

  final Ref ref;

  Future<void> loadFromStorage() async {
    final localStorage = ref.read(localStorageProvider);
    final saved = await localStorage.getInt(StorageKeys.itemsPerPage);
    if (saved != null && saved > 0) {
      state = saved;
    }
  }

  Future<void> setItemsPerPage(int items) async {
    state = items;
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.saveInt(StorageKeys.itemsPerPage, state);
  }
}

/// Provider para página atual (StateProvider)
final currentPageProvider = StateProvider<int>((ref) => 1);

/// Provider para louvores ordenados (computed)
final sortedLouvoresProvider = Provider<AsyncValue<List<Louvor>>>((ref) {
  final filteredAsync = ref.watch(filteredLouvoresProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  return filteredAsync.when(
    data: (louvores) {
      final sorted = List<Louvor>.from(louvores);
      
      switch (sortOrder) {
        case SortOrder.number:
          sorted.sort((a, b) {
            // Converter números para int para ordenação numérica
            final numA = int.tryParse(a.numero) ?? 0;
            final numB = int.tryParse(b.numero) ?? 0;
            return numA.compareTo(numB);
          });
          break;
        case SortOrder.name:
          sorted.sort((a, b) {
            // Ordenação alfabética normalizada
            final nameA = TextNormalization.normalizeText(a.nome);
            final nameB = TextNormalization.normalizeText(b.nome);
            return nameA.compareTo(nameB);
          });
          break;
      }
      
      return AsyncValue.data(sorted);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para louvores paginados (computed)
final paginatedLouvoresProvider = Provider<AsyncValue<List<Louvor>>>((ref) {
  final sortedAsync = ref.watch(sortedLouvoresProvider);
  final currentPage = ref.watch(currentPageProvider);
  final itemsPerPage = ref.watch(itemsPerPageProvider);

  return sortedAsync.when(
    data: (louvores) {
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = startIndex + itemsPerPage;
      final paginated = louvores.sublist(
        startIndex.clamp(0, louvores.length),
        endIndex.clamp(0, louvores.length),
      );
      return AsyncValue.data(paginated);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para total de páginas (computed)
final totalPagesProvider = Provider<AsyncValue<int>>((ref) {
  final sortedAsync = ref.watch(sortedLouvoresProvider);
  final itemsPerPage = ref.watch(itemsPerPageProvider);

  return sortedAsync.when(
    data: (louvores) {
      final totalPages = (louvores.length / itemsPerPage).ceil();
      return AsyncValue.data(totalPages > 0 ? totalPages : 1);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

