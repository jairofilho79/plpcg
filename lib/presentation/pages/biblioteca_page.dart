import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/louvor.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/search_bar.dart' as search_widget;
import '../widgets/category_filters.dart';
import '../widgets/classification_filters.dart';
import '../widgets/active_filters_indicator.dart';
import '../widgets/pdf_viewer_selector.dart';
import '../widgets/sort_selector.dart';
import '../widgets/items_per_page_selector.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/louvores_paginated_list_view.dart';
import '../providers/dependencies_provider.dart';

/// Página de biblioteca com paginação e ordenação
class BibliotecaPage extends ConsumerStatefulWidget {
  const BibliotecaPage({super.key});

  @override
  ConsumerState<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends ConsumerState<BibliotecaPage> {
  @override
  void initState() {
    super.initState();
    // Resetar página para 1 quando entrar na página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observar mudanças nos filtros e resetar página
    ref.listen(filteredLouvoresProvider, (previous, next) {
      if (previous != null && next.valueOrNull != previous.valueOrNull) {
        // Filtros mudaram, resetar para página 1
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentPageProvider.notifier).state = 1;
        });
      }
    });

    // Observar mudanças na ordenação e resetar página
    ref.listen(sortOrderProvider, (previous, next) {
      if (previous != next) {
        // Ordenação mudou, resetar para página 1
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentPageProvider.notifier).state = 1;
        });
      }
    });

    return AppScaffold(
      showHeader: true,
      title: 'Biblioteca',
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular altura mínima da área de lista para garantir 2 linhas de cards
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth > 1024
            ? ((screenWidth - (AppSpacing.md * 4)) / 3).clamp(200.0, 350.0)
            : screenWidth > 600
                ? ((screenWidth - (AppSpacing.md * 3)) / 2).clamp(200.0, 300.0)
                : screenWidth - (AppSpacing.md * 2);
        final cardHeight = cardWidth / 0.65; // aspectRatio = 0.65
        final minListHeight = (cardHeight + AppSpacing.md) * 2; // 2 linhas + spacing
        
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Barra de pesquisa
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: search_widget.SearchBar(),
                  ),
                  // Filtros de categoria
                  const CategoryFilters(),
                  const SizedBox(height: AppSpacing.sm),
                  // Filtros de classificação
                  const ClassificationFilters(),
                  const SizedBox(height: AppSpacing.sm),
                  // Seletor de modo de visualização de PDF
                  const PdfViewerSelector(),
                  const SizedBox(height: AppSpacing.sm),
                  // Indicador de filtros ativos
                  const ActiveFiltersIndicator(),
                  const SizedBox(height: AppSpacing.sm),
                  // Seletor de ordenação
                  const SortSelector(),
                  const SizedBox(height: AppSpacing.sm),
                  // Seletor de itens por página
                  const ItemsPerPageSelector(),
                  const SizedBox(height: AppSpacing.sm),
                  // Controles de paginação
                  const PaginationControls(),
                  const SizedBox(height: AppSpacing.sm),
                  // Lista paginada de louvores com altura mínima
                  SizedBox(
                    height: minListHeight,
                    child: LouvoresPaginatedListView(
                      onLouvorTap: (louvor) {
                        // Ação de PDF é tratada diretamente no LouvorCard
                        // Este callback pode ser usado para outras ações futuras
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

