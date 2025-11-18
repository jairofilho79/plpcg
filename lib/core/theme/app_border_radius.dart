import 'package:flutter/material.dart';

/// Raios de borda padronizados do design system
class AppBorderRadius {
  AppBorderRadius._();

  static const double small = 8.0; // 0.5rem
  static const double medium = 12.0; // 0.75rem
  static const double large = 24.0; // 1.5rem (chips)

  // BorderRadius helpers
  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(small),
  );

  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(medium),
  );

  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(large),
  );
}

