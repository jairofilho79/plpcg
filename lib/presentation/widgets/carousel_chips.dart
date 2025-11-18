import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/louvor.dart';
import '../providers/dependencies_provider.dart';

/// Widget de chips horizontais scrolláveis para o carousel de louvores
class CarouselChips extends ConsumerStatefulWidget {
  const CarouselChips({
    super.key,
    this.onLouvorSelected,
  });

  /// Callback quando um louvor é selecionado
  final void Function(Louvor)? onLouvorSelected;

  @override
  ConsumerState<CarouselChips> createState() => _CarouselChipsState();
}

class _CarouselChipsState extends ConsumerState<CarouselChips> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedPdfId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Navega para um louvor específico
  void _navigateToLouvor(Louvor louvor) {
    setState(() {
      _selectedPdfId = louvor.pdfId;
    });

    // Scroll automático para o chip selecionado
    _scrollToSelected();

    // Chamar callback
    widget.onLouvorSelected?.call(louvor);
  }

  /// Faz scroll automático para o chip selecionado
  void _scrollToSelected() {
    if (_selectedPdfId == null) return;

    final carouselLouvores = ref.read(carouselLouvoresProvider);
    final index = carouselLouvores.indexWhere((l) => l.pdfId == _selectedPdfId);
    if (index == -1) return;

    // Aguardar o próximo frame para garantir que o ListView foi renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // Calcular posição aproximada (cada chip tem ~120px de largura + espaçamento)
      const chipWidth = 120.0;
      const spacing = AppSpacing.sm;
      final targetOffset = (index * (chipWidth + spacing)) - 50.0;

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Navega para o louvor anterior
  void _navigatePrevious() {
    final carouselLouvores = ref.read(carouselLouvoresProvider);
    if (carouselLouvores.isEmpty) return;

    final currentIndex = _selectedPdfId != null
        ? carouselLouvores.indexWhere((l) => l.pdfId == _selectedPdfId)
        : -1;

    if (currentIndex == -1 || currentIndex == 0) {
      // Se não há seleção ou está no primeiro, seleciona o último
      _navigateToLouvor(carouselLouvores.last);
    } else {
      // Seleciona o anterior
      _navigateToLouvor(carouselLouvores[currentIndex - 1]);
    }
  }

  /// Navega para o próximo louvor
  void _navigateNext() {
    final carouselLouvores = ref.read(carouselLouvoresProvider);
    if (carouselLouvores.isEmpty) return;

    final currentIndex = _selectedPdfId != null
        ? carouselLouvores.indexWhere((l) => l.pdfId == _selectedPdfId)
        : -1;

    if (currentIndex == -1 || currentIndex == carouselLouvores.length - 1) {
      // Se não há seleção ou está no último, seleciona o primeiro
      _navigateToLouvor(carouselLouvores.first);
    } else {
      // Seleciona o próximo
      _navigateToLouvor(carouselLouvores[currentIndex + 1]);
    }
  }

  /// Mostra modal de confirmação para limpar carousel
  Future<void> _showClearCarouselDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Limpar Carousel',
          style: AppTextStyles.heading5,
        ),
        content: Text(
          'Tem certeza que deseja remover todos os louvores do carousel?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Limpar',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final carouselNotifier = ref.read(carouselLouvoresProvider.notifier);
      await carouselNotifier.clear();
      setState(() {
        _selectedPdfId = null;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Carousel limpo'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carouselLouvores = ref.watch(carouselLouvoresProvider);

    if (carouselLouvores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Botão anterior (apenas se houver mais de 1 louvor)
          if (carouselLouvores.length > 1)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              color: AppColors.gold,
              onPressed: _navigatePrevious,
              tooltip: 'Louvor anterior',
            ),
          // Lista de chips scrollável
          Expanded(
            child: SizedBox(
              height: 80, // Altura fixa para o ListView horizontal
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                itemCount: carouselLouvores.length,
                itemBuilder: (context, index) {
                  final louvor = carouselLouvores[index];
                  final isSelected = _selectedPdfId == louvor.pdfId;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _CarouselChip(
                      louvor: louvor,
                      isSelected: isSelected,
                      onTap: () => _navigateToLouvor(louvor),
                    ),
                  );
                },
              ),
            ),
          ),
          // Botão próximo (apenas se houver mais de 1 louvor)
          if (carouselLouvores.length > 1)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              color: AppColors.gold,
              onPressed: _navigateNext,
              tooltip: 'Próximo louvor',
            ),
          // Botão limpar carousel
          IconButton(
            icon: const Icon(Icons.clear_all),
            color: AppColors.error,
            onPressed: () => _showClearCarouselDialog(context),
            tooltip: 'Limpar carousel',
          ),
        ],
      ),
    );
  }
}

/// Chip individual do carousel
class _CarouselChip extends StatelessWidget {
  const _CarouselChip({
    required this.louvor,
    required this.isSelected,
    required this.onTap,
  });

  final Louvor louvor;
  final bool isSelected;
  final VoidCallback onTap;

  /// Trunca o nome do louvor se necessário
  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength - 3)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.card,
          borderRadius: AppBorderRadius.largeRadius,
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número do louvor
            Text(
              louvor.numero,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.textDark : AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs / 2),
            // Nome do louvor (truncado)
            SizedBox(
              width: 100,
              child: Text(
                _truncateName(louvor.nome, 15),
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.textDark : AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

