import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Toolbar do leitor de PDF com controles avançados
class PdfViewerToolbar extends StatelessWidget {
  const PdfViewerToolbar({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.currentPage,
    required this.totalPages,
    required this.zoomLevel,
    required this.isPageWidthMode,
    required this.isZoomFitMode,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    this.onFirstPage,
    this.onLastPage,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleFit,
    required this.onResetZoom,
    required this.onClose,
  });

  final String titulo;
  final String subtitulo;
  final int currentPage;
  final int totalPages;
  final double zoomLevel;
  final bool isPageWidthMode;
  final bool isZoomFitMode;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onFirstPage;
  final VoidCallback? onLastPage;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleFit;
  final VoidCallback onResetZoom;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Brand "PLPCG" (esquerda)
          _buildBrand(),
          
          // Título e subtítulo (centro)
          Expanded(
            child: _buildTitleSection(),
          ),
          
          // Botão anterior
          _buildNavButton(
            icon: Icons.arrow_back_ios,
            onPressed: canGoPrevious ? onPrevious : null,
            onLongPress: canGoPrevious && onFirstPage != null ? () {
              // Long press: primeira página
              HapticFeedback.mediumImpact();
              onFirstPage!();
            } : null,
          ),
          
          // Indicador de página
          _buildPageIndicator(),
          
          // Botão próxima
          _buildNavButton(
            icon: Icons.arrow_forward_ios,
            onPressed: canGoNext ? onNext : null,
            onLongPress: canGoNext && onLastPage != null ? () {
              // Long press: última página
              HapticFeedback.mediumImpact();
              onLastPage!();
            } : null,
          ),
          
          // Controles de zoom (ocultos em mobile)
          if (!isMobile) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildZoomOutButton(),
            const SizedBox(width: AppSpacing.xs),
            _buildZoomIndicator(),
            const SizedBox(width: AppSpacing.xs),
            _buildZoomInButton(),
          ],
        ],
      ),
    );
  }

  /// Brand "PLPCG"
  Widget _buildBrand() {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(
          'PLPCG',
          style: AppTextStyles.heading5.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Seção de título e subtítulo
  Widget _buildTitleSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (titulo.isNotEmpty)
            Text(
              titulo,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (subtitulo.isNotEmpty)
            Text(
              subtitulo,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Botão de navegação
  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        color: onPressed != null
            ? Colors.transparent
            : AppColors.textDark.withOpacity(0.3),
        child: Icon(
          icon,
          color: onPressed != null
              ? AppColors.gold
              : AppColors.textDark.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }

  /// Indicador de página
  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        '$currentPage / $totalPages',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textLight,
        ),
      ),
    );
  }

  /// Botão zoom out
  Widget _buildZoomOutButton() {
    final canZoomOut = zoomLevel > 0.25;
    return IconButton(
      icon: const Icon(Icons.remove),
      color: canZoomOut ? AppColors.gold : AppColors.textDark.withOpacity(0.5),
      iconSize: 20,
      onPressed: canZoomOut ? onZoomOut : null,
      tooltip: 'Diminuir zoom',
    );
  }

  /// Indicador de zoom
  Widget _buildZoomIndicator() {
    return GestureDetector(
      onTap: onToggleFit,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onResetZoom();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isZoomFitMode
                  ? (isPageWidthMode
                      ? Icons.fit_screen
                      : Icons.aspect_ratio)
                  : Icons.zoom_in,
              size: 16,
              color: AppColors.gold,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isZoomFitMode
                  ? (isPageWidthMode
                      ? 'Largura'
                      : 'Altura')
                  : '${(zoomLevel * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão zoom in
  Widget _buildZoomInButton() {
    final canZoomIn = zoomLevel < 4.0;
    return IconButton(
      icon: const Icon(Icons.add),
      color: canZoomIn ? AppColors.gold : AppColors.textDark.withOpacity(0.5),
      iconSize: 20,
      onPressed: canZoomIn ? onZoomIn : null,
      tooltip: 'Aumentar zoom',
    );
  }
}

