/// Utilitários para validação de dados
class Validators {
  Validators._();

  /// Valida se uma string não está vazia
  static String? notEmpty(String? value, {String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }
    return null;
  }

  /// Valida se uma string tem um comprimento mínimo
  static String? minLength(String? value, int minLength, {String? errorMessage}) {
    if (value == null || value.length < minLength) {
      return errorMessage ?? 'Deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  /// Valida se uma string tem um comprimento máximo
  static String? maxLength(String? value, int maxLength, {String? errorMessage}) {
    if (value == null || value.length > maxLength) {
      return errorMessage ?? 'Deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  /// Valida se uma string está dentro de um intervalo de comprimento
  static String? lengthRange(
    String? value,
    int minLength,
    int maxLength, {
    String? errorMessage,
  }) {
    if (value == null) {
      return errorMessage ?? 'Este campo é obrigatório';
    }
    if (value.length < minLength || value.length > maxLength) {
      return errorMessage ??
          'Deve ter entre $minLength e $maxLength caracteres';
    }
    return null;
  }

  /// Valida se um email é válido (formato básico)
  static String? email(String? value, {String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return errorMessage ?? 'Email inválido';
    }
    return null;
  }

  /// Combina múltiplos validadores
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

