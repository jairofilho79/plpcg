import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Card customizado seguindo o design system
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = AppCardElevation.medium,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final AppCardElevation elevation;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.mediumRadius,
        boxShadow: _getShadow(elevation),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.mediumRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    return onTap != null ? card : _CardWithoutTap(child: card);
  }

  List<BoxShadow> _getShadow(AppCardElevation elevation) {
    return switch (elevation) {
      AppCardElevation.none => [],
      AppCardElevation.small => AppShadows.smallList,
      AppCardElevation.medium => AppShadows.mediumList,
      AppCardElevation.large => AppShadows.largeList,
    };
  }
}

class _CardWithoutTap extends StatelessWidget {
  const _CardWithoutTap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

enum AppCardElevation {
  none,
  small,
  medium,
  large,
}

