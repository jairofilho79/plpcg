/// Constantes da API
class ApiConstants {
  ApiConstants._();

  // Base URL - pode ser relativa para web ou absoluta para mobile
  // Em produção, isso pode ser configurado via environment variables
  static const String baseUrl = ''; // Relativo para web, ou URL completa para mobile

  // Endpoints
  static const String louvoresManifest = '/louvores-manifest.json';
  static const String offlineManifest = '/offline-manifest.json';
  static const String packagesPath = '/packages';
  static const String assetsPath = '/assets';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

