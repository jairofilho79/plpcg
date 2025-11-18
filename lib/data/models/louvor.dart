import 'package:freezed_annotation/freezed_annotation.dart';

part 'louvor.freezed.dart';
part 'louvor.g.dart';

/// Modelo de dados para um Louvor
@freezed
class Louvor with _$Louvor {
  const factory Louvor({
    required String nome,
    required String classificacao,
    required String numero,
    required String categoria,
    required String pdf,
    required String pdfId,
  }) = _Louvor;

  factory Louvor.fromJson(Map<String, dynamic> json) => _$LouvorFromJson(json);
}

