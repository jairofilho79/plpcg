/// Classe base para falhas/erros da aplicação
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => message;
}

/// Falha de rede/conexão
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Falha de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message, [this.statusCode]);

  final int? statusCode;
}

/// Falha de cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Falha de validação
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha de permissão
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Falha desconhecida
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

