import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/louvor.dart';
import '../../core/services/pdf_action_service.dart';
import '../providers/dependencies_provider.dart';
import 'app_card.dart';

/// Card de exibição de louvor
class LouvorCard extends ConsumerWidget {
  const LouvorCard({
    super.key,
    required this.louvor,
    this.onTap,
  });

  final Louvor louvor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: onTap ?? () => _handlePdfAction(context, ref),
      elevation: AppCardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Número do louvor
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: AppBorderRadius.smallRadius,
            ),
            child: Text(
              louvor.numero,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Nome do louvor
          Text(
            louvor.nome,
            style: AppTextStyles.heading4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Classificação
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeBlue,
                  borderRadius: AppBorderRadius.smallRadius,
                ),
                child: Text(
                  louvor.classificacao,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Categoria
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGray,
                    borderRadius: AppBorderRadius.smallRadius,
                  ),
                  child: Text(
                    louvor.categoria,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Executa ação de PDF baseada no modo preferido
  Future<void> _handlePdfAction(BuildContext context, WidgetRef ref) async {
    final pdfActionService = ref.read(pdfActionServiceProvider);
    final preferredMode = ref.read(preferredPdfViewerModeProvider);

    // Mostrar loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abrindo PDF...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // Executar ação
    final result = await pdfActionService.executePdfAction(
      mode: preferredMode,
      pdfId: louvor.pdfId,
      pdfPath: louvor.pdf,
      louvorNome: louvor.nome,
    );

    // Mostrar resultado
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? Colors.green
              : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

