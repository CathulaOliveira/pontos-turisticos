import 'package:intl/intl.dart';

class PontoTuristico {

  static const CAMPO_ID = 'id';
  static const CAMPO_NOME = 'nome';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DATA = 'data';
  static const CAMPO_DETALHES = 'detalhes';
  static const CAMPO_LATITUDE = 'latitude';
  static const CAMPO_LONGITUDE = 'longitude';
  static const NOME_TABLE = 'ponto_turistico';

  int? id;
  String nome;
  String descricao;
  String detalhes;
  DateTime? data;
  double? latitude;
  double? longitude;

  PontoTuristico({
    this.id,
    required this.nome,
    required this.descricao,
    this.data,
    required this.detalhes,
    this.latitude,
    this.longitude
  });

  String get dataFormatado {
    if (data == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(data!);
  }

  Map<String, dynamic> toMap() => {
    CAMPO_ID: id,
    CAMPO_NOME: nome,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DATA: data == null ? null : DateFormat("dd/MM/yyyy").format(data!),
    CAMPO_DETALHES: detalhes,
    CAMPO_LATITUDE: latitude,
    CAMPO_LONGITUDE: longitude
  };

  factory PontoTuristico.fromMap(Map<String, dynamic> map) => PontoTuristico(
      id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
      nome: map[CAMPO_NOME] is String ? map[CAMPO_NOME] : '',
      descricao: map[CAMPO_DESCRICAO] is String ? map[CAMPO_DESCRICAO] : '',
      data: map[CAMPO_DATA] == null ? null : DateFormat('dd/MM/yyyy').parse(map[CAMPO_DATA]),
      detalhes: map[CAMPO_DETALHES] is String ? map[CAMPO_DETALHES] : '',
      latitude: map[CAMPO_LATITUDE] is double ? map[CAMPO_LATITUDE] : null,
      longitude: map[CAMPO_LONGITUDE] is double ? map[CAMPO_LONGITUDE] : null,
  );

}