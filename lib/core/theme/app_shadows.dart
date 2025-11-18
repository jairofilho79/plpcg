import 'package:flutter/material.dart';

/// Sombras padronizadas do design system
class AppShadows {
  AppShadows._();

  static const BoxShadow small = BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  static const BoxShadow medium = BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: 0,
  );

  static const BoxShadow large = BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: 0,
  );

  static List<BoxShadow> get smallList => [small];
  static List<BoxShadow> get mediumList => [medium];
  static List<BoxShadow> get largeList => [large];
}

