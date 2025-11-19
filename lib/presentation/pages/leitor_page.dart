import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/pdf_path_utils.dart';
import '../widgets/pdf_viewer_toolbar.dart';

/// Página de leitor de PDF interno
class LeitorPage extends ConsumerStatefulWidget {
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
  ConsumerState<LeitorPage> createState() => _LeitorPageState();
}

class _LeitorPageState extends ConsumerState<LeitorPage> {
  late PdfViewerController _pdfViewerController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  // Estados
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  double _zoomLevel = 1.0;
  bool _isPageWidthMode = true; // true = width, false = height
  bool _isZoomFitMode = true;

  @override
  void initState() {
    super.initState();
    debugPrint('[LeitorPage] Inicializando com file: ${widget.file}');
    debugPrint('[LeitorPage] Título: ${widget.titulo}');
    debugPrint('[LeitorPage] Subtítulo: ${widget.subtitulo}');
    _pdfViewerController = PdfViewerController();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Carrega o PDF
  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Construir URL do PDF
      final pdfPath = widget.file.isNotEmpty
          ? PdfPathUtils.getPdfPathFromId(widget.file) ?? widget.file
          : '';
      
      debugPrint('[LeitorPage] PDF Path decodificado: $pdfPath');
      
      if (pdfPath.isEmpty) {
        throw Exception('Caminho do PDF não fornecido');
      }

      final pdfUrl = PdfPathUtils.buildPdfUrl(
        pdfPath,
        baseUrl: ApiConstants.baseUrl,
      );
      
      debugPrint('[LeitorPage] PDF URL final: $pdfUrl');

      // O PDF será carregado pelo widget SfPdfViewer
      // Aguardar um pouco para o carregamento inicial
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar PDF: $e';
      });
    }
  }

  /// Navega para página anterior
  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.previousPage();
      _updatePageInfo();
      _scrollToTop();
    }
  }

  /// Navega para próxima página
  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfViewerController.nextPage();
      _updatePageInfo();
      _scrollToTop();
    }
  }

  /// Navega para primeira página
  void _goToFirstPage() {
    if (_currentPage > 1) {
      _pdfViewerController.jumpToPage(1);
      _updatePageInfo();
      _scrollToTop();
    }
  }

  /// Navega para última página
  void _goToLastPage() {
    if (_currentPage < _totalPages && _totalPages > 0) {
      _pdfViewerController.jumpToPage(_totalPages);
      _updatePageInfo();
      _scrollToTop();
    }
  }

  /// Atualiza informações da página
  void _updatePageInfo() {
    if (_pdfViewerController.pageNumber != null) {
      setState(() {
        _currentPage = _pdfViewerController.pageNumber!;
      });
    }
  }

  /// Zoom in
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(0.25, 4.0);
      _isZoomFitMode = false;
    });
    _pdfViewerController.zoomLevel = _zoomLevel;
  }

  /// Zoom out
  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(0.25, 4.0);
      _isZoomFitMode = false;
    });
    _pdfViewerController.zoomLevel = _zoomLevel;
  }

  /// Alterna modo de ajuste (page-width / page-height)
  void _toggleFitMode() {
    setState(() {
      _isPageWidthMode = !_isPageWidthMode;
      _isZoomFitMode = true;
      // Aplicar ajuste baseado no modo
      // O Syncfusion não tem fit mode direto, então ajustamos o zoom manualmente
      // Por enquanto, resetamos para 1.0 e deixamos o usuário ajustar
      _zoomLevel = 1.0;
      _pdfViewerController.zoomLevel = 1.0;
    });
  }

  /// Reseta zoom
  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _isZoomFitMode = true;
      _isPageWidthMode = true;
    });
    _pdfViewerController.zoomLevel = 1.0;
  }

  /// Scroll suave para o topo
  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Manipula eventos de teclado (atalhos)
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      
      // Ctrl/Cmd + Plus: Zoom in
      if (isCtrl && event.logicalKey == LogicalKeyboardKey.equal) {
        _zoomIn();
      }
      // Ctrl/Cmd + Minus: Zoom out
      else if (isCtrl && event.logicalKey == LogicalKeyboardKey.minus) {
        _zoomOut();
      }
      // Ctrl/Cmd + 0: Reset zoom
      else if (isCtrl && event.logicalKey == LogicalKeyboardKey.digit0) {
        _resetZoom();
      }
      // Arrow Down/Page Down: Próxima página
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.pageDown) {
        _goToNextPage();
      }
      // Arrow Up/Page Up: Página anterior
      else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.pageUp) {
        _goToPreviousPage();
      }
    }
  }

  /// Constrói o visualizador de PDF com gestos
  Widget _buildPdfViewerWithGestures(String pdfUrl) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe horizontal para navegar
        final velocity = details.primaryVelocity ?? 0;
        
        // Swipe para esquerda (próxima página) - velocidade negativa
        if (velocity < -500) {
          _goToNextPage();
        }
        // Swipe para direita (página anterior) - velocidade positiva
        else if (velocity > 500) {
          _goToPreviousPage();
        }
      },
      child: _buildPdfViewer(pdfUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construir URL do PDF
    final pdfPath = widget.file.isNotEmpty
        ? PdfPathUtils.getPdfPathFromId(widget.file) ?? widget.file
        : '';
    
    if (pdfPath.isEmpty && !_isLoading && _errorMessage == null) {
      return _buildErrorWidget('Caminho do PDF não fornecido');
    }

    final pdfUrl = pdfPath.isNotEmpty
        ? PdfPathUtils.buildPdfUrl(
            pdfPath,
            baseUrl: ApiConstants.baseUrl,
          )
        : '';

    return Focus(
      autofocus: true,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Toolbar
              PdfViewerToolbar(
                titulo: widget.titulo,
                subtitulo: widget.subtitulo,
                currentPage: _currentPage,
                totalPages: _totalPages,
                zoomLevel: _zoomLevel,
                isPageWidthMode: _isPageWidthMode,
                isZoomFitMode: _isZoomFitMode,
                canGoPrevious: _currentPage > 1,
                canGoNext: _currentPage < _totalPages,
                onPrevious: _goToPreviousPage,
                onNext: _goToNextPage,
                onFirstPage: _goToFirstPage,
                onLastPage: _goToLastPage,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onToggleFit: _toggleFitMode,
                onResetZoom: _resetZoom,
                onClose: () => context.pop(),
              ),
              // Área de visualização do PDF
              Expanded(
                child: _buildPdfViewerWithGestures(pdfUrl),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Constrói o visualizador de PDF
  Widget _buildPdfViewer(String pdfUrl) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (pdfUrl.isEmpty) {
      return _buildErrorWidget('URL do PDF inválida');
    }

    return RepaintBoundary(
      child: SfPdfViewer.network(
        pdfUrl,
        controller: _pdfViewerController,
        scrollDirection: PdfScrollDirection.vertical,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        enableDoubleTapZooming: true,
        enableTextSelection: false,
        canShowScrollHead: true,
        canShowScrollStatus: false,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
            _currentPage = 1;
          });
        },
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
          // Scroll suave ao mudar de página
          _scrollToTop();
        },
        onZoomLevelChanged: (PdfZoomDetails details) {
          setState(() {
            _zoomLevel = details.newZoomLevel;
            if (details.newZoomLevel != 1.0) {
              _isZoomFitMode = false;
            }
          });
        },
      ),
    );
  }

  /// Widget de loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Carregando PDF...',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de erro
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Erro ao carregar PDF',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                _loadPdf();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Voltar',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

