import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/pdf_viewer_mode.dart';
import '../constants/api_constants.dart';
import '../utils/pdf_path_utils.dart';
import '../../data/datasources/api_client.dart';

/// Serviço para executar ações de PDF (abrir, compartilhar, baixar)
class PdfActionService {
  PdfActionService(this._apiClient);

  final ApiClient _apiClient;

  /// Executa a ação de PDF baseada no modo selecionado
  Future<PdfActionResult> executePdfAction({
    required PdfViewerMode mode,
    required String pdfId,
    String? pdfPath,
    String? louvorNome,
  }) async {
    try {
      // Obter caminho do PDF a partir do pdfId se pdfPath não foi fornecido
      final effectivePdfPath = pdfPath ?? PdfPathUtils.getPdfPathFromId(pdfId);
      
      if (effectivePdfPath == null) {
        return PdfActionResult.error('Não foi possível determinar o caminho do PDF');
      }

      switch (mode) {
        case PdfViewerMode.online:
          return await _openOnline(effectivePdfPath);
        case PdfViewerMode.external:
          return await _openExternal(effectivePdfPath);
        case PdfViewerMode.share:
          return await _sharePdf(effectivePdfPath, louvorNome);
        case PdfViewerMode.download:
          return await _downloadPdf(effectivePdfPath, pdfId, louvorNome);
        case PdfViewerMode.internal:
          // Será implementado na Fase 8 (Leitor Interno)
          return PdfActionResult.error('Leitor interno ainda não implementado');
      }
    } catch (e) {
      return PdfActionResult.error('Erro ao executar ação: $e');
    }
  }

  /// Abre PDF online no navegador
  Future<PdfActionResult> _openOnline(String pdfPath) async {
    try {
      // Construir URL completa
      final url = _buildPdfUrl(pdfPath);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        return PdfActionResult.success('PDF aberto no navegador');
      } else {
        return PdfActionResult.error('Não foi possível abrir o PDF');
      }
    } catch (e) {
      return PdfActionResult.error('Erro ao abrir PDF online: $e');
    }
  }

  /// Abre PDF em app externo
  Future<PdfActionResult> _openExternal(String pdfPath) async {
    try {
      final url = _buildPdfUrl(pdfPath);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return PdfActionResult.success('PDF aberto em app externo');
      } else {
        return PdfActionResult.error('Nenhum app disponível para abrir o PDF');
      }
    } catch (e) {
      return PdfActionResult.error('Erro ao abrir PDF externo: $e');
    }
  }

  /// Compartilha PDF via Share API
  Future<PdfActionResult> _sharePdf(String pdfPath, String? louvorNome) async {
    try {
      final url = _buildPdfUrl(pdfPath);

      final text = louvorNome != null
          ? 'Compartilhar: $louvorNome\n$url'
          : 'Compartilhar PDF\n$url';

      await Share.share(
        text,
        subject: louvorNome ?? 'PDF',
      );
      return PdfActionResult.success('PDF compartilhado');
    } catch (e) {
      return PdfActionResult.error('Erro ao compartilhar PDF: $e');
    }
  }

  /// Baixa PDF no dispositivo
  Future<PdfActionResult> _downloadPdf(
    String pdfPath,
    String pdfId,
    String? louvorNome,
  ) async {
    try {
      // Verificar permissão de armazenamento
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Tentar permissão de gerenciamento de arquivos (Android 11+)
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          return PdfActionResult.error(
            'Permissão de armazenamento negada',
          );
        }
      }

      // Obter diretório de downloads
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = directory.path;

      // Criar nome de arquivo seguro
      final fileName = _createSafeFileName(pdfId, louvorNome);
      final filePath = '$downloadsDir/$fileName';

      // Baixar PDF
      final dio = Dio();
      final url = _buildPdfUrl(pdfPath);

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          // Progresso pode ser usado para feedback visual futuro
        },
      );

      return PdfActionResult.success(
        'PDF baixado com sucesso em: $filePath',
      );
    } catch (e) {
      return PdfActionResult.error('Erro ao baixar PDF: $e');
    }
  }

  /// Constrói URL completa do PDF
  String _buildPdfUrl(String pdfPath) {
    return PdfPathUtils.buildPdfUrl(pdfPath, baseUrl: ApiConstants.baseUrl);
  }

  /// Cria nome de arquivo seguro a partir do pdfId ou nome do louvor
  String _createSafeFileName(String pdfId, String? louvorNome) {
    // Tentar usar nome do louvor se disponível
    if (louvorNome != null && louvorNome.isNotEmpty) {
      final safeName = louvorNome
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .toLowerCase();
      return '$safeName.pdf';
    }

    // Caso contrário, usar pdfId (decodificar base64 se necessário)
    try {
      // Tentar decodificar base64
      final decoded = String.fromCharCodes(
        Uri.decodeComponent(pdfId).codeUnits,
      );
      final fileName = decoded.split('/').last;
      return fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    } catch (e) {
      // Se falhar, usar hash do pdfId
      return '${pdfId.hashCode}.pdf';
    }
  }
}

/// Resultado de uma ação de PDF
class PdfActionResult {
  const PdfActionResult.success(this.message) : isSuccess = true;
  const PdfActionResult.error(this.message) : isSuccess = false;

  final bool isSuccess;
  final String message;
}

