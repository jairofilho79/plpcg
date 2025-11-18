/// Extensões úteis para DateTime
extension DateTimeExtensions on DateTime {
  /// Formata data como "dd/MM/yyyy"
  String toFormattedDate() {
    return '${day.toString().padLeft(2, '0')}/'
        '${month.toString().padLeft(2, '0')}/'
        '$year';
  }

  /// Formata data e hora como "dd/MM/yyyy HH:mm"
  String toFormattedDateTime() {
    return '${toFormattedDate()} '
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  /// Verifica se a data é hoje
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica se a data é ontem
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Retorna uma string relativa (hoje, ontem, ou data formatada)
  String toRelativeString() {
    if (isToday) return 'Hoje';
    if (isYesterday) return 'Ontem';
    return toFormattedDate();
  }
}

