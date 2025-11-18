# PLPCG

**Pesquisador de Louvores em Partitura e Cifra (Flutter)**

Aplicação Flutter para pesquisa, visualização e gerenciamento de partituras, cifras e gestos em gravura para CIAs (Crianças, Intermediários e Adolescentes) da Igreja Cristã Maranata.

## Requisitos

- Flutter SDK 3.8.1 ou superior
- Dart SDK 3.8.1 ou superior

## Instalação

1. Clone o repositório ou navegue até o diretório do projeto:
   ```bash
   cd plpcg
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

## Executando a Aplicação

### Windows
```bash
flutter run -d windows
```

### Web (Chrome)
```bash
flutter run -d chrome
```

### Web (Edge)
```bash
flutter run -d edge
```

### Listar dispositivos disponíveis
```bash
flutter devices
```

## Estrutura do Projeto

```
plpcg/
├── lib/
│   ├── core/              # Código compartilhado
│   │   ├── constants/    # Constantes da aplicação
│   │   ├── theme/        # Tema, cores, textos, espaçamentos
│   │   ├── utils/        # Utilitários gerais
│   │   ├── errors/       # Tratamento de erros
│   │   ├── extensions/   # Extensions do Dart
│   │   └── router/      # Configuração de rotas
│   ├── data/             # Camada de dados
│   │   ├── datasources/  # Fontes de dados (API, local)
│   │   ├── repositories/ # Implementação de repositórios
│   │   └── models/       # Modelos de dados (DTOs)
│   ├── domain/           # Camada de negócio
│   │   ├── entities/     # Entidades de domínio
│   │   ├── repositories/ # Interfaces de repositórios
│   │   └── usecases/     # Casos de uso
│   ├── presentation/     # Camada de apresentação
│   │   ├── providers/    # Riverpod providers
│   │   ├── pages/        # Páginas (telas)
│   │   ├── widgets/      # Widgets reutilizáveis
│   │   └── controllers/  # Controladores
│   └── main.dart         # Entry point
├── assets/
│   └── icons/            # Ícones SVG
├── test/                 # Testes
└── pubspec.yaml          # Dependências e configurações
```

## Status Atual - Fase 1 Completa

- ✅ Projeto Flutter configurado com todas as dependências
- ✅ Estrutura de pastas organizada (Clean Architecture)
- ✅ Tema "Coletânea Digital" completamente aplicado
- ✅ Navegação configurada com go_router
- ✅ Riverpod configurado e pronto para uso
- ✅ Armazenamento local (Hive + SharedPreferences) funcionando
- ✅ Cliente HTTP configurado com interceptors
- ✅ Modelos base criados e serializáveis
- ✅ Utilitários essenciais implementados
- ✅ Widgets base reutilizáveis criados
- ✅ Estrutura para ícones configurada
- ⏳ Funcionalidades principais (próximas fases)

## Desenvolvimento

Para mais informações sobre desenvolvimento Flutter, consulte:
- [Documentação Flutter](https://docs.flutter.dev/)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)
- [API Reference](https://api.flutter.dev/)

## Licença

Este projeto é desenvolvido por irmãos voluntários para servir à obra, sem fins lucrativos.
