import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/dependencies_provider.dart';

/// Widget para controles de paginação
class PaginationControls extends ConsumerWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final totalPagesAsync = ref.watch(totalPagesProvider);
    final currentPageNotifier = ref.read(currentPageProvider.notifier);

    return totalPagesAsync.when(
      data: (totalPages) {
        if (totalPages <= 1) {
          return const SizedBox.shrink();
        }

        final canGoPrevious = currentPage > 1;
        final canGoNext = currentPage < totalPages;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão anterior
              _PaginationButton(
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
                onTap: canGoPrevious
                    ? () {
                        currentPageNotifier.state = currentPage - 1;
                        _scrollToTop(context);
                      }
                    : null,
                onLongPress: canGoPrevious
                    ? () {
                        currentPageNotifier.state = 1;
                        _scrollToTop(context);
                        HapticFeedback.mediumImpact();
                      }
                    : null,
                enabled: canGoPrevious,
              ),
              const SizedBox(width: AppSpacing.md),
              // Input de página
              _PageInput(
                currentPage: currentPage,
                totalPages: totalPages,
                onPageChanged: (page) {
                  if (page >= 1 && page <= totalPages) {
                    currentPageNotifier.state = page;
                    _scrollToTop(context);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.md),
              // Indicador de progresso
              Text(
                'de $totalPages',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Botão próxima
              _PaginationButton(
                icon: Icons.chevron_right,
                tooltip: 'Próxima página',
                onTap: canGoNext
                    ? () {
                        currentPageNotifier.state = currentPage + 1;
                        _scrollToTop(context);
                      }
                    : null,
                onLongPress: canGoNext
                    ? () {
                        currentPageNotifier.state = totalPages;
                        _scrollToTop(context);
                        HapticFeedback.mediumImpact();
                      }
                    : null,
                enabled: canGoNext,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Scroll suave para o topo da lista
  void _scrollToTop(BuildContext context) {
    // Encontrar o ScrollController da lista mais próxima
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null && scrollable.position.pixels > 0) {
      scrollable.position.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

/// Botão de paginação com suporte a long press
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.onLongPress,
    required this.enabled,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.gold.withOpacity(0.2)
              : AppColors.badgeGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.gold : AppColors.badgeGray,
          size: 24,
        ),
      ),
    );
  }
}

/// Input para navegação direta de página
class _PageInput extends StatefulWidget {
  const _PageInput({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  State<_PageInput> createState() => _PageInputState();
}

class _PageInputState extends State<_PageInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPage.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_PageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage && !_focusNode.hasFocus) {
      _controller.text = widget.currentPage.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    final page = int.tryParse(value);
    if (page != null && page >= 1 && page <= widget.totalPages) {
      widget.onPageChanged(page);
      _focusNode.unfocus();
    } else {
      // Valor inválido, restaurar valor atual
      _controller.text = widget.currentPage.toString();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.gold.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.gold.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.gold,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.card,
        ),
        onSubmitted: _handleSubmitted,
      ),
    );
  }
}

