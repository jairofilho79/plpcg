import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wrapper para ícones SVG com tamanhos padronizados
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.assetPath,
    this.size = AppIconSize.medium,
    this.color,
    this.semanticLabel,
  });

  final String assetPath;
  final AppIconSize size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconSize = _getSize(size);

    return SvgPicture.asset(
      assetPath,
      width: iconSize,
      height: iconSize,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
    );
  }

  double _getSize(AppIconSize size) {
    return switch (size) {
      AppIconSize.small => 16,
      AppIconSize.medium => 24,
      AppIconSize.large => 32,
      AppIconSize.xlarge => 48,
    };
  }
}

enum AppIconSize {
  small,
  medium,
  large,
  xlarge,
}

