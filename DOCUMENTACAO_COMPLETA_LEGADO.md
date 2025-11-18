# Documentação Completa - PLPC (Pesquisador de Louvores em Partitura e Cifra)

## Índice

1. [Visão Geral](#visão-geral)
2. [Objetivos e Motivações](#objetivos-e-motivações)
3. [Requisitos Funcionais (Features em Alto Nível)](#requisitos-funcionais-features-em-alto-nível)
4. [Requisitos Não Funcionais (Features de Operação)](#requisitos-não-funcionais-features-de-operação)
5. [Diretrizes de Design](#diretrizes-de-design)
6. [Descrição das Páginas](#descrição-das-páginas)
7. [Service Worker (SW)](#service-worker-sw)
8. [Comunicação com Backend](#comunicação-com-backend)
9. [Modo Offline](#modo-offline)
10. [Página de Leitor de PDF](#página-de-leitor-de-pdf)

---

## Visão Geral

O **PLPC (Pesquisador de Louvores em Partitura e Cifra)** é uma aplicação web progressiva (PWA) desenvolvida para auxiliar equipes de louvor da Igreja Cristã Maranata. A aplicação permite pesquisa, visualização e gerenciamento offline de partituras, cifras e gestos em gravura para CIAs (Crianças, Intermediários e Adolescentes).

### Stack Tecnológico

- **Frontend**: SvelteKit 2.0, Tailwind CSS 3.4, Lucide Icons
- **Backend**: Cloudflare Pages Functions, Cloudflare Workers
- **Storage**: Cloudflare R2 (Object Storage)
- **PWA**: Service Workers customizados, Cache API
- **PDF Viewer**: PDF.js 4.8.69
- **Deploy**: Cloudflare Pages
- **Utilitários**: fflate (descompactação ZIP), yazl (criação de pacotes)

---

## Objetivos e Motivações

### Objetivo Principal

Ajudar os irmãos da equipe de louvor com os materiais mais básicos para o louvor (Partitura, Cifra e Gestos em gravura para CIAs), tornando fácil pesquisar, consumir e funcionar offline, pois muitas igrejas não têm internet ou é muito difícil o acesso em ESFs (Escolas Bíblicas de Férias).

### Motivações

1. **Acessibilidade Offline**: Muitas igrejas e ESFs não possuem conexão estável à internet, necessitando de uma solução que funcione completamente offline após o download inicial.

2. **Facilidade de Pesquisa**: Permitir busca rápida e eficiente por número ou nome do louvor, facilitando o trabalho dos músicos durante os ensaios e cultos.

3. **Organização por Categorias**: Classificar os materiais por tipo (Partitura, Cifra nível I, Cifra nível II, Gestos em Gravura) e por classificação (ColAdultos, ColCIAs, Avulsos, etc.).

4. **Gratuidade e Acessibilidade**: Aplicação 100% gratuita, desenvolvida por irmãos voluntários para servir à obra, sem fins lucrativos.

5. **Suporte Multi-dispositivo**: Funcionar em smartphones, tablets e desktops, com interface responsiva adaptada a cada tipo de dispositivo.

---

## Requisitos Funcionais (Features em Alto Nível)

### 1. Sistema de Pesquisa e Filtros

- **Pesquisa por Número**: Busca direta pelo número do louvor
- **Pesquisa por Nome**: Busca textual com normalização (remove acentos, case-insensitive)
- **Filtros por Categoria**: 
  - Partitura
  - Cifra (inclui automaticamente "Cifra nível I" e "Cifra nível II")
  - Gestos em Gravura
- **Filtros por Classificação**:
  - ColAdultos (Coletânea de Adultos)
  - ColCIAs (Coletânea de CIAs)
  - Avulsos
  - Outras classificações específicas
- **Debounce na Pesquisa**: Aguarda 300ms após o usuário parar de digitar antes de executar a busca

### 2. Biblioteca de Louvores

- **Visualização Paginada**: Lista todos os louvores com paginação configurável (10, 20, 30, 50, 100 itens por página)
- **Ordenação**: Por número ou por nome (alfabética)
- **Filtros Aplicáveis**: Mesmos filtros da página principal
- **Navegação Rápida**: Botões de primeira/última página com long press (500ms)
- **Indicador de Progresso**: Mostra página atual e total de páginas

### 3. Carousel de Louvores

- **Seleção de Louvores**: Adicionar louvores ao carousel para visualização sequencial
- **Navegação**: Chips clicáveis para navegar entre os louvores selecionados
- **Persistência**: Salvar carousel como playlist
- **Limpeza**: Botão para limpar o carousel

### 4. Sistema de Playlists

- **Criação**: Salvar carousel atual como playlist nomeada
- **Gerenciamento**: 
  - Editar nome da playlist
  - Marcar como favorita
  - Remover playlist
  - Compartilhar playlist via link
- **Filtros**: Buscar por nome, filtrar apenas favoritas
- **Reprodução**: Carregar playlist no carousel e navegar para página principal

### 5. Visualizador de PDF

- **Múltiplos Modos de Visualização**:
  - Online (abre em nova aba)
  - Nova aba (abre em nova janela)
  - Compartilhar (usa Web Share API)
  - Salvar (download direto)
  - Leitor interno (página dedicada)
- **Seletor de Modo**: Dropdown para escolher o modo preferido

### 6. Modo Offline

- **Download por Categorias**: Selecionar categorias para download offline
- **Download Otimizado**: Baixa apenas PDFs faltantes usando pacotes ZIP
- **Estatísticas**: Mostra disponibilidade por categoria (total, disponíveis, faltantes, percentual)
- **Sincronização**: Sistema de sincronização entre abas e após downloads
- **Auto-download**: Download automático de novos PDFs nas categorias selecionadas
- **Validação**: Verificação automática de consistência entre cache e manifest

### 7. Compartilhamento

- **Links de Playlist**: Gerar links compartilháveis com lista de PDFs
- **Web Share API**: Compartilhar PDFs usando API nativa do navegador
- **URLs com Parâmetros**: Suporte a links com `?sharepdfs=...&sharename=...`

---

## Requisitos Não Funcionais (Features de Operação)

### 1. Performance

- **Lazy Loading**: Carregamento sob demanda de componentes e recursos
- **Cache First Strategy**: PDFs e recursos estáticos servidos do cache quando disponível
- **Otimização de Imagens**: Ícones SVG e imagens otimizadas
- **Code Splitting**: Divisão automática de código pelo SvelteKit
- **Debounce**: Prevenção de chamadas excessivas em pesquisas e filtros

### 2. Responsividade

- **Mobile First**: Design otimizado para dispositivos móveis
- **Breakpoints**: Adaptação para mobile, tablet, desktop
- **Touch Gestures**: Suporte a gestos touch (pinch to zoom, swipe, long press)
- **Safe Area Insets**: Respeita áreas seguras em dispositivos com notch

### 3. Acessibilidade

- **ARIA Labels**: Atributos ARIA em elementos interativos
- **Keyboard Navigation**: Navegação completa via teclado
- **Screen Reader Support**: Estrutura semântica HTML
- **Contraste**: Cores com contraste adequado (WCAG AA)

### 4. Offline First

- **Service Worker**: Registro automático e gerenciamento de cache
- **Cache API**: Armazenamento de PDFs e recursos no Cache Storage
- **IndexedDB**: Armazenamento de dados estruturados (playlists, preferências)
- **localStorage**: Persistência de configurações e estado
- **Sincronização Cross-Tab**: BroadcastChannel para sincronizar estado entre abas

### 5. Segurança

- **CORS Headers**: Configuração adequada de CORS para APIs
- **Content Security Policy**: Políticas de segurança implementadas
- **HTTPS Only**: Aplicação funciona apenas em HTTPS (requisito para Service Workers)

### 6. Confiabilidade

- **Error Handling**: Tratamento robusto de erros com mensagens amigáveis
- **Retry Logic**: Tentativas automáticas em caso de falha de rede
- **Fallbacks**: Fallback para cache quando offline
- **Validação**: Validação de dados antes de processamento

### 7. Manutenibilidade

- **TypeScript**: Tipagem estática onde aplicável
- **Componentização**: Componentes Svelte reutilizáveis
- **Stores Centralizados**: Gerenciamento de estado com Svelte stores
- **Utils Separados**: Funções utilitárias em módulos separados
- **Comentários**: Código comentado e documentado

### 8. Escalabilidade

- **Cloudflare R2**: Armazenamento escalável de PDFs
- **CDN**: Distribuição global via Cloudflare CDN
- **Lazy Loading**: Carregamento sob demanda de recursos
- **Pagination**: Paginação para grandes volumes de dados

---

## Diretrizes de Design

### Tema Visual "Coletânea Digital"

A aplicação utiliza uma paleta de cores sóbria e elegante, inspirada em uma estética de "coletânea digital" com tons terrosos e dourados.

### Paleta de Cores

#### Cores Principais

- **Fundo Estrutural**: `#4B2D2B` (marrom escuro)
  - Usado como cor de fundo principal da aplicação
  - CSS Variable: `--background-color`

- **Cards e Superfícies**: `#FFF8E1` / `#f8f9fa` (bege claro/cinza muito claro)
  - Usado para cards, inputs e elementos de superfície
  - CSS Variable: `--card-color`

- **Títulos e Destaques**: `#6A2F2F` (marrom avermelhado)
  - Usado para títulos principais e elementos de destaque
  - CSS Variable: `--title-color`

- **Cor Dourada (Gold)**: `#D4AF37` (dourado)
  - Cor de destaque principal, usada em bordas, botões e elementos interativos
  - CSS Variable: `--gold-color`
  - Variação clara: `#F4D03F` (`--gold-light`)

- **Placeholders e Secundários**: `#F0E68C` (amarelo claro)
  - Usado em placeholders, textos secundários e elementos de apoio
  - CSS Variable: `--placeholder-color`

#### Cores de Texto

- **Texto Claro**: `#ffffff` (branco)
  - Usado sobre fundos escuros
  - CSS Variable: `--text-light`

- **Texto Escuro**: `#2c3e50` (cinza escuro)
  - Usado sobre fundos claros
  - CSS Variable: `--text-dark`

#### Cores de Botões e Estados

- **Botão Background**: `#6A3B39` (marrom médio)
  - CSS Variable: `--btn-background-color`

- **Badge Azul**: `#5a7a9c` (azul acinzentado)
  - CSS Variable: `--badge-blue-bg`

- **Badge Cinza**: `#9ca3af` (cinza)
  - CSS Variable: `--badge-gray-bg`

### Tipografia

#### Fontes

- **Títulos e Headers**: 
  - Fonte: `EB Garamond` (serif)
  - Fallback: `Garamond, Georgia, serif`
  - CSS Class: `font-garamond`
  - Características: Elegante, clássica, com serifas

- **Corpo de Texto**: 
  - Fonte: `Open Sans` (sans-serif)
  - Fallback: `sans-serif`
  - CSS Class: `font-sans`
  - Características: Moderna, legível, sem serifas

#### Tamanhos e Pesos

- **Títulos Principais (H1)**: 
  - Tamanho: `2rem` - `3rem` (responsivo)
  - Peso: `700` (bold)
  - Tracking: `0.03em` (letter-spacing)

- **Títulos de Seção (H2)**: 
  - Tamanho: `1.5rem` - `1.875rem`
  - Peso: `700`

- **Títulos de Subseção (H3)**: 
  - Tamanho: `1.25rem`
  - Peso: `600` (semi-bold)

- **Corpo de Texto**: 
  - Tamanho: `1rem` (16px base)
  - Peso: `400` (normal)

- **Texto Pequeno**: 
  - Tamanho: `0.875rem` (14px)
  - Peso: `400` ou `500`

- **Texto Muito Pequeno**: 
  - Tamanho: `0.75rem` (12px)
  - Peso: `500` ou `600`

#### Efeitos de Texto

- **Text Shadow**: Aplicado em títulos para profundidade
  - Exemplo: `text-shadow: 1px 1px 2px rgba(0,0,0,0.3);`

- **Subtitle Inset**: Efeito de texto entalhado para subtítulos
  - Múltiplas camadas de sombra para efeito 3D

### Espaçamento

- **Padding Padrão**: `1rem` (16px)
- **Padding de Cards**: `1rem` - `1.5rem`
- **Gap entre Elementos**: `0.5rem` - `1rem`
- **Margem entre Seções**: `1.5rem` - `2rem`

### Bordas e Raios

- **Border Radius Padrão**: `0.5rem` (8px)
- **Border Radius de Cards**: `0.75rem` (12px)
- **Border Radius de Chips**: `1.5rem` (24px)
- **Espessura de Borda**: `2px` (padrão), `4px` (destaques)

### Sombras

- **Sombra Média**: `0 4px 6px rgba(0,0,0,0.1)`
  - CSS Variable: `--shadow-md`

- **Sombra Grande**: `0 10px 15px rgba(0,0,0,0.2)`
  - CSS Variable: `--shadow-lg`

### Ícones

- **Biblioteca**: Lucide Svelte
- **Tamanho Padrão**: `1.25rem` (20px)
- **Tamanho Pequeno**: `1rem` (16px)
- **Tamanho Grande**: `1.5rem` (24px)
- **Cor**: Herda cor do texto ou usa `--gold-color` para destaque

### Responsividade

#### Breakpoints

- **Mobile**:
  - Header: Botões apenas com ícones (texto oculto)
  - Cards: Largura total
  - Grid: 1 coluna

- **Tablet**:
  - Header: Layout completo
  - Cards: Grid de 2 colunas
  - Toolbar: Elementos visíveis

- **Desktop**:
  - Header: Layout expandido
  - Cards: Grid de 3+ colunas

### Animações e Transições

- **Duração Padrão**: `0.2s` - `0.3s`
- **Easing**: `ease` ou `ease-in-out`
- **Hover Effects**: 
  - Transform: `translateY(-1px)` ou `translateY(-2px)`
  - Box-shadow: Aumento de sombra
  - Opacity: Mudanças sutis

### Estados de Interação

- **Hover**: 
  - Aumento de sombra
  - Transformação sutil
  - Mudança de cor de borda para `--gold-light`

- **Active**: 
  - Transformação reversa
  - Sombra reduzida

- **Focus**: 
  - Outline: `none`
  - Box-shadow: `0 0 0 3px rgba(244, 208, 63, 0.25)`
  - Border-color: `--gold-light`

- **Disabled**: 
  - Opacity: `0.5`
  - Cursor: `not-allowed`

---

## Descrição das Páginas

### 1. Página Principal (`/`)

**Rota**: `src/routes/+page.svelte`

**Descrição**: Página inicial da aplicação com sistema de pesquisa e filtros.

**Funcionalidades**:
- Barra de pesquisa com debounce (300ms)
- Filtros por categoria (Partitura, Cifra, Gestos em Gravura)
- Filtros por classificação (ColAdultos, ColCIAs, Avulsos, etc.)
- Seletor de modo de visualização de PDF
- Carousel de louvores selecionados (chips clicáveis)
- Lista de resultados da pesquisa
- Suporte a links compartilhados (`?sharepdfs=...&sharename=...`)

**Componentes Utilizados**:
- `SearchBar`: Barra de pesquisa
- `CategoryFilters`: Filtros por categoria
- `ClassificationFilters`: Filtros por classificação
- `PdfViewerSelector`: Seletor de modo de visualização
- `CarouselChips`: Chips do carousel
- `LouvorCard`: Card de exibição de louvor

**Lógica de Filtragem**:
1. Aplica filtro de categoria (com expansão automática de "Cifra")
2. Aplica filtro de classificação (normaliza removendo parênteses)
3. Aplica pesquisa (por número ou nome normalizado)
4. Exibe resultados ou mensagem "Nenhum resultado encontrado"

### 2. Biblioteca (`/biblioteca`)

**Rota**: `src/routes/biblioteca/+page.svelte`

**Descrição**: Visualização completa da biblioteca de louvores com paginação e ordenação.

**Funcionalidades**:
- Filtros por categoria e classificação (mesmos da página principal)
- Ordenação por número ou nome (alfabética)
- Paginação configurável (10, 20, 30, 50, 100 itens por página)
- Navegação de páginas:
  - Botões anterior/próxima
  - Input direto de número de página
  - Long press (500ms) em anterior/próxima para ir à primeira/última página
- Indicador de progresso (página X de Y)
- Seletor de modo de visualização de PDF

**Componentes Utilizados**:
- `CategoryFilters`: Filtros por categoria
- `ClassificationFilters`: Filtros por classificação
- `SortSelector`: Seletor de ordenação
- `PdfViewerSelector`: Seletor de modo de visualização
- `LouvorCard`: Card de exibição de louvor

**Estado**:
- Reset automático para página 1 quando filtros mudam
- Ajuste automático quando itens por página mudam
- Scroll suave para lista ao mudar de página

### 3. Leitor de PDF (`/leitor`)

**Rota**: `src/routes/leitor/+page.svelte`

**Descrição**: Visualizador de PDF dedicado com controles avançados. **Ver seção dedicada abaixo para detalhes completos.**

### 4. Modo Offline (`/offline`)

**Rota**: `src/routes/offline/+page.svelte`

**Descrição**: Página de configuração e gerenciamento do modo offline.

**Funcionalidades**:
- Resumo de disponibilidade geral (total, disponíveis, faltantes, percentual)
- Seleção de categorias para download
- Estatísticas por categoria (total, disponíveis, faltantes, percentual, barra de progresso)
- Informações sobre pacotes necessários (número de lotes, tamanho total)
- Botão de download com validação
- Progresso de download em tempo real
- Banner de sincronização quando dados podem estar desatualizados
- Botão de sincronização manual
- Indicador de categorias já baixadas (não podem ser removidas)
- Badges de status (Completo, X% disponível)

**Componentes Utilizados**:
- `OfflineRequirementsAlert`: Alerta sobre requisitos offline
- `OfflineIndicator`: Indicador de status offline

**Lógica**:
- Carrega estatísticas de disponibilidade por categoria
- Identifica PDFs faltantes usando manifest e cache
- Calcula pacotes necessários baseado em PDFs faltantes
- Baixa apenas lotes específicos necessários (otimizado)
- Atualiza estatísticas automaticamente após download
- Sincroniza entre abas usando BroadcastChannel

### 5. Listas/Playlists (`/listas`)

**Rota**: `src/routes/listas/+page.svelte`

**Descrição**: Gerenciamento de playlists salvas.

**Funcionalidades**:
- Lista de playlists salvas
- Busca por nome de playlist
- Filtro de favoritas (botão de estrela no header)
- Edição de nome (clique no nome ou botão de editar)
- Marcar/desmarcar como favorita
- Compartilhar playlist (gera link compartilhável)
- Reproduzir playlist (carrega no carousel e navega para home)
- Remover playlist (com modal de confirmação)
- Estado vazio com mensagens contextuais

**Componentes Utilizados**:
- Nenhum componente externo (tudo implementado na página)

**Persistência**:
- Armazenamento em `localStorage` via store `savedPlaylists`
- Estrutura: `{ id, nome, pdfIds: [], favorita: boolean }`

### 6. Sobre (`/sobre`)

**Rota**: `src/routes/sobre/+page.svelte`

**Descrição**: Página informativa sobre a aplicação.

**Conteúdo**:
- Seção "Quem somos": Informações sobre os desenvolvedores
- Seção "Objetivo": Objetivo da aplicação
- Seção "Como usar": 
  - Uso básico (placeholder para vídeo)
  - Uso offline (placeholder para vídeo)
  - Uso da biblioteca (placeholder para vídeo)
  - Uso das listas (placeholder para vídeo)
  - Problemas conhecidos (placeholder para vídeo)
- Footer: Mensagem de agradecimento

**Design**:
- Cards com bordas douradas
- Seções bem definidas
- Placeholders para vídeos futuros

### 7. Layout Global (`+layout.svelte`)

**Rota**: `src/routes/+layout.svelte`

**Descrição**: Layout principal da aplicação com header e estrutura comum.

**Componentes**:
- **Header Fixo** (oculto em `/leitor`):
  - Botão "Sobre" (esquerda)
  - Botão "Biblioteca" (esquerda)
  - Título "PLPC" (centro, clicável para home)
  - Botão "Offline" (direita)
  - Botão "Listas" (direita)
  - `OfflineIndicator` (canto superior direito)

**Funcionalidades**:
- Registro automático do Service Worker
- Setup de sincronização de cache
- Controle de overflow (oculto em `/leitor`)
- Navegação entre páginas

**Responsividade**:
- Mobile: Botões apenas com ícones
- Desktop: Botões com ícones e texto

---

## Service Worker (SW)

**Arquivo**: `static/sw.js`

**Versão do Cache**: `plpc-v3-dev`

### Estrutura de Caches

- **APP_CACHE**: `plpc-v3-dev-app`
  - Armazena: HTML shell, manifestos, ícones, recursos estáticos
- **PDF_CACHE**: `plpc-v3-dev-pdfs`
  - Armazena: Todos os PDFs baixados

### Eventos Tratados

#### 1. Install Event

- Cacheia app shell na instalação
- Recursos: `/`, `/manifest.json`, `/louvores-manifest.json`, `/offline-manifest.json`, `/favicon.svg`, `/icon-192.png`, `/icon-512.png`
- Chama `skipWaiting()` para ativação imediata

#### 2. Activate Event

- Limpa caches antigos (que começam com `plpc-` mas não são os atuais)
- Chama `clients.claim()` para controlar todas as abas

#### 3. Fetch Event

**Estratégias por Tipo de Recurso**:

1. **PDFs** (Cache First):
   - Verifica cache primeiro
   - Se não encontrado, busca na rede
   - Cacheia resposta bem-sucedida
   - Notifica clientes sobre atualização de cache

2. **Navigation Requests** (Network First em dev, Network First em prod):
   - **Dev**: Sempre busca na rede (não cacheia)
   - **Prod**: Busca na rede, cacheia resposta, fallback para cache se offline
   - Suporta SvelteKit SPA routing (serve `/` shell para todas as rotas)

3. **App Shell** (Cache First):
   - Verifica cache primeiro
   - Fallback para rede se não encontrado

4. **Development Assets** (Network First em dev):
   - Em modo dev: Sempre busca na rede (bypass cache)
   - Em prod: Cache First

5. **Outros Recursos** (Cache First em prod, Network First em dev):
   - **Dev**: Network First
   - **Prod**: Cache First

### Detecção de Modo de Desenvolvimento

- Detecta por hostname: `localhost`, `127.0.0.1`, IPs locais (`192.168.*`, `10.*`, `172.16.*`), `.local`
- Em dev: Desabilita cache para JS/CSS do Vite/SvelteKit
- Em dev: Usa Network First para todos os recursos

### Mensagens do Service Worker

#### DOWNLOAD_PDFS

- **Parâmetros**: `{ pdfsToDownload: string[], batchSize: number }`
- **Comportamento**: 
  - Baixa PDFs em lotes (batch)
  - Processa em paralelo dentro de cada lote
  - Envia progresso via `PROGRESS`
  - Envia resultado final via `COMPLETE` ou `ERROR`
  - Suporta cancelamento

#### CANCEL_DOWNLOAD

- **Comportamento**: Cancela download em andamento
- **Resposta**: `CANCEL_CONFIRMED`

#### GET_CACHED_PDFS

- **Comportamento**: Retorna lista de URLs de PDFs em cache
- **Resposta**: `{ type: 'CACHED_PDFS', pdfs: string[], count: number }`

#### CLEAR_CACHE

- **Comportamento**: Limpa todos os caches (APP_CACHE e PDF_CACHE)
- **Resposta**: `CACHE_CLEARED`
- **Notificação**: Notifica clientes sobre limpeza

#### SKIP_WAITING

- **Comportamento**: Força ativação imediata do novo Service Worker

### Notificações para Clientes

- **CACHE_UPDATED**: Disparado quando cache é atualizado
  - Inclui: `timestamp`, `source`, `cleared` (opcional)

### Funções Auxiliares

- `isDevelopmentMode()`: Detecta se está em modo de desenvolvimento
- `isDevelopmentAsset(url)`: Verifica se é asset de desenvolvimento
- `notifyClientsCacheUpdated(data)`: Notifica todos os clientes sobre atualização de cache

---

## Comunicação com Backend

### Arquitetura

A aplicação utiliza **Cloudflare Pages Functions** e **Cloudflare Workers** como backend, com armazenamento em **Cloudflare R2**.

### Endpoints

#### 1. Manifesto de Louvores

**GET** `/louvores-manifest.json`

- **Rota**: `src/routes/louvores-manifest.json/+server.js`
- **Descrição**: Retorna lista completa de louvores
- **Resposta**: Array de objetos `Louvor`
- **Estrutura do Objeto**:
  ```json
  {
    "nome": "Nome do Louvor",
    "classificacao": "ColAdultos",
    "numero": "123",
    "categoria": "Partitura",
    "pdf": "assets/ColAdultos/nome-arquivo.pdf",
    "pdfId": "base64-encoded-path"
  }
  ```
- **Cache**: Servido do R2, pode ser cacheado pelo navegador
- **Uso**: Carregado na inicialização da aplicação via `loadLouvores()`

#### 2. Manifesto Offline

**GET** `/offline-manifest.json`

- **Rota**: `src/routes/offline-manifest.json/+server.js`
- **Descrição**: Retorna informações sobre pacotes ZIP para download offline
- **Resposta**: Objeto com estrutura de pacotes
- **Estrutura**:
  ```json
  {
    "packages": {
      "Partitura": {
        "parts": [
          {
            "filename": "Partitura-1.zip",
            "url": "/packages/Partitura-1.zip",
            "size": 12345678,
            "category": "Partitura"
          }
        ],
        "totalSize": 12345678
      }
    }
  }
  ```
- **Uso**: Usado pela página offline para calcular downloads necessários

#### 3. Recursos Estáticos

**GET** `/packages/{filename}.zip`

- **Descrição**: Pacotes ZIP para download offline
- **Armazenamento**: Cloudflare R2 ou servidor estático
- **Uso**: Baixados pela página offline e descompactados no cliente

**GET** `/assets/{classificacao}/{filename}.pdf`

- **Descrição**: PDFs individuais
- **Armazenamento**: Cloudflare R2
- **Uso**: Servidos diretamente ou via cache do Service Worker

### Utilitários de Autenticação

- `base64ToBuffer(base64)`: Converte string base64 para ArrayBuffer

### Variáveis de Ambiente (Cloudflare)
- `LOUVORES_BUCKET`: Binding para bucket R2 com os PDFs

### Estrutura de Dados no R2

```
R2 Bucket (LOUVORES_BUCKET)
├── louvores-manifest.json          # Manifesto principal
├── offline-manifest.json           # Manifesto offline
├── assets/
│   ├── ColAdultos/
│   │   ├── louvor-1.pdf
│   │   └── louvor-2.pdf
│   ├── ColCIAs/
│   │   └── ...
│   └── Avulsos/
│       └── ...
└── packages/
    ├── Partitura-1.zip
    ├── Partitura-2.zip
    ├── Cifra-1.zip
    └── ...
```

---

## Modo Offline

O modo offline é uma das funcionalidades mais importantes da aplicação, permitindo uso completo sem conexão à internet após o download inicial.

### Arquitetura

#### Componentes Principais

1. **Service Worker** (`static/sw.js`): Gerencia cache de PDFs e recursos
2. **Offline Store** (`src/lib/stores/offline.js`): Gerencia estado e lógica offline
3. **Página Offline** (`src/routes/offline/+page.svelte`): Interface de configuração
4. **Utils**:
   - `swRegistration.js`: Registro e comunicação com SW
   - `pdfValidation.js`: Validação de disponibilidade de PDFs
   - `cacheSync.js`: Sincronização entre abas
   - `pdfIndex.js`: Índice de PDFs para busca rápida

### Fluxo de Download

#### 1. Seleção de Categorias

- Usuário seleciona categorias na página `/offline`
- Categorias são salvas em `localStorage` (`selectedCategoriesForDownload`)
- Categorias já baixadas não podem ser desmarcadas

#### 2. Cálculo de PDFs Faltantes

- Compara `louvores-manifest.json` com lista de PDFs em cache
- Identifica PDFs faltantes por categoria usando `identifyMissingPdfs()`
- Normaliza URLs para comparação (encoding, case, path separators)

#### 3. Identificação de Pacotes Necessários

- Consulta `offline-manifest.json` para encontrar pacotes ZIP
- Usa `findRequiredPackages()` para identificar lotes específicos
- Calcula apenas os lotes que contêm PDFs faltantes (otimização)

#### 4. Download de Pacotes ZIP

- Baixa pacotes ZIP específicos (não todos)
- Processa em lotes para evitar sobrecarga
- Usa `AbortController` para suportar cancelamento

#### 5. Descompactação e Cache

- Descompacta ZIPs usando `fflate.unzip()`
- Filtra apenas PDFs necessários (ignora outros arquivos)
- Normaliza caminhos dos arquivos extraídos
- Armazena PDFs individuais no Cache Storage (PDF_CACHE)
- Remove ZIPs do cache após extração (economia de espaço)

#### 6. Atualização de Estado

- Atualiza lista de PDFs em cache
- Recalcula estatísticas por categoria
- Marca categorias como "completas" se 100% dos PDFs estão disponíveis
- Salva categorias baixadas em `localStorage` (`OFFLINE_CATEGORIAS_SALVAS`)
- Notifica outras abas sobre atualização

### Estratégias de Cache

#### Cache First para PDFs

- Service Worker verifica cache primeiro
- Se encontrado, serve imediatamente (sem delay de rede)
- Se não encontrado, busca na rede e cacheia

#### Network First para Navegação

- Em produção: Tenta rede primeiro, fallback para cache
- Em desenvolvimento: Sempre busca na rede (não cacheia)

#### Cache de Manifestos

- `louvores-manifest.json`: Cacheado pelo navegador
- `offline-manifest.json`: Cacheado em `localStorage` como fallback

### Sincronização Entre Abas

#### BroadcastChannel

- Usa `BroadcastChannel` para comunicação entre abas
- Canal: `plpc-cache-sync`
- Eventos:
  - `cache-updated`: Notifica sobre atualização de cache
  - `cache-sync-required`: Solicita sincronização

#### Versionamento de Cache

- Versão de cache armazenada em `localStorage` (`cache-version`)
- Comparação de versões entre abas
- Sincronização automática quando versão muda

#### Atualização Automática de Estatísticas

- Sistema híbrido de atualização:
  1. **Subscription ao Store**: Reativo a mudanças em `cachedCount`
  2. **Event Listeners**: Escuta eventos `offline-cache-updated` e `cache-sync-required`
  3. **Polling de Fallback**: Verifica mudanças a cada 5 segundos
  4. **Visibility Change**: Atualiza quando aba fica visível
  5. **Window Focus**: Atualiza quando janela ganha foco
- Rate limiting: Mínimo de 2 segundos entre atualizações de stats
- Fila de atualizações com prioridades (high/normal)

### Auto-Download

#### Detecção de Novos PDFs

- Compara hash do manifest atual com hash salvo
- Hash: Concatenação ordenada de todos os `pdfId`
- Armazenado em `localStorage` (`lastManifestHash`)

#### Download Automático

- Quando manifest muda:
  1. Identifica novos PDFs nas categorias selecionadas
  2. Baixa apenas novos PDFs (não re-baixa existentes)
  3. Atualiza hash do manifest
  4. Notifica usuário (opcional)

#### Configuração

- Auto-download habilitado quando:
  - `ALLOW_OFFLINE_KEY === 'true'` em `localStorage`
  - Categorias selecionadas em `selectedCategoriesForDownload`
- Executado automaticamente na inicialização e quando manifest muda

### Validação e Consistência

#### Validação de Disponibilidade

- `validatePdfAvailability(pdfPath)`: Verifica se PDF está em cache
- Retorna: `{ available: boolean, needsDownload: boolean, url: string }`
- Usado pelo leitor para verificar antes de carregar

#### Sincronização de Estatísticas

- `validateAndSyncStats()`: Valida e corrige inconsistências
- Verifica:
  - Categorias marcadas como baixadas vs. realidade do cache
  - Estatísticas de disponibilidade vs. cache real
  - Mensagens de erro vs. PDFs realmente faltantes
- Corrige automaticamente:
  - Remove categorias marcadas incorretamente
  - Adiciona categorias completas não marcadas
  - Limpa erros quando não há PDFs faltantes

#### Limpeza de Cache

- `clearAllCache()`: Limpa todos os caches
- Remove:
  - APP_CACHE
  - PDF_CACHE
  - Dados em `localStorage` relacionados a offline
- Notifica outras abas sobre limpeza

### Otimizações

#### Download Otimizado por Lotes

- Baixa apenas lotes específicos necessários
- Não baixa lotes completos se apenas alguns PDFs faltam
- Agrupa PDFs faltantes por categoria
- Calcula interseção entre PDFs faltantes e conteúdo dos lotes

#### Normalização de URLs

- Função unificada `normalizePathForComparison()`:
  - Remove protocolo e domínio
  - Decodifica URI encoding (múltiplas vezes se necessário)
  - Normaliza para lowercase
  - Normaliza separadores de caminho (`\` → `/`)
  - Remove barras iniciais/finais
- Usada em todas as comparações para máxima compatibilidade

#### Índice de PDFs

- `pdfIndex.js`: Cria índice em memória para busca rápida
- Estrutura: Map de `pdfId` → informações do louvor
- Atualizado em background após downloads
- Usado para validação rápida de disponibilidade

### Limitações e Considerações

#### Limite de Cache

- Cache Storage tem limites por origem (geralmente 50-100MB)
- Aplicação não gerencia remoção automática de cache antigo
- Usuário deve limpar cache manualmente se necessário

#### Remoção Individual

- **Não implementado**: Remoção de PDFs individuais do cache
- **Workaround**: Limpar cache completo via navegador

#### Sincronização Offline

- Sincronização entre abas requer que ambas estejam online
- Cache atualizado em uma aba não é imediatamente visível em outra se offline

---

## Página de Leitor de PDF

**Rota**: `src/routes/leitor/+page.svelte`

A página de leitor de PDF é uma das funcionalidades mais sofisticadas da aplicação, oferecendo uma experiência completa de visualização de PDFs com controles avançados e suporte a gestos touch.

### Parâmetros de URL

- `file`: Caminho do PDF a ser carregado (ex: `/pdfs/exemplo.pdf`)
- `titulo`: Título a ser exibido na toolbar
- `subtitulo`: Subtítulo a ser exibido na toolbar

**Exemplo**: `/leitor?file=/assets/ColAdultos/louvor.pdf&titulo=Nome do Louvor&subtitulo=ColAdultos`

### Arquitetura

#### Bibliotecas Utilizadas

- **PDF.js 4.8.69**: Biblioteca Mozilla para renderização de PDFs
  - `pdfjs-dist/build/pdf.mjs`: Core do PDF.js
  - `pdfjs-dist/web/pdf_viewer.mjs`: Viewer components
  - `pdfjs-dist/build/pdf.worker.min.mjs`: Web Worker para processamento

#### Componentes PDF.js

- **PDFSinglePageViewer**: Viewer de página única (uma página por vez)
- **PDFLinkService**: Serviço de links internos do PDF
- **EventBus**: Sistema de eventos do PDF.js

### Toolbar

#### Layout

- **Posição**: Fixa no topo (z-index: 1000)
- **Altura**: 56px (60px incluindo borda)
- **Grid Responsivo**:
  - Mobile: `grid-template-columns: 1fr repeat(6, max-content)`
  - Tablet+: `grid-template-columns: auto 1fr repeat(6, max-content)`

#### Elementos

1. **Brand "PLPC"** (esquerda, mobile; própria coluna, tablet+)
   - Fonte: EB Garamond, 1.5rem (1.75rem desktop)
   - Cor: `--placeholder-color`
   - Text-shadow para profundidade

2. **Título e Subtítulo** (centro, mobile; coluna 2, tablet+)
   - Título: Fonte weight 600, ellipsis se muito longo
   - Subtítulo: 12px, opacity 0.8, ellipsis se muito longo

3. **Botão Anterior** (←)
   - Navega para página anterior
   - Grid: coluna 2 (mobile) ou 3 (tablet+), rows 1-4

4. **Indicador de Página** (X / Y)
   - Mostra página atual e total
   - Fonte tabular-nums para alinhamento
   - Grid: coluna 3 (mobile) ou 4 (tablet+)

5. **Botão Próxima** (→)
   - Navega para próxima página
   - Grid: coluna 4 (mobile) ou 5 (tablet+)

6. **Botão Zoom Out** (-)
   - Diminui zoom em 10%
   - Oculto em telas mobile
   - Grid: coluna 5 (mobile) ou 6 (tablet+)

7. **Botão Zoom Fit** (XX%)
   - Mostra percentual de zoom atual
   - **Clique simples**: Ajusta para modo de fit preferido
   - **Long press (500ms)**: Alterna entre `page-fit` e `page-width`
   - Indicadores visuais:
     - `page-fit`: Barras horizontais (topo e fundo)
     - `page-width`: Barras verticais (esquerda e direita)
   - Grid: coluna 6 (mobile) ou 7 (tablet+)

8. **Botão Zoom In** (+)
   - Aumenta zoom em 10%
   - Oculto em telas mobile
   - Grid: coluna 7 (mobile) ou 8 (tablet+)

### Modos de Ajuste de Zoom

#### Page Fit (Padrão)

- Ajusta PDF para caber na altura da viewport
- Mantém proporção original
- Páginas centralizadas horizontalmente
- Usa `viewer.currentScaleValue = 'page-fit'`

#### Page Width

- Ajusta PDF para preencher toda a largura disponível
- Calcula escala manualmente baseado na largura natural da página
- Considera largura de scrollbar (17px em desktop Windows)
- Cacheia escala calculada para reutilização
- Força recálculo em resize de janela
- Usa `viewer.currentScale = calculatedScale`

**Cálculo de Page Width**:
```javascript
const naturalViewport = pdfPage.getViewport({ scale: 1.0 });
const naturalWidth = naturalViewport.width;
const availableWidth = containerEl.clientWidth - scrollbarWidth;
const targetScale = availableWidth / naturalWidth;
```

### Gestos Touch

#### Pinch to Zoom

- **Detecção**: 2 toques simultâneos
- **Comportamento**:
  - Calcula distância inicial entre toques
  - Atualiza zoom proporcionalmente durante movimento
  - Limita zoom entre 0.25x e 4x
  - Previne comportamento padrão do navegador

#### Navegação por Toque

- **Detecção**: 1 toque, movimento < 10px, duração < 300ms
- **Zonas**:
  - **Primeiro quarto (0-25%)**: Página anterior
  - **Último quarto (75-100%)**: Próxima página
  - **Meio (25-75%)**: Sem ação (permite scroll)

#### Long Press

- **Duração**: 500ms
- **Uso**: Alternar modo de fit no botão de zoom

### Atalhos de Teclado

- **Ctrl/Cmd + Plus (+)**: Zoom in
- **Ctrl/Cmd + Minus (-)**: Zoom out
- **Ctrl/Cmd + 0**: Reset para modo de fit preferido
- **Arrow Down / Page Down**: Próxima página
- **Arrow Up / Page Up**: Página anterior

### Validação de PDF

#### Verificação de Disponibilidade

- Antes de carregar, verifica se PDF está em cache
- Usa `validatePdfAvailability()` de `pdfValidation.js`
- Se não disponível e online:
  - Tenta download automático via Service Worker
  - Máximo de 2 tentativas
  - Mostra feedback ao usuário

#### Estados de Carregamento

- **Loading**: Overlay com spinner e mensagem "Carregando PDF..."
- **Error**: Banner vermelho com mensagem de erro
  - Se offline: Botão para ir à página de configuração offline
- **Success**: PDF renderizado normalmente

### Integração com Service Worker

#### Flag IS_LEITOR_OFFLINE

- Quando acessa `/leitor`, define `IS_LEITOR_OFFLINE = 'true'` em `localStorage`
- Usado para indicar que usuário está usando leitor offline
- Pode ser usado para ajustar comportamento

#### Cache First

- Service Worker serve PDFs do cache primeiro
- Se não encontrado, busca na rede e cacheia
- Reduz latência e permite uso offline

### Estilos e Layout

#### Container Principal

- **Posição**: Fixed, cobre toda a viewport
- **Top**: Dinâmico (altura da toolbar)
- **Background**: `#2a2a2a` (cinza escuro)
- **Overflow**: Auto (permite scroll)
- **Touch Action**: `pan-x pan-y` (permite scroll, previne pinch padrão)

#### Viewer

- **Largura**: 100% do container
- **Margens**: Removidas (PDF.js padrão)
- **Padding**: 0

#### Modos de Exibição

- **Page Fit Mode**: Páginas centralizadas com `margin: 0 auto`
- **Page Width Mode**: Páginas sem margem horizontal (preenchem largura)

### Eventos PDF.js

#### pagesinit

- Disparado quando páginas são inicializadas
- Aplica escala inicial baseada no modo preferido
- Para `page-width`: Calcula e aplica escala manualmente

#### scalechanging

- Disparado durante mudanças de zoom
- Atualiza percentual exibido na toolbar
- Ignora durante ajuste manual de `page-width`

#### pagesloaded

- Disparado quando páginas são carregadas
- Atualiza contador de páginas total
- Ajusta zoom se em modo `page-width`

#### pagechanging

- Disparado ao mudar de página
- Atualiza página atual
- Ajusta zoom se em modo `page-width` (reutiliza escala cacheada)

### Performance

#### Cache de Escala

- Escala calculada para `page-width` é cacheada
- Reutilizada ao mudar de página se largura do container não mudou
- Limpa cache em resize de janela

#### Debounce de Ajustes

- Timeouts para evitar recálculos excessivos
- `pageWidthAdjustTimeout`: Debounce de 50-150ms
- Previne loops de recálculo

#### Lazy Loading de Páginas

- PDF.js carrega páginas sob demanda
- Apenas página visível é renderizada inicialmente
- Text layer carregado apenas quando necessário (`textLayerMode: 2`)

### Tratamento de Erros

#### Erro de Carregamento

- Captura erros durante `getDocument()`
- Mostra banner de erro com mensagem amigável
- Oferece retry automático (máx. 2 tentativas)
- Se offline: Botão para ir à configuração offline

#### PDF Não Disponível

- Verifica disponibilidade antes de carregar
- Se não disponível:
  - Tenta download automático se online
  - Mostra mensagem se offline
  - Oferece navegação para página offline

### Acessibilidade

#### ARIA Labels

- Todos os botões têm `aria-label` descritivo
- Indicador de página tem `aria-label`

#### Navegação por Teclado

- Todos os controles acessíveis via teclado
- Foco visível em elementos interativos

#### Screen Readers

- Estrutura semântica HTML
- Textos alternativos onde necessário

## Conclusão

Esta documentação cobre todos os aspectos principais da aplicação PLPC, desde objetivos e motivações até detalhes técnicos de implementação. A aplicação é uma solução completa e robusta para gerenciamento offline de partituras e cifras, com foco em usabilidade, performance e confiabilidade.

Para mais informações ou suporte, consulte a página "Sobre" na aplicação ou entre em contato com a equipe de desenvolvimento.

---

**Última atualização**: Dezembro 2024  
**Versão da Aplicação**: 1.0.0  
**Versão do Documento**: 1.0

