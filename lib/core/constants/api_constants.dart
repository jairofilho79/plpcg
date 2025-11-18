import 'package:flutter/foundation.dart';

/// Constantes da API
class ApiConstants {
  ApiConstants._();

  // Base URL configurável por ambiente
  // Em dev: usa plpcjf.org (requisição externa)
  // Em produção: usa / (relativo, busca direto do bucket R2)
  static String get baseUrl {
    if (kDebugMode) {
      // Modo desenvolvimento: usar URL completa
      return 'https://plpcjf.org';
    } else {
      // Modo produção: usar URL relativa (busca do bucket R2)
      return '';
    }
  }

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

