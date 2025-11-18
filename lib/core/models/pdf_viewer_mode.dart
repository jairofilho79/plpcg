/// Modos de visualização de PDF disponíveis
enum PdfViewerMode {
  /// Abre PDF em navegador (online)
  online,

  /// Abre PDF em app externo
  external,

  /// Compartilha PDF via Share API
  share,

  /// Baixa PDF direto no dispositivo
  download,

  /// Abre no leitor interno da aplicação
  internal,
}

/// Extensão para converter enum para string e vice-versa
extension PdfViewerModeExtension on PdfViewerMode {
  /// Converte enum para string para persistência
  String toJson() {
    switch (this) {
      case PdfViewerMode.online:
        return 'online';
      case PdfViewerMode.external:
        return 'external';
      case PdfViewerMode.share:
        return 'share';
      case PdfViewerMode.download:
        return 'download';
      case PdfViewerMode.internal:
        return 'internal';
    }
  }

  /// Converte string para enum
  static PdfViewerMode fromJson(String value) {
    switch (value) {
      case 'online':
        return PdfViewerMode.online;
      case 'external':
        return PdfViewerMode.external;
      case 'share':
        return PdfViewerMode.share;
      case 'download':
        return PdfViewerMode.download;
      case 'internal':
        return PdfViewerMode.internal;
      default:
        return PdfViewerMode.online; // Default
    }
  }

  /// Retorna o nome amigável do modo
  String get displayName {
    switch (this) {
      case PdfViewerMode.online:
        return 'Online';
      case PdfViewerMode.external:
        return 'App Externo';
      case PdfViewerMode.share:
        return 'Compartilhar';
      case PdfViewerMode.download:
        return 'Baixar';
      case PdfViewerMode.internal:
        return 'Leitor Interno';
    }
  }

  /// Retorna a descrição do modo
  String get description {
    switch (this) {
      case PdfViewerMode.online:
        return 'Abre o PDF no navegador';
      case PdfViewerMode.external:
        return 'Abre em aplicativo externo';
      case PdfViewerMode.share:
        return 'Compartilha o PDF';
      case PdfViewerMode.download:
        return 'Baixa o PDF no dispositivo';
      case PdfViewerMode.internal:
        return 'Abre no leitor interno';
    }
  }
}

