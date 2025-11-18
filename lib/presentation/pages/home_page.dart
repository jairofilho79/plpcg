import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/search_bar.dart' as search_widget;
import '../widgets/louvores_list_view.dart';
import '../widgets/category_filters.dart';
import '../widgets/classification_filters.dart';
import '../widgets/active_filters_indicator.dart';

/// Página inicial da aplicação
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showHeader: true,
      title: null, // Título padrão "PLPCG" será usado
      actions: [
        // Botão Biblioteca
        IconButton(
          icon: const Icon(Icons.library_books),
          color: AppColors.textLight,
          tooltip: 'Biblioteca',
          onPressed: () => context.go('/biblioteca'),
        ),
        // Botão Offline
        IconButton(
          icon: const Icon(Icons.offline_bolt),
          color: AppColors.textLight,
          tooltip: 'Offline',
          onPressed: () => context.go('/offline'),
        ),
        // Botão Listas
        IconButton(
          icon: const Icon(Icons.playlist_play),
          color: AppColors.textLight,
          tooltip: 'Listas',
          onPressed: () => context.go('/listas'),
        ),
        // Botão Sobre
        IconButton(
          icon: const Icon(Icons.info_outline),
          color: AppColors.textLight,
          tooltip: 'Sobre',
          onPressed: () => context.go('/sobre'),
        ),
      ],
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
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
            // Indicador de filtros ativos
            const ActiveFiltersIndicator(),
            const SizedBox(height: AppSpacing.sm),
            // Lista de louvores
            Expanded(
              child: LouvoresListView(
                onLouvorTap: (louvor) {
                  // TODO: Implementar ação ao clicar no louvor (Fase 4)
                  // Por enquanto, apenas mostra um snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Louvor: ${louvor.nome}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

