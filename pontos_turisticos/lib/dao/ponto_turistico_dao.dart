
import 'package:pontos_turisticos/database/database_provider.dart';
import 'package:pontos_turisticos/model/ponto_turistico.dart';

class PontoTuristicoDao {

  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(PontoTuristico pontoTuristico) async {
    final db = await dbProvider.database;
    final valores = pontoTuristico.toMap();

    if (pontoTuristico.id == null) {
      pontoTuristico.id = await db.insert(PontoTuristico.NOME_TABLE, valores);
      return true;
    } else {
      final registrosAtualizados = await db.update(
          PontoTuristico.NOME_TABLE,
        valores,
        where: '${PontoTuristico.CAMPO_ID} = ?',
        whereArgs: [pontoTuristico.id]
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> excluir(int id) async {
    final db = await dbProvider.database;
    final registrosAtualizados = await db.delete(
        PontoTuristico.NOME_TABLE,
      where: '${PontoTuristico.CAMPO_ID} = ?',
      whereArgs: [id]
    );
    return registrosAtualizados > 0;
  }


  Future<List<PontoTuristico>> listar(
      {String filtro = '',
        String campoOrdenacao = PontoTuristico.CAMPO_ID,
        bool usarOrdemDecrescente = false
      }) async {
    String? where;
    if (filtro.isNotEmpty) {
      where = "UPPER(${PontoTuristico.CAMPO_NOME}) LIKE '${filtro.toUpperCase()}%'";
    }
    var orderBy = campoOrdenacao;
    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final db = await dbProvider.database;
    final resultado = await db.query(
        PontoTuristico.NOME_TABLE,
        columns: [PontoTuristico.CAMPO_ID,
          PontoTuristico.CAMPO_NOME,
          PontoTuristico.CAMPO_DESCRICAO,
          PontoTuristico.CAMPO_DATA,
          PontoTuristico.CAMPO_DETALHES
        ],
      where: where,
      orderBy: orderBy
    );
    return resultado.map((m) => PontoTuristico.fromMap(m)).toList();
  }
}