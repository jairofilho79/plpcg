import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/listas_page.dart';

/// Configuração de rotas da aplicação usando go_router
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/biblioteca',
      name: 'biblioteca',
      builder: (context, state) => const BibliotecaPage(),
    ),
    GoRoute(
      path: '/leitor',
      name: 'leitor',
      builder: (context, state) {
        final file = state.uri.queryParameters['file'] ?? '';
        final titulo = state.uri.queryParameters['titulo'] ?? '';
        final subtitulo = state.uri.queryParameters['subtitulo'] ?? '';
        return LeitorPage(
          file: file,
          titulo: titulo,
          subtitulo: subtitulo,
        );
      },
    ),
    GoRoute(
      path: '/offline',
      name: 'offline',
      builder: (context, state) => const OfflinePage(),
    ),
    GoRoute(
      path: '/listas',
      name: 'listas',
      builder: (context, state) => const ListasPage(),
    ),
    GoRoute(
      path: '/sobre',
      name: 'sobre',
      builder: (context, state) => const SobrePage(),
    ),
  ],
);

/// Placeholder para página de biblioteca
class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: const Center(child: Text('Biblioteca - Em desenvolvimento')),
    );
  }
}

/// Placeholder para página de leitor
class LeitorPage extends StatelessWidget {
  const LeitorPage({
    super.key,
    required this.file,
    required this.titulo,
    required this.subtitulo,
  });

  final String file;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo.isNotEmpty ? titulo : 'Leitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Leitor - Em desenvolvimento'),
            if (file.isNotEmpty) Text('Arquivo: $file'),
            if (subtitulo.isNotEmpty) Text('Subtítulo: $subtitulo'),
          ],
        ),
      ),
    );
  }
}

/// Placeholder para página offline
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Offline')),
      body: const Center(child: Text('Modo Offline - Em desenvolvimento')),
    );
  }
}


/// Placeholder para página sobre
class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: const Center(child: Text('Sobre - Em desenvolvimento')),
    );
  }
}

