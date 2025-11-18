import '../utils/text_normalization.dart';

/// Extensões úteis para String
extension StringExtensions on String {
  /// Remove acentos da string
  String removeAccents() => TextNormalization.removeAccents(this);

  /// Normaliza texto para busca (remove acentos e converte para lowercase)
  String normalize() => TextNormalization.normalizeText(this);

  /// Verifica se contém outro texto (normalizado)
  bool containsNormalized(String search) =>
      TextNormalization.containsNormalized(this, search);

  /// Capitaliza a primeira letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palavra
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Trunca string com ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Verifica se é um número válido
  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  /// Verifica se está vazia ou contém apenas espaços
  bool get isBlank => trim().isEmpty;
}

