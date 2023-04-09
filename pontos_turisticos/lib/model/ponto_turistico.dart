import 'package:intl/intl.dart';

class PontoTuristico {

  static const CAMPO_ID = 'id';
  static const CAMPO_NOME = 'nome';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DATA = 'data';

  int id;
  String nome;
  String descricao;
  String detalhes;
  DateTime? data;

  PontoTuristico({required this.id, required this.nome, required this.descricao, this.data, required this.detalhes});

  String get dataFormatado {
    if (data == null) {
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(data!);
  }

}