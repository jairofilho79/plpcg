import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Scaffold customizado com header padrão
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showHeader = true,
    this.actions,
  });

  final Widget body;
  final String? title;
  final bool showHeader;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showHeader
          ? AppBar(
              title: title != null
                  ? Text(title!)
                  : GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'PLPCG',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: body,
      ),
    );
  }
}

