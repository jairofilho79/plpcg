import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/pdf_viewer_mode.dart';
import '../providers/dependencies_provider.dart';

/// Widget para seleção do modo de visualização de PDF
class PdfViewerSelector extends ConsumerWidget {
  const PdfViewerSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(preferredPdfViewerModeProvider);
    final notifier = ref.read(preferredPdfViewerModeProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.mediumRadius,
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícone
          Icon(
            _getModeIcon(currentMode),
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Label
          Text(
            'Modo de visualização:',
            style: AppTextStyles.label,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PdfViewerMode>(
                value: currentMode,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.gold,
                ),
                style: AppTextStyles.body,
                dropdownColor: AppColors.card,
                items: PdfViewerMode.values.map((mode) {
                  return DropdownMenuItem<PdfViewerMode>(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(
                          _getModeIcon(mode),
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mode.displayName,
                                style: AppTextStyles.body,
                              ),
                              Text(
                                mode.description,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textDark.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (PdfViewerMode? newMode) {
                  if (newMode != null && newMode != currentMode) {
                    debugPrint('PdfViewerSelector: Mudando de $currentMode para $newMode');
                    notifier.setMode(newMode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna o ícone apropriado para cada modo
  IconData _getModeIcon(PdfViewerMode mode) {
    switch (mode) {
      case PdfViewerMode.online:
        return Icons.language;
      case PdfViewerMode.external:
        return Icons.open_in_new;
      case PdfViewerMode.share:
        return Icons.share;
      case PdfViewerMode.download:
        return Icons.download;
      case PdfViewerMode.internal:
        return Icons.picture_in_picture;
    }
  }
}

