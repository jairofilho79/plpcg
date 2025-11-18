import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';

/// Cliente HTTP usando Dio com interceptors e retry logic
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: ApiConstants.defaultHeaders,
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Logging interceptor (apenas em dev)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          // Em produção, usar logger apropriado
          if (const bool.fromEnvironment('dart.vm.product') == false) {
            print(object);
          }
        },
      ),
    );

    // Retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < ApiConstants.maxRetries) {
              error.requestOptions.extra['retryCount'] = retryCount + 1;
              await Future.delayed(ApiConstants.retryDelay);
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// GET request
  Future<Result<Response>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  /// POST request
  Future<Result<Response>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  /// Download file
  Future<Result<Response>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
      return Success(response);
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Tempo de conexão excedido');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ServerFailure(
          error.response?.data?.toString() ?? 'Erro do servidor',
          statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkFailure('Requisição cancelada');
      case DioExceptionType.connectionError:
        return NetworkFailure('Erro de conexão');
      default:
        return NetworkFailure('Erro de rede: ${error.message}');
    }
  }
}

