import 'failures.dart';

/// Classe Result para tratamento funcional de erros
/// Similar a Either, mas mais simples e direto
sealed class Result<T> {
  const Result();
}

/// Resultado de sucesso
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Resultado de erro
final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}

/// Extensões úteis para Result
extension ResultExtensions<T> on Result<T> {
  /// Verifica se é sucesso
  bool get isSuccess => this is Success<T>;

  /// Verifica se é erro
  bool get isError => this is Error<T>;

  /// Obtém os dados se for sucesso, caso contrário retorna null
  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Error() => null,
      };

  /// Obtém o erro se for erro, caso contrário retorna null
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final failure) => failure,
      };

  /// Executa uma função se for sucesso
  Result<R> map<R>(R Function(T data) mapper) => switch (this) {
        Success(data: final data) => Success(mapper(data)),
        Error(failure: final failure) => Error<R>(failure),
      };

  /// Executa uma função assíncrona se for sucesso
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async =>
      switch (this) {
        Success(data: final data) => Success(await mapper(data)),
        Error(failure: final failure) => Error<R>(failure),
      };

  /// Executa uma função se for erro
  Result<T> mapError(Failure Function(Failure failure) mapper) => switch (this) {
        Success() => this,
        Error(failure: final failure) => Error(mapper(failure)),
      };
}

