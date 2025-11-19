/// Enum para tipos de ordenação de louvores
enum SortOrder {
  /// Ordenação por número (crescente)
  number,
  
  /// Ordenação por nome (alfabética)
  name,
}

extension SortOrderExtension on SortOrder {
  /// Retorna o nome legível do tipo de ordenação
  String get displayName {
    switch (this) {
      case SortOrder.number:
        return 'Por número';
      case SortOrder.name:
        return 'Por nome';
    }
  }
  
  /// Converte para string para armazenamento
  String toStorageString() {
    switch (this) {
      case SortOrder.number:
        return 'number';
      case SortOrder.name:
        return 'name';
    }
  }
}

/// Função helper para criar SortOrder a partir de string do storage
SortOrder sortOrderFromStorageString(String value) {
  switch (value) {
    case 'number':
      return SortOrder.number;
    case 'name':
      return SortOrder.name;
    default:
      return SortOrder.number;
  }
}

