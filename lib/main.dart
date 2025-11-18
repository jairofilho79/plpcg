import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: PLPCGApp(),
    ),
  );
}

class PLPCGApp extends StatelessWidget {
  const PLPCGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PLPCG',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
