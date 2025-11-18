import 'dart:convert';

/// Utilitários para manipulação de caminhos de PDF
class PdfPathUtils {
  PdfPathUtils._();

  /// Obtém o caminho relativo do PDF a partir do pdfId (base64)
  /// Retorna null se não conseguir decodificar
  static String? getPdfPathFromId(String pdfId) {
    if (pdfId.isEmpty) {
      return null;
    }

    try {
      // Decodificar base64
      final decoded = utf8.decode(base64Decode(pdfId));
      
      // Normalizar removendo barras iniciais
      var path = decoded.replaceFirst(RegExp(r'^/+'), '').trim();
      
      if (path.isEmpty) {
        return null;
      }

      // Decodificar caracteres URI-encoded se necessário
      try {
        if (path.contains('%')) {
          path = Uri.decodeComponent(path);
        }
      } catch (_) {
        // Se decodeURIComponent falhar, mantém o path original
      }

      // Assegurar prefixo assets/
      if (!path.toLowerCase().startsWith('assets/')) {
        path = 'assets/$path';
      }

      return path;
    } catch (e) {
      // Se falhar, tentar usar pdfId diretamente como caminho
      // (pode ser que já venha como caminho em alguns casos)
      if (pdfId.startsWith('assets/') || pdfId.startsWith('/assets/')) {
        return pdfId.replaceFirst(RegExp(r'^/+'), '');
      }
      return null;
    }
  }

  /// Constrói URL completa do PDF a partir do caminho
  static String buildPdfUrl(String pdfPath, {String? baseUrl}) {
    // Remove barras iniciais se houver
    final cleanPath = pdfPath.replaceFirst(RegExp(r'^/+'), '');
    
    // Se baseUrl está vazio ou null (web), usar caminho relativo
    if (baseUrl == null || baseUrl.isEmpty) {
      return '/$cleanPath';
    }
    
    // Caso contrário, usar baseUrl completa
    return '${baseUrl.replaceAll(RegExp(r'/$'), '')}/$cleanPath';
  }
}

