import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Widget de loading shimmer para placeholders
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.height = 100,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.placeholder.withOpacity(0.3),
        borderRadius: AppBorderRadius.mediumRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.gold,
        ),
      ),
    );
  }
}

/// Lista de shimmer cards para loading state
class LouvoresLoadingShimmer extends StatelessWidget {
  const LouvoresLoadingShimmer({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AppCard(
          elevation: AppCardElevation.medium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shimmer para número
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.placeholder.withOpacity(0.3),
                  borderRadius: AppBorderRadius.smallRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Shimmer para nome
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.placeholder.withOpacity(0.3),
                  borderRadius: AppBorderRadius.smallRadius,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 20,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.placeholder.withOpacity(0.3),
                  borderRadius: AppBorderRadius.smallRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Shimmer para badges
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder.withOpacity(0.3),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder.withOpacity(0.3),
                      borderRadius: AppBorderRadius.smallRadius,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double _getMaxCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      // Mobile: 1 coluna
      return width - (AppSpacing.md * 2);
    } else if (width < 1024) {
      // Tablet: 2 colunas
      return (width - (AppSpacing.md * 3)) / 2;
    } else {
      // Desktop: 3+ colunas
      return (width - (AppSpacing.md * 4)) / 3;
    }
  }
}

