# Plano de Migração PLPCG - Svelte para Flutter

## Índice

1. [Visão Geral](#visão-geral)
2. [Objetivos da Migração](#objetivos-da-migração)
3. [Stack Tecnológico Flutter](#stack-tecnológico-flutter)
4. [Boas Práticas e Arquitetura](#boas-práticas-e-arquitetura)
5. [Fases de Implementação](#fases-de-implementação)
6. [Diretrizes de Design](#diretrizes-de-design)
7. [Comunicação com Backend](#comunicação-com-backend)

---

## Visão Geral

Este documento descreve o plano completo de migração da aplicação **PLPCG (Pesquisador de Louvores em Partitura e Cifra com Gestos)** da versão legada em Svelte para uma aplicação Flutter moderna, aproveitando ao máximo os recursos nativos da plataforma para melhor performance, responsividade e experiência do usuário.

### Objetivos da Migração

1. **Performance Superior**: Aproveitar a compilação nativa do Flutter para 60fps garantidos e renderização otimizada
2. **Melhor Responsividade**: Gestos touch nativos e animações fluidas do Flutter
3. **Offline Robusto**: Utilizar recursos nativos de armazenamento (SharedPreferences, Hive, Isar) com melhor desempenho que Service Workers
4. **Cross-Platform**: Base única de código para Android, iOS e Web
5. **Manutenibilidade**: Arquitetura limpa seguindo boas práticas do Flutter
6. **Componentização**: Widgets reutilizáveis e bem estruturados

### Manutenção de Requisitos

Todos os requisitos funcionais e não funcionais da aplicação legada serão mantidos:

- ✅ Sistema de pesquisa e filtros
- ✅ Biblioteca de louvores com paginação
- ✅ Carousel de louvores
- ✅ Sistema de playlists
- ✅ Visualizador de PDF avançado
- ✅ Modo offline completo
- ✅ Compartilhamento
- ✅ Design "Coletânea Digital" (cores, fontes, espaçamentos)
- ✅ Suporte multi-dispositivo (mobile, tablet, desktop)

---

## Stack Tecnológico Flutter

### Core Flutter

- **Flutter SDK**: 3.24+ (versão estável mais recente)
- **Dart**: 3.4+ (null safety habilitado)
- **Plataformas**: Android, iOS, Web (PWA)

### Gerenciamento de Estado

**Opções recomendadas** (escolher uma para padronizar):
- **Riverpod 2.5+**: Recomendado - moderna, type-safe, performática
- **Bloc 8.5+**: Alternativa sólida - pattern estabelecido, testável
- **Provider + ChangeNotifier**: Opção simples - padrão Flutter

**Decisão**: Usar **Riverpod** como padrão, com providers assíncronos para dados do backend e state providers para estado local.

### Navegação

- **go_router 13+**: Navegação declarativa com suporte a deep links, rotas nomeadas, navegação tipo-safe

### Armazenamento Local

- **Hive 2.3+**: NoSQL database local (playlists, preferências) - rápido e leve
- **SharedPreferences 2.3+**: Dados simples (configurações, flags)
- **path_provider 2.1+**: Acesso a diretórios do sistema para cache de PDFs
- **file_picker 8.0+**: Seleção de arquivos (futuro)

### Comunicação com Backend

- **Dio 5.5+**: Cliente HTTP robusto (interceptors, cache, retry logic)
- **Cloudflare R2**: Mantido da versão legada
- **connectivity_plus 6.0+**: Verificação de conectividade

### Visualização de PDF

- **syncfusion_flutter_pdfviewer 27+**: Visualizador PDF nativo performático com zoom, scroll, cache
- **pdfx 0.9+**: Alternativa - wrapper do PDF.js para Flutter

**Decisão**: Usar **syncfusion_flutter_pdfviewer** (mais performático) ou **pdfx** (compatível com PDF.js da versão legada).

### Utilitários

- **path 1.9+**: Manipulação de caminhos
- **archive 3.6+**: Descompactação de ZIPs (offline mode)
- **crypto 3.0+**: Hash e validações
- **url_launcher 6.3+**: Abrir PDFs em apps externos
- **share_plus 10.0+**: Compartilhamento nativo
- **permission_handler 11.2+**: Gerenciamento de permissões (storage)

### UI e Design

- **flutter_svg 2.0+**: Ícones SVG (equivalente a Lucide Svelte)
- **google_fonts 6.2+**: Fontes (EB Garamond, Open Sans)
- **flutter_animate 4.5+**: Animações declarativas
- **flutter_staggered_animations 1.1+**: Animações de lista
- **skeletonizer 1.0+**: Placeholders de loading

### Offline e Cache

- **flutter_cache_manager 3.4+**: Gerenciamento inteligente de cache de arquivos
- **workmanager 0.5+**: Background tasks (downloads, sync) - Android/iOS
- **wakelock_plus 1.2+**: Manter tela ligada durante downloads

### Animações e Gestos

- **flutter_gesture_recognizer**: Gestos customizados (pinch to zoom nativo do Flutter)
- **Transform**: Widgets nativos para zoom e rotação

### Validação e Formulários

- **flutter_form_builder 9.2+**: Formulários complexos (se necessário)
- **validators 3.0+**: Validação de inputs

### Desenvolvimento e Qualidade

- **flutter_lints 4.0+**: Regras de linting do Flutter
- **mocktail 1.0+**: Mocking para testes
- **flutter_test**: Framework de testes nativo
- **integration_test**: Testes de integração

---

## Boas Práticas e Arquitetura

### Arquitetura do Projeto

Seguir **Clean Architecture** adaptada para Flutter com separação de camadas:

```
lib/
├── core/                    # Código compartilhado
│   ├── constants/          # Constantes da aplicação
│   ├── theme/              # Tema, cores, textos, espaçamentos
│   ├── utils/              # Utilitários gerais
│   ├── errors/             # Tratamento de erros
│   └── extensions/         # Extensions do Dart
├── data/                   # Camada de dados
│   ├── datasources/        # Fontes de dados (API, local)
│   ├── repositories/       # Implementação de repositórios
│   └── models/             # Modelos de dados (DTOs)
├── domain/                 # Camada de negócio
│   ├── entities/           # Entidades de domínio
│   ├── repositories/       # Interfaces de repositórios
│   └── usecases/           # Casos de uso
├── presentation/           # Camada de apresentação
│   ├── providers/          # Riverpod providers
│   ├── pages/              # Páginas (telas)
│   ├── widgets/            # Widgets reutilizáveis
│   └── controllers/        # Controladores (se usar Bloc)
└── main.dart              # Entry point
```

### Princípios de Design

1. **Single Responsibility**: Cada widget/classe tem uma única responsabilidade
2. **DRY (Don't Repeat Yourself)**: Widgets reutilizáveis para elementos comuns
3. **Separation of Concerns**: Lógica de negócio separada da UI
4. **Dependency Injection**: Usar Riverpod para injeção de dependências
5. **Immutability**: Preferir objetos imutáveis (usar `freezed` ou `copyWith`)
6. **Error Handling**: Tratamento centralizado de erros com `Result` ou `Either`

### Gerenciamento de Estado

#### Provider Structure (Riverpod)

```dart
// Exemplo de estrutura de providers
final louvoresRepositoryProvider = Provider<LouvoresRepository>((ref) {
  return LouvoresRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final louvoresProvider = FutureProvider<List<Louvor>>((ref) {
  return ref.watch(louvoresRepositoryProvider).getLouvores();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});
```

### Componentização

#### Widgets Reutilizáveis

Criar widgets pequenos e focados:

- `LouvorCard`: Card de exibição de louvor
- `SearchBar`: Barra de pesquisa
- `CategoryFilterChip`: Chip de filtro de categoria
- `ClassificationFilterChip`: Chip de filtro de classificação
- `PdfViewerSelector`: Dropdown de modo de visualização
- `CarouselChip`: Chip do carousel
- `OfflineIndicator`: Indicador de status offline
- `LoadingShimmer`: Skeleton loader

#### Layout Responsivo

Usar `LayoutBuilder`, `MediaQuery` e `Breakpoint` para responsividade:

```dart
// Breakpoints definidos no tema
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}
```

### Performance

1. **Const Constructors**: Usar `const` sempre que possível
2. **ListView.builder**: Para listas longas (lazy loading)
3. **ImageCache**: Configurar tamanho de cache de imagens
4. **Debounce**: Usar `Timer` ou `debounce` do Riverpod
5. **Memoization**: Usar `select` do Riverpod para escutar apenas mudanças específicas
6. **RepaintBoundary**: Isolar widgets que não precisam repintar frequentemente

### Testes

- **Unit Tests**: Para lógica de negócio e utilitários
- **Widget Tests**: Para widgets isolados
- **Integration Tests**: Para fluxos completos (pesquisa, download, etc.)

---

## Diretrizes de Design

### Tema Visual "Coletânea Digital"

Mantemos exatamente o mesmo tema da versão legada, adaptado para Flutter.

### Paleta de Cores

Definir no arquivo `lib/core/theme/app_colors.dart`:

```dart
class AppColors {
  // Cores principais
  static const Color background = Color(0xFF4B2D2B);        // Fundo estrutural
  static const Color card = Color(0xFFFFF8E1);              // Cards e superfícies
  static const Color title = Color(0xFF6A2F2F);             // Títulos e destaques
  static const Color gold = Color(0xFFD4AF37);              // Cor dourada
  static const Color goldLight = Color(0xFFF4D03F);         // Dourado claro
  static const Color placeholder = Color(0xFFF0E68C);       // Placeholders
  
  // Cores de texto
  static const Color textLight = Color(0xFFFFFFFF);         // Texto claro
  static const Color textDark = Color(0xFF2C3E50);          // Texto escuro
  
  // Botões e estados
  static const Color btnBackground = Color(0xFF6A3B39);     // Botão background
  static const Color badgeBlue = Color(0xFF5A7A9C);         // Badge azul
  static const Color badgeGray = Color(0xFF9CA3AF);         // Badge cinza
}
```

### Tipografia

Usar `google_fonts`:

```dart
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.ebGaramond(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.03,
  );
  
  static TextStyle get body => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  // ... outros estilos
}
```

### Espaçamentos

Definir no tema:

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

### Border Radius

```dart
class AppBorderRadius {
  static const double small = 8.0;      // 0.5rem
  static const double medium = 12.0;    // 0.75rem
  static const double large = 24.0;     // 1.5rem (chips)
}
```

### Sombras

```dart
class AppShadows {
  static const BoxShadow medium = BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 4),
    blurRadius: 6,
  );
  
  static const BoxShadow large = BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 10),
    blurRadius: 15,
  );
}
```

---

## Comunicação com Backend

### Estrutura Mantida

A aplicação continua usando os mesmos endpoints Cloudflare:

- **GET** `/louvores-manifest.json`: Lista de louvores
- **GET** `/offline-manifest.json`: Pacotes ZIP para download
- **GET** `/packages/{filename}.zip`: Pacotes ZIP
- **GET** `/assets/{classificacao}/{filename}.pdf`: PDFs individuais

### Cliente HTTP

Usar Dio com interceptors para:
- Cache automático de manifestos
- Retry logic em caso de falha
- Timeout configurável
- Logging de requisições (em dev)

### Modelos de Dados

```dart
@freezed
class Louvor with _$Louvor {
  const factory Louvor({
    required String nome,
    required String classificacao,
    required String numero,
    required String categoria,
    required String pdf,
    required String pdfId,
  }) = _Louvor;
  
  factory Louvor.fromJson(Map<String, dynamic> json) => _$LouvorFromJson(json);
}
```

---

## Fases de Implementação

As fases abaixo estão organizadas por entregáveis funcionais. Cada fase pode ser desenvolvida e testada independentemente, seguindo princípios de desenvolvimento incremental.

---

## FASE 1: Setup e Infraestrutura Base

**Objetivo**: Criar a estrutura base do projeto Flutter com toda a configuração necessária.

### Entregáveis

1. **1.1 - Criação do Projeto Flutter**
   - Criar projeto Flutter com estrutura de pastas organizada
   - Configurar `pubspec.yaml` com todas as dependências
   - Configurar análise estática (`analysis_options.yaml` com `flutter_lints`)
   - Configurar `.gitignore` apropriado
   - Setup de ambientes (dev, staging, prod)

2. **1.2 - Configuração de Tema e Design System**
   - Criar arquivo `app_colors.dart` com paleta de cores completa
   - Criar arquivo `app_text_styles.dart` com estilos de texto (EB Garamond, Open Sans)
   - Criar arquivo `app_spacing.dart` com espaçamentos padronizados
   - Criar arquivo `app_border_radius.dart` com raios de borda
   - Criar arquivo `app_shadows.dart` com sombras padronizadas
   - Criar `app_theme.dart` configurando `ThemeData` do Flutter
   - Configurar fontes via `google_fonts`

3. **1.3 - Configuração de Navegação**
   - Configurar `go_router` com rotas nomeadas
   - Definir rotas: `/` (home), `/biblioteca`, `/leitor`, `/offline`, `/listas`, `/sobre`
   - Configurar deep linking para rotas com parâmetros
   - Criar navegação tipo-safe

4. **1.4 - Setup de Gerenciamento de Estado**
   - Configurar Riverpod como provider padrão
   - Criar estrutura de providers base
   - Configurar `ProviderScope` no `main.dart`
   - Criar providers de dependências (Dio, repositories, etc.)

5. **1.5 - Configuração de Armazenamento Local**
   - Configurar Hive para playlists e dados estruturados
   - Configurar SharedPreferences para configurações simples
   - Configurar path_provider para acesso a diretórios
   - Criar classes de serviço abstratas para armazenamento

6. **1.6 - Cliente HTTP e Comunicação com Backend**
   - Configurar Dio com interceptors
   - Criar `ApiClient` wrapper
   - Configurar base URL e timeouts
   - Criar serviços para endpoints (`louvores-manifest.json`, `offline-manifest.json`)
   - Implementar cache de manifestos em memória

7. **1.7 - Modelos de Dados Base**
   - Criar modelo `Louvor` com freezed
   - Criar modelo `OfflinePackage` para pacotes ZIP
   - Criar modelo `Playlist` para playlists
   - Criar modelos de resposta da API
   - Configurar serialização JSON (`json_serializable`)

8. **1.8 - Utilitários Base**
   - Criar funções de normalização de texto (remoção de acentos)
   - Criar funções de validação
   - Criar extensões úteis (String, DateTime, etc.)
   - Criar tratamento centralizado de erros
   - Criar classes de resultado (Result/Either)

9. **1.9 - Widgets Base Reutilizáveis**
   - Criar `AppScaffold` com header padrão
   - Criar `AppButton` com estilos padronizados
   - Criar `AppCard` com design system
   - Criar `AppTextField` para inputs
   - Criar `LoadingIndicator` genérico
   - Criar `ErrorWidget` para exibição de erros

10. **1.10 - Configuração de Ícones**
    - Instalar `flutter_svg`
    - Criar pasta de assets com ícones SVG
    - Criar widget wrapper para ícones SVG com tamanhos padronizados
    - Mapear ícones Lucide para SVG (ou usar pacote equivalente)

**Resultado Esperado**: Projeto Flutter configurado e pronto para desenvolvimento, com tema aplicado e estrutura base funcional.

---

## FASE 2: Página Inicial e Consumo de Dados

**Objetivo**: Implementar a página principal com consumo de dados do backend.

### Entregáveis

1. **2.1 - Provider de Louvores**
   - Criar `LouvoresRepository` (interface e implementação)
   - Criar `louvoresProvider` (FutureProvider) para buscar dados
   - Implementar cache local dos louvores (Hive)
   - Implementar lógica de fallback (rede → cache → erro)
   - Tratamento de erros com retry logic

2. **2.2 - Página Principal (Home) - Estrutura Base**
   - Criar página `/` com `AppScaffold`
   - Implementar layout responsivo (mobile/tablet/desktop)
   - Adicionar header com botões de navegação (Sobre, Biblioteca, Offline, Listas)
   - Configurar SafeArea para respeitar notch

3. **2.3 - Barra de Pesquisa**
   - Criar widget `SearchBar` reutilizável
   - Implementar TextField com debounce (300ms) usando Timer
   - Integrar com `searchQueryProvider` (StateProvider)
   - Aplicar estilo do design system
   - Adicionar ícone de pesquisa e botão de limpar

4. **2.4 - Carregamento e Exibição de Dados**
   - Criar `LouvoresListView` widget
   - Implementar loading state com `LoadingShimmer`
   - Implementar error state com `ErrorWidget` e botão de retry
   - Implementar success state listando todos os louvores
   - Usar `ListView.builder` para performance (lazy loading)

5. **2.5 - Widget LouvorCard**
   - Criar widget `LouvorCard` reutilizável
   - Exibir: número, nome, classificação, categoria
   - Aplicar design system (cores, espaçamentos, bordas, sombras)
   - Implementar estados hover/pressed (opcional para web/desktop)
   - Adicionar gestos de toque (tap para ação futura)

6. **2.6 - Grid Responsivo de Cards**
   - Adaptar layout para grid responsivo:
     - Mobile: 1 coluna
     - Tablet: 2 colunas
     - Desktop: 3+ colunas
   - Usar `GridView.builder` com `SliverGridDelegateWithMaxCrossAxisExtent`
   - Implementar espaçamento consistente entre cards

**Resultado Esperado**: Página inicial funcional exibindo todos os louvores em cards responsivos, com barra de pesquisa implementada (ainda sem filtros funcionais).

---

## FASE 3: Sistema de Busca e Filtros

**Objetivo**: Implementar funcionalidades de pesquisa e filtragem completa.

### Entregáveis

1. **3.1 - Lógica de Busca**
   - Criar função de normalização de texto (remove acentos, lowercase)
   - Criar `filteredLouvoresProvider` (computed) que combina:
     - `louvoresProvider` (dados)
     - `searchQueryProvider` (query)
     - `selectedCategoriesProvider` (categorias)
     - `selectedClassificationsProvider` (classificações)
   - Implementar busca por número (exata)
   - Implementar busca por nome (normalizada, parcial)
   - Otimizar com `select` do Riverpod para evitar rebuilds desnecessários

2. **3.2 - Filtros por Categoria**
   - Criar widget `CategoryFilters`
   - Criar `CategoryFilterChip` reutilizável
   - Exibir filtros: Partitura, Cifra, Gestos em Gravura
   - Implementar seleção múltipla (chips clicáveis)
   - Lógica especial: "Cifra" inclui automaticamente "Cifra nível I" e "Cifra nível II"
   - Integrar com `selectedCategoriesProvider`

3. **3.3 - Filtros por Classificação**
   - Criar widget `ClassificationFilters`
   - Criar `ClassificationFilterChip` reutilizável
   - Extrair classificações únicas dos louvores
   - Normalizar classificações (remover parênteses se necessário)
   - Implementar seleção múltipla (chips clicáveis)
   - Integrar com `selectedClassificationsProvider`
   - Layout responsivo (wrap em linha, scroll horizontal se necessário)

4. **3.4 - Aplicação de Filtros na Listagem**
   - Integrar `filteredLouvoresProvider` na `LouvoresListView`
   - Exibir mensagem "Nenhum resultado encontrado" quando lista vazia
   - Adicionar contador de resultados (ex: "Mostrando X de Y louvores")
   - Atualizar lista reativamente quando filtros mudam

5. **3.5 - Persistência de Filtros**
   - Salvar filtros selecionados em SharedPreferences
   - Restaurar filtros ao reabrir app
   - Opcional: Limpar filtros com botão "Limpar todos"

6. **3.6 - Melhorias de UX**
   - Adicionar animação ao filtrar resultados (`flutter_staggered_animations`)
   - Mostrar indicador de filtros ativos
   - Adicionar feedback visual ao aplicar filtros

**Resultado Esperado**: Sistema completo de busca e filtros funcionando, com resultados atualizados em tempo real.

---

## FASE 4: Seletor de Modo de Visualização de PDF

**Objetivo**: Implementar seletor de modo de visualização e preparar integração com leitor.

### Entregáveis

1. **4.1 - Modelo de Modo de Visualização**
   - Criar enum `PdfViewerMode`:
     - `online` (abre em navegador)
     - `external` (abre em app externo)
     - `share` (compartilhar via Share API)
     - `download` (baixar direto)
     - `internal` (leitor interno)
   - Criar provider para modo preferido (`preferredPdfViewerModeProvider`)
   - Persistir preferência em SharedPreferences

2. **4.2 - Widget PdfViewerSelector**
   - Criar dropdown/widget de seleção de modo
   - Aplicar estilo do design system
   - Exibir ícone + texto descritivo para cada modo
   - Integrar com `preferredPdfViewerModeProvider`

3. **4.3 - Implementação de Modos Online, External, Share e Download**
   - **Online**: Usar `url_launcher` para abrir PDF em navegador
   - **External**: Usar `url_launcher` com `launchMode: LaunchMode.externalApplication`
   - **Share**: Usar `share_plus` para compartilhar URL do PDF
   - **Download**: Usar `dio.download` + `permission_handler` para salvar no dispositivo
   - Tratamento de erros para cada modo (permissões negadas, apps não instalados, etc.)

4. **4.4 - Integração com LouvorCard**
   - Adicionar botão/ação em `LouvorCard` para abrir PDF
   - Implementar lógica que verifica modo preferido e executa ação correspondente
   - Mostrar loading durante abertura/download
   - Feedback visual de sucesso/erro

**Resultado Esperado**: Seletor de modo de visualização funcional, com todos os modos implementados exceto leitor interno (próxima fase).

---

## FASE 5: Carousel de Louvores

**Objetivo**: Implementar sistema de carousel para seleção e navegação entre louvores.

### Entregáveis

1. **5.1 - Provider de Carousel**
   - Criar `carouselLouvoresProvider` (StateProvider<List<Louvor>>)
   - Criar funções para adicionar/remover louvores do carousel
   - Persistir carousel em SharedPreferences (IDs dos PDFs)

2. **5.2 - Widget CarouselChips**
   - Criar widget de chips horizontais scrolláveis
   - Cada chip exibe: número e nome do louvor (truncado)
   - Chips clicáveis para navegar para o louvor
   - Chip ativo destacado (cor dourada)
   - Layout responsivo (scroll horizontal em mobile)

3. **5.3 - Adicionar ao Carousel**
   - Adicionar botão/ação em `LouvorCard` para adicionar ao carousel
   - Feedback visual quando adicionado (toast/snackbar)
   - Prevenir duplicatas

4. **5.4 - Navegação no Carousel**
   - Implementar navegação ao clicar em chip
   - Scroll automático para chip selecionado
   - Navegação anterior/próxima (botões ou gestos swipe)

5. **5.5 - Botão Limpar Carousel**
   - Adicionar botão para limpar todos os louvores do carousel
   - Modal de confirmação antes de limpar
   - Feedback visual após limpar

6. **5.6 - Integração na Página Principal**
   - Adicionar seção de carousel acima da listagem de resultados
   - Exibir apenas quando houver louvores no carousel
   - Animação ao adicionar/remover chips

**Resultado Esperado**: Carousel funcional com chips clicáveis, permitindo adicionar e navegar entre louvores selecionados.

---

## FASE 6: Sistema de Playlists

**Objetivo**: Implementar sistema completo de gerenciamento de playlists.

### Entregáveis

1. **6.1 - Modelo de Playlist**
   - Atualizar modelo `Playlist` com campos:
     - `id` (String)
     - `nome` (String)
     - `pdfIds` (List<String>)
     - `favorita` (bool)
     - `createdAt` (DateTime)
   - Configurar Hive adapter para Playlist
   - Criar repository para playlists (`PlaylistRepository`)

2. **6.2 - Provider de Playlists**
   - Criar `playlistsProvider` (StateProvider<List<Playlist>>)
   - Implementar CRUD completo (criar, ler, atualizar, deletar)
   - Persistir em Hive
   - Sincronizar com SharedPreferences se necessário

3. **6.3 - Página de Listas/Playlists**
   - Criar rota `/listas`
   - Layout com lista de playlists salvas
   - Estado vazio com mensagem amigável
   - Integrar com `playlistsProvider`

4. **6.4 - Salvar Carousel como Playlist**
   - Criar dialog/modal para salvar playlist
   - Input de nome da playlist
   - Validar nome (não vazio, não duplicado)
   - Converter carousel atual em playlist
   - Feedback de sucesso

5. **6.5 - Lista de Playlists com Cards**
   - Criar `PlaylistCard` widget
   - Exibir: nome, quantidade de louvores, data de criação
   - Badge de favorita (estrela)
   - Ações: editar, favoritar, compartilhar, reproduzir, remover

6. **6.6 - Edição de Playlist**
   - Editar nome (tap no nome ou botão editar)
   - Dialog para alterar nome
   - Validação de nome

7. **6.7 - Marcar/Desmarcar Favorita**
   - Toggle de favorita via botão de estrela
   - Atualizar estado reativamente

8. **6.8 - Compartilhar Playlist**
   - Implementar geração de link compartilhável
   - Formato: `?sharepdfs=id1,id2,id3&sharename=Nome`
   - Usar `share_plus` para compartilhar link
   - Implementar deep link para abrir playlist compartilhada

9. **6.9 - Reproduzir Playlist**
   - Botão "Reproduzir" no card da playlist
   - Carregar PDFs da playlist no carousel
   - Navegar para página principal após carregar

10. **6.10 - Remover Playlist**
    - Botão de remover com modal de confirmação
    - Deletar do Hive
    - Atualizar lista reativamente

11. **6.11 - Busca e Filtro de Playlists**
    - Barra de pesquisa por nome
    - Filtro de favoritas (botão de estrela no header)
    - Provider computed para playlists filtradas

**Resultado Esperado**: Sistema completo de playlists com todas as funcionalidades de gerenciamento implementadas.

---

## FASE 7: Página de Biblioteca

**Objetivo**: Implementar página de biblioteca com paginação e ordenação.

### Entregáveis

1. **7.1 - Estrutura da Página Biblioteca**
   - Criar rota `/biblioteca`
   - Layout similar à página principal
   - Reutilizar filtros de categoria e classificação
   - Adicionar seletor de ordenação e paginação

2. **7.2 - Seletor de Ordenação**
   - Criar widget `SortSelector`
   - Opções: Por número, Por nome (alfabética)
   - Provider `sortOrderProvider` (StateProvider)
   - Aplicar ordenação aos louvores filtrados

3. **7.3 - Lógica de Paginação**
   - Criar `paginatedLouvoresProvider` (computed)
   - Parâmetros: lista filtrada, página atual, itens por página
   - Calcular total de páginas
   - Retornar apenas louvores da página atual

4. **7.4 - Seletor de Itens por Página**
   - Criar dropdown com opções: 10, 20, 30, 50, 100
   - Provider `itemsPerPageProvider` (StateProvider)
   - Persistir preferência em SharedPreferences
   - Resetar para página 1 ao mudar itens por página

5. **7.5 - Controles de Navegação de Páginas**
   - Criar widget `PaginationControls`
   - Botões anterior/próxima
   - Input direto de número de página (com validação)
   - Indicador de progresso (página X de Y)
   - Desabilitar botões quando apropriado

6. **7.6 - Navegação Rápida (Long Press)**
   - Implementar detecção de long press (500ms) nos botões anterior/próxima
   - Long press em anterior → primeira página
   - Long press em próxima → última página
   - Feedback visual (haptic feedback se disponível)

7. **7.7 - Scroll Suave ao Mudar Página**
   - Scroll automático para topo da lista ao mudar de página
   - Animação suave usando `ScrollController.animateTo`

8. **7.8 - Reutilização de Componentes**
   - Reutilizar `LouvorCard` da página principal
   - Reutilizar filtros de categoria e classificação
   - Reutilizar `PdfViewerSelector`

**Resultado Esperado**: Página de biblioteca completa com paginação, ordenação e filtros funcionais.

---

## FASE 8: Leitor de PDF Interno

**Objetivo**: Implementar visualizador de PDF dedicado com controles avançados.

### Entregáveis

1. **8.1 - Estrutura da Página Leitor**
   - Criar rota `/leitor` com parâmetros (file, titulo, subtitulo)
   - Layout fullscreen (sem header padrão)
   - Toolbar fixa no topo
   - Área de visualização de PDF

2. **8.2 - Toolbar do Leitor**
   - Criar widget `PdfViewerToolbar`
   - Elementos:
     - Brand "PLPCG" (esquerda)
     - Título e subtítulo (centro)
     - Botão anterior (←)
     - Indicador de página (X / Y)
     - Botão próxima (→)
     - Botão zoom out (-)
     - Percentual de zoom / Botão zoom fit
     - Botão zoom in (+)
   - Layout responsivo (ocultar botões de zoom em mobile)

3. **8.3 - Integração do Visualizador de PDF**
   - Configurar `syncfusion_flutter_pdfviewer` ou `pdfx`
   - Carregar PDF a partir de URL (rede ou cache local)
   - Implementar estados: loading, error, success
   - Overlay de loading com spinner e mensagem

4. **8.4 - Navegação de Páginas**
   - Implementar navegação anterior/próxima
   - Atualizar contador de páginas
   - Scroll para página ao mudar

5. **8.5 - Controles de Zoom**
   - Implementar zoom in/out (10% por vez)
   - Limites de zoom (0.25x a 4x)
   - Exibir percentual atual de zoom

6. **8.6 - Modos de Ajuste (Page Fit / Page Width)**
   - Implementar modo `page-fit` (ajusta altura da viewport)
   - Implementar modo `page-width` (preenche largura disponível)
   - Botão de zoom fit alterna entre modos
   - Long press (500ms) no botão alterna modo preferido
   - Indicadores visuais dos modos (barras horizontais/verticais)

7. **8.7 - Gestos Touch Nativos**
   - **Pinch to Zoom**: Usar `GestureDetector` com `ScaleGestureRecognizer`
   - Limitar zoom durante pinch
   - **Swipe para Navegar**: Detectar swipe horizontal
     - Primeiro quarto da tela: página anterior
     - Último quarto: próxima página
   - Prevenir conflitos com scroll

8. **8.8 - Validação de PDF Disponível**
   - Verificar se PDF está em cache antes de carregar
   - Se não disponível e online: tentar download automático
   - Se offline: mostrar mensagem com botão para página offline
   - Implementar retry logic (máx. 2 tentativas)

9. **8.9 - Tratamento de Erros**
   - Banner de erro quando falha ao carregar
   - Mensagens amigáveis de erro
   - Botão de retry
   - Link para página offline se apropriado

10. **8.10 - Atalhos de Teclado (Desktop/Web)**
    - Ctrl/Cmd + Plus: Zoom in
    - Ctrl/Cmd + Minus: Zoom out
    - Ctrl/Cmd + 0: Reset zoom
    - Arrow Down/Page Down: Próxima página
    - Arrow Up/Page Up: Página anterior
    - Usar `KeyboardListener` ou `Shortcuts`

11. **8.11 - Performance e Otimizações**
    - Cache de escala calculada para page-width
    - Debounce de ajustes de zoom
    - Lazy loading de páginas (se suportado pelo viewer)
    - RepaintBoundary para área do PDF

12. **8.12 - Integração com Modo Offline**
    - Verificar cache local antes de buscar na rede
    - Priorizar cache quando disponível
    - Sincronizar estado de disponibilidade

**Resultado Esperado**: Leitor de PDF completo e funcional com todos os controles, gestos e modos de visualização.

---

## FASE 9: Modo Offline - Infraestrutura

**Objetivo**: Implementar infraestrutura base para modo offline (cache, validação, sincronização).

### Entregáveis

1. **9.1 - Serviço de Cache de PDFs**
   - Configurar `flutter_cache_manager` para cache de arquivos
   - Criar `PdfCacheService` wrapper
   - Estratégia de cache: Cache First para PDFs
   - Limites de cache configuráveis

2. **9.2 - Validação de Disponibilidade de PDFs**
   - Criar `PdfValidationService`
   - Método `validatePdfAvailability(pdfPath)`
   - Verificar cache local primeiro
   - Retornar: `available`, `needsDownload`, `url`

3. **9.3 - Provider de Estatísticas Offline**
   - Criar `offlineStatsProvider` (FutureProvider)
   - Calcular estatísticas por categoria:
     - Total de PDFs
     - Disponíveis no cache
     - Faltantes
     - Percentual de disponibilidade
   - Atualizar reativamente quando cache muda

4. **9.4 - Sincronização de Cache**
   - Criar `CacheSyncService`
   - Usar `flutter_cache_manager` para notificações de atualização
   - Validar consistência entre cache e manifest
   - Função `validateAndSyncStats()` para corrigir inconsistências

5. **9.5 - Normalização de URLs**
   - Criar função `normalizePathForComparison()`
   - Remover protocolo e domínio
   - Decodificar URI encoding (múltiplas vezes se necessário)
   - Normalizar para lowercase
   - Normalizar separadores de caminho
   - Remover barras iniciais/finais

6. **9.6 - Índice de PDFs em Memória**
   - Criar `PdfIndexService`
   - Estrutura: Map de `pdfId` → informações do louvor
   - Atualizar índice após downloads
   - Busca rápida de disponibilidade

7. **9.7 - Persistência de Estado Offline**
   - Salvar categorias selecionadas em SharedPreferences
   - Salvar hash do manifest para detecção de mudanças
   - Salvar categorias baixadas (não podem ser removidas)
   - Versionamento de cache

**Resultado Esperado**: Infraestrutura completa de cache e validação funcionando, pronta para integração com downloads.

---

## FASE 10: Modo Offline - Downloads

**Objetivo**: Implementar sistema completo de download de pacotes ZIP e descompactação.

### Entregáveis

1. **10.1 - Serviço de Download**
   - Criar `DownloadService`
   - Usar `dio.download` para baixar pacotes ZIP
   - Suportar download em background (workmanager se necessário)
   - Implementar cancelamento de download (AbortController equivalente)
   - Progresso de download via callbacks

2. **10.2 - Identificação de PDFs Faltantes**
   - Criar função `identifyMissingPdfs(category)`
   - Comparar `louvores-manifest.json` com lista de PDFs em cache
   - Normalizar URLs para comparação
   - Retornar lista de PDFs faltantes por categoria

3. **10.3 - Identificação de Pacotes Necessários**
   - Criar função `findRequiredPackages(missingPdfs, category)`
   - Consultar `offline-manifest.json` para encontrar pacotes ZIP
   - Calcular interseção entre PDFs faltantes e conteúdo dos pacotes
   - Retornar apenas pacotes que contêm PDFs faltantes (otimização)

4. **10.4 - Download de Pacotes ZIP**
   - Implementar download em lotes (batch)
   - Processar downloads em paralelo dentro de cada lote
   - Mostrar progresso de download em tempo real
   - Suportar cancelamento
   - Salvar ZIPs temporariamente

5. **10.5 - Descompactação de ZIPs**
   - Usar `archive` para descompactar ZIPs
   - Filtrar apenas PDFs necessários (ignorar outros arquivos)
   - Normalizar caminhos dos arquivos extraídos
   - Validar arquivos extraídos

6. **10.6 - Armazenamento de PDFs no Cache**
   - Salvar PDFs individuais no cache usando `PdfCacheService`
   - Remover ZIPs após extração (economia de espaço)
   - Atualizar índice de PDFs

7. **10.7 - Atualização de Estatísticas Após Download**
   - Recalcular estatísticas automaticamente após downloads
   - Marcar categorias como "completas" se 100% disponíveis
   - Atualizar providers reativamente
   - Notificar outras partes da app sobre atualização

8. **10.8 - Tratamento de Erros de Download**
   - Capturar erros durante download/descompactação
   - Mensagens de erro amigáveis
   - Retry automático para downloads falhos
   - Limpeza de arquivos temporários em caso de erro

**Resultado Esperado**: Sistema de download e cache funcionando completamente, com PDFs armazenados localmente.

---

## FASE 11: Página de Modo Offline

**Objetivo**: Implementar interface completa de gerenciamento do modo offline.

### Entregáveis

1. **11.1 - Estrutura da Página Offline**
   - Criar rota `/offline`
   - Layout com seções: resumo geral, categorias, controles
   - Integrar com providers de estatísticas offline

2. **11.2 - Resumo de Disponibilidade Geral**
   - Card com estatísticas gerais:
     - Total de PDFs
     - Disponíveis no cache
     - Faltantes
     - Percentual geral
   - Barra de progresso visual

3. **11.3 - Seleção de Categorias para Download**
   - Lista de categorias (Partitura, Cifra, Gestos em Gravura)
   - Checkbox para cada categoria
   - Desabilitar checkboxes de categorias já baixadas (não podem ser removidas)
   - Badges de status (Completo, X% disponível)

4. **11.4 - Estatísticas por Categoria**
   - Card para cada categoria selecionada
   - Exibir: total, disponíveis, faltantes, percentual
   - Barra de progresso por categoria
   - Informações sobre pacotes necessários (número de lotes, tamanho total)

5. **11.5 - Botão de Download**
   - Botão principal "Baixar PDFs Faltantes"
   - Validar se há categorias selecionadas
   - Validar se há PDFs faltantes
   - Desabilitar durante download em andamento

6. **11.6 - Progresso de Download em Tempo Real**
   - Overlay ou seção dedicada mostrando progresso
   - Indicador de lote atual (X de Y)
   - Percentual de progresso geral
   - Lista de pacotes sendo baixados
   - Botão de cancelar download

7. **11.7 - Banner de Sincronização**
   - Mostrar banner quando dados podem estar desatualizados
   - Botão "Sincronizar agora" para atualização manual
   - Auto-ocultar após sincronização

8. **11.8 - Indicador de Status Offline**
   - Widget `OfflineIndicator` reutilizável
   - Mostrar status de conectividade
   - Badge com percentual de disponibilidade
   - Integrar no header da aplicação

9. **11.9 - Alerta de Requisitos Offline**
   - Widget `OfflineRequirementsAlert`
   - Informações sobre requisitos e limitações
   - Link para ajuda/documentação

10. **11.10 - Validação e Correção Automática**
    - Botão para validar consistência do cache
    - Corrigir inconsistências automaticamente
    - Feedback visual das correções

11. **11.11 - Limpeza de Cache**
    - Opção para limpar cache completo (com confirmação)
    - Remover todos os PDFs do cache
    - Limpar dados de categorias baixadas
    - Resetar estatísticas

**Resultado Esperado**: Interface completa de gerenciamento offline com todas as funcionalidades de download, estatísticas e controle.

---

## FASE 12: Auto-Download e Sincronização

**Objetivo**: Implementar sistema de auto-download e sincronização automática.

### Entregáveis

1. **12.1 - Detecção de Mudanças no Manifest**
   - Calcular hash do manifest (concatenação ordenada de `pdfId`)
   - Comparar com hash salvo em SharedPreferences
   - Detectar quando manifest muda (novos PDFs adicionados)

2. **12.2 - Auto-Download de Novos PDFs**
   - Quando manifest muda:
     - Identificar novos PDFs nas categorias selecionadas
     - Baixar apenas novos PDFs (não re-baixar existentes)
     - Atualizar hash do manifest
   - Executar em background (workmanager ou na inicialização)

3. **12.3 - Configuração de Auto-Download**
   - Verificar se auto-download está habilitado
   - Condições: categorias selecionadas + permissão offline ativa
   - Persistir preferência de auto-download

4. **12.4 - Notificações de Download**
   - Opcional: notificação quando novos PDFs são baixados
   - Mostrar quantidade de novos PDFs baixados
   - Usar `flutter_local_notifications` (opcional)

5. **12.5 - Sincronização na Inicialização**
   - Verificar mudanças no manifest ao abrir app
   - Executar auto-download se necessário
   - Mostrar feedback ao usuário

6. **12.6 - Polling de Verificação (Opcional)**
   - Verificar periodicamente se manifest mudou (opcional, configurável)
   - Executar apenas quando app está em foreground
   - Respeitar rate limiting para não sobrecarregar servidor

**Resultado Esperado**: Sistema automático de detecção e download de novos PDFs funcionando.

---

## FASE 13: Compartilhamento e Deep Links

**Objetivo**: Implementar sistema completo de compartilhamento e suporte a deep links.

### Entregáveis

1. **13.1 - Suporte a Links Compartilhados na Home**
   - Detectar parâmetros de URL: `?sharepdfs=...&sharename=...`
   - Parse de lista de PDF IDs
   - Carregar PDFs compartilhados no carousel
   - Navegar automaticamente para home após carregar
   - Feedback visual indicando que playlist foi carregada

2. **13.2 - Geração de Links de Playlist**
   - Função para gerar link compartilhável de playlist
   - Formato: `?sharepdfs=id1,id2,id3&sharename=Nome`
   - Incluir domínio base da aplicação

3. **13.3 - Compartilhamento Nativo**
   - Usar `share_plus` para compartilhar links
   - Compartilhar PDFs individuais (modo share)
   - Compartilhar playlists
   - Suporte a plataformas nativas (WhatsApp, email, etc.)

4. **13.4 - Deep Links no go_router**
   - Configurar deep links para todas as rotas
   - Suporte a `/leitor?file=...&titulo=...&subtitulo=...`
   - Suporte a `/listas` com filtros
   - Validação de parâmetros

5. **13.5 - Tratamento de Links Inválidos**
   - Validar PDFs referenciados em links compartilhados
   - Mostrar mensagem se PDFs não encontrados
   - Oferecer download se PDFs não estão em cache

**Resultado Esperado**: Sistema completo de compartilhamento e deep linking funcionando.

---

## FASE 14: Página Sobre

**Objetivo**: Implementar página informativa sobre a aplicação.

### Entregáveis

1. **14.1 - Estrutura da Página Sobre**
   - Criar rota `/sobre`
   - Layout com cards e seções bem definidas
   - Aplicar design system

2. **14.2 - Seção "Quem Somos"**
   - Informações sobre os desenvolvedores
   - Card com bordas douradas

3. **14.3 - Seção "Objetivo"**
   - Objetivo da aplicação
   - Card com bordas douradas

4. **14.4 - Seção "Como Usar"**
   - Subseções:
     - Uso básico
     - Uso offline
     - Uso da biblioteca
     - Uso das listas
     - Problemas conhecidos
   - Placeholders para vídeos futuros (usar `VideoPlayer` se necessário)

5. **14.5 - Footer**
   - Mensagem de agradecimento
   - Versão da aplicação
   - Links úteis (se houver)

**Resultado Esperado**: Página "Sobre" completa e informativa.

---

## FASE 15: Layout Global e Header

**Objetivo**: Implementar layout global com header responsivo e navegação.

### Entregáveis

1. **15.1 - AppScaffold Global**
   - Criar widget `AppScaffold` reutilizável
   - Integrar com `go_router` para navegação
   - Layout responsivo (mobile/tablet/desktop)

2. **15.2 - Header Fixo**
   - Header com altura fixa (56px + borda)
   - Oculto na página `/leitor` (fullscreen)
   - Background com cor do tema
   - Z-index alto para ficar acima do conteúdo

3. **15.3 - Botões de Navegação no Header**
   - **Esquerda**: Botão "Sobre", Botão "Biblioteca"
   - **Centro**: Título "PLPCG" (clicável para home)
   - **Direita**: Botão "Offline", Botão "Listas"
   - Layout responsivo:
     - Mobile: Apenas ícones (texto oculto)
     - Desktop: Ícones + texto

4. **15.4 - Indicador Offline no Header**
   - Integrar `OfflineIndicator` no canto superior direito
   - Mostrar status de conectividade
   - Badge com percentual de disponibilidade

5. **15.5 - Navegação entre Páginas**
   - Integração com `go_router`
   - Navegação tipo-safe
   - Transições suaves entre páginas

6. **15.6 - SafeArea**
   - Respeitar áreas seguras (notch, bottom bar)
   - Aplicar em todas as páginas

**Resultado Esperado**: Layout global completo com header responsivo e navegação funcional.

---

## FASE 16: Responsividade e Adaptações

**Objetivo**: Garantir que toda a aplicação seja totalmente responsiva em todos os dispositivos.

### Entregáveis

1. **16.1 - Breakpoints e Utilitários Responsivos**
   - Criar classe `Responsive` com breakpoints (mobile, tablet, desktop)
   - Utilitários: `isMobile`, `isTablet`, `isDesktop`
   - Helpers para valores adaptativos (ex: `responsiveValue<T>`)

2. **16.2 - Adaptação de Layouts**
   - Revisar todas as páginas para responsividade
   - Grids adaptativos (1/2/3+ colunas)
   - Espaçamentos adaptativos
   - Tamanhos de fonte adaptativos

3. **16.3 - Adaptação de Componentes**
   - `LouvorCard`: Tamanhos adaptativos
   - `SearchBar`: Layout adaptativo
   - Filtros: Wrap responsivo
   - Toolbar do leitor: Elementos ocultos/visíveis

4. **16.4 - Gestos e Interações Touch**
   - Garantir que todos os gestos funcionem em mobile
   - Tamanhos de área de toque adequados (min 44x44)
   - Feedback visual em todas as interações

5. **16.5 - Testes em Dispositivos Reais**
   - Testar em smartphones (vários tamanhos)
   - Testar em tablets
   - Testar em desktop/web
   - Ajustar problemas encontrados

**Resultado Esperado**: Aplicação totalmente responsiva em todos os dispositivos.

---

## FASE 17: Performance e Otimizações

**Objetivo**: Otimizar performance da aplicação seguindo best practices do Flutter.

### Entregáveis

1. **17.1 - Const Constructors**
   - Revisar todos os widgets e adicionar `const` onde possível
   - Reduzir rebuilds desnecessários

2. **17.2 - Otimização de Listas**
   - Garantir uso de `ListView.builder` / `GridView.builder` em todas as listas
   - Configurar `itemExtent` quando possível
   - Usar `RepaintBoundary` em cards complexos

3. **17.3 - Memoization com Riverpod**
   - Usar `select` para escutar apenas mudanças específicas
   - Evitar rebuilds desnecessários de widgets
   - Revisar todos os providers

4. **17.4 - Cache de Imagens e Recursos**
   - Configurar `ImageCache` com tamanhos adequados
   - Cache de assets estáticos
   - Lazy loading de recursos

5. **17.5 - Debounce e Throttling**
   - Revisar todos os debounces (pesquisa, filtros)
   - Implementar throttling onde necessário
   - Evitar chamadas excessivas de rebuild

6. **17.6 - Code Splitting**
   - Lazy loading de rotas com `go_router`
   - Deferred imports quando apropriado
   - Reduzir tamanho inicial do bundle

7. **17.7 - Animações Otimizadas**
   - Usar `flutter_animate` para animações performáticas
   - Evitar animações desnecessárias
   - Usar `RepaintBoundary` em widgets animados

8. **17.8 - Profiling e Análise**
   - Usar Flutter DevTools para profiling
   - Identificar e corrigir jank frames
   - Otimizar widgets com mais rebuilds

**Resultado Esperado**: Aplicação otimizada com 60fps garantidos e performance superior.

---

## FASE 18: Acessibilidade

**Objetivo**: Garantir que a aplicação seja acessível seguindo guidelines do Flutter.

### Entregáveis

1. **18.1 - Semântica e Screen Readers**
   - Adicionar `Semantics` widgets onde necessário
   - Labels descritivos para todos os elementos interativos
   - Hierarquia semântica adequada

2. **18.2 - Navegação por Teclado**
   - Garantir que todos os elementos sejam focáveis
   - Ordem de foco lógica (Tab navigation)
   - Atalhos de teclado funcionais

3. **18.3 - Contraste de Cores**
   - Verificar contraste de todas as cores (WCAG AA)
   - Ajustar cores se necessário
   - Suporte a tema de alto contraste (opcional)

4. **18.4 - Tamanhos de Toque**
   - Garantir tamanho mínimo de 44x44 para áreas de toque
   - Espaçamento adequado entre elementos clicáveis

5. **18.5 - Textos Alternativos**
   - Textos alternativos para ícones
   - Descrições para imagens (se houver)

6. **18.6 - Testes de Acessibilidade**
   - Testar com screen readers (TalkBack, VoiceOver)
   - Testar navegação por teclado
   - Correções baseadas em feedback

**Resultado Esperado**: Aplicação acessível seguindo guidelines do Flutter e WCAG.

---

## FASE 19: Tratamento de Erros e Edge Cases

**Objetivo**: Implementar tratamento robusto de erros e edge cases.

### Entregáveis

1. **19.1 - Tratamento Centralizado de Erros**
   - Criar `ErrorHandler` centralizado
   - Mapear erros para mensagens amigáveis
   - Logging de erros (usar `logger` package)

2. **19.2 - Estados de Erro em Todos os Fluxos**
   - Estados de erro em todos os providers assíncronos
   - Widgets de erro consistentes
   - Botões de retry onde apropriado

3. **19.3 - Validação de Dados**
   - Validar dados recebidos da API
   - Validar inputs do usuário
   - Mensagens de erro claras

4. **19.4 - Edge Cases**
   - App offline na inicialização
   - Manifesto vazio ou inválido
   - PDFs corrompidos
   - Falta de espaço em disco
   - Permissões negadas
   - Timeout de requisições

5. **19.5 - Feedback ao Usuário**
   - Snackbars para erros temporários
   - Dialogs para erros críticos
   - Loading states durante operações

6. **19.6 - Logging e Debugging**
   - Sistema de logging configurável (dev/prod)
   - Debug mode com informações adicionais
   - Remover logs em produção

**Resultado Esperado**: Aplicação robusta com tratamento completo de erros e edge cases.

---

## FASE 20: Testes

**Objetivo**: Implementar suite completa de testes.

### Entregáveis

1. **20.1 - Testes Unitários**
   - Testes para lógica de negócio (usecases)
   - Testes para utilitários (normalização, validação)
   - Testes para repositories
   - Cobertura mínima: 70%

2. **20.2 - Testes de Widgets**
   - Testes para widgets reutilizáveis
   - Testes para componentes complexos
   - Testes de interações (tap, scroll)

3. **20.3 - Testes de Integração**
   - Fluxo completo de pesquisa e filtros
   - Fluxo completo de download offline
   - Fluxo completo de criação de playlist
   - Navegação entre páginas

4. **20.4 - Testes de Performance**
   - Testes de renderização de listas longas
   - Testes de cache e downloads
   - Profiling automatizado

5. **20.5 - CI/CD com Testes**
   - Configurar pipeline de CI
   - Executar testes automaticamente
   - Relatórios de cobertura

**Resultado Esperado**: Suite completa de testes com boa cobertura.

---

## FASE 21: Polimento e Ajustes Finais

**Objetivo**: Polir a aplicação e fazer ajustes finais antes do lançamento.

### Entregáveis

1. **21.1 - Revisão de Design**
   - Revisar todos os screens para consistência
   - Ajustar espaçamentos e alinhamentos
   - Garantir que design system está aplicado corretamente

2. **21.2 - Animações e Transições**
   - Revisar todas as animações
   - Garantir transições suaves
   - Adicionar micro-interações onde apropriado

3. **21.3 - Copywriting e Textos**
   - Revisar todos os textos da aplicação
   - Garantir consistência de tom
   - Corrigir erros de ortografia

4. **21.4 - Ícones e Assets**
   - Revisar todos os ícones
   - Garantir que todos os assets estão incluídos
   - Otimizar tamanho de assets

5. **21.5 - Configuração de Build**
   - Configurar builds para produção (Android/iOS/Web)
   - Otimização de bundle size
   - Configurar app icons e splash screens

6. **21.6 - Documentação de Código**
   - Adicionar comentários JSDoc/DartDoc onde necessário
   - Documentar APIs públicas
   - README atualizado

7. **21.7 - Testes de Aceitação**
   - Testar todos os fluxos principais
   - Testar em dispositivos reais
   - Correções finais baseadas em feedback

**Resultado Esperado**: Aplicação polida e pronta para lançamento.

---

## Considerações Finais

### Princípios de Desenvolvimento

- ✅ **Clean Architecture**: Separação clara de responsabilidades
- ✅ **SOLID Principles**: Código extensível e manutenível
- ✅ **DRY**: Reutilização máxima de código
- ✅ **Test-Driven Development (TDD)**: Quando apropriado
- ✅ **Code Reviews**: Revisão de código para qualidade
- ✅ **Documentation**: Código documentado e compreensível

### Recursos do Flutter Aproveitados

- 🚀 **Compilação Nativa**: Performance superior a web
- 🎨 **Widget System**: Componentização poderosa e flexível
- 📱 **Gestos Nativos**: Touch gestures nativos e performáticos
- 🎭 **Animações**: Animações fluidas e declarativas
- 📦 **Package Ecosystem**: Ecossistema rico de pacotes
- 🔄 **Hot Reload**: Desenvolvimento rápido e iterativo
- 🌐 **Cross-Platform**: Base única para múltiplas plataformas

### Manutenção da Compatibilidade

A aplicação Flutter manterá total compatibilidade com:
- ✅ Endpoints do backend Cloudflare
- ✅ Estrutura de dados (JSON schemas)
- ✅ Design system "Coletânea Digital"
- ✅ Funcionalidades da versão legada

### Próximos Passos

Após conclusão de todas as fases:
1. Beta testing com usuários reais
2. Coleta de feedback
3. Ajustes baseados em feedback
4. Lançamento oficial
5. Monitoramento e manutenção contínua

---

**Versão do Documento**: 1.0  
**Data de Criação**: Dezembro 2024  
**Status**: Planejamento Inicial

