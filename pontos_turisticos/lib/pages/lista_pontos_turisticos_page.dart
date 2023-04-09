import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pontos_turisticos/dao/ponto_turistico_dao.dart';
import 'package:pontos_turisticos/pages/conteudo_form_dialog.dart';
import 'package:pontos_turisticos/pages/datalhes_ponto_turistico_page.dart';
import 'package:pontos_turisticos/pages/filtro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ponto_turistico.dart';

class ListaPontosTuristicosPage extends StatefulWidget {

  @override
  _ListaPontosTuristicosPageState createState() => _ListaPontosTuristicosPageState();
}

class _ListaPontosTuristicosPageState extends State<ListaPontosTuristicosPage> {

  static const ACAO_EDITAR = 'Editar';
  static const ACAO_EXCLUIR = 'Excluir';
  static const ACAO_VISUALIZAR = 'visualizar';

  final pontosTuristicos = <PontoTuristico>[];
  final _dao = PontoTuristicoDao();
  var carregando = false;

  @override
  void initState() {
    super.initState();
    _atualizaDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Novo Ponto Turístico',
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: Text('Pontos Turísticos'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro,
            icon: Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody() {
    if (carregando) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Carregando os pontos turísticos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      );
    }
    if (pontosTuristicos.isEmpty) {
      return const Center(
        child: Text('Nenhum item cadastrado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        final pontoTuristico = pontosTuristicos[index];

        return PopupMenuButton<String>(
          child: ListTile(
            title: Text('${pontoTuristico.id} - ${pontoTuristico.nome}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(pontoTuristico: pontoTuristico);
            }
            if (valorSelecionado == ACAO_VISUALIZAR) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DetalhesPontoTuristicoPage(pontoTuristico: pontoTuristico),
              ));
            }
            if (valorSelecionado == ACAO_EXCLUIR) {
              _excluir(pontoTuristico);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: pontosTuristicos.length,
    );
  }

  void _abrirPaginaFiltro() {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.ROUTE_NAME).then((alterouValores) {
      if (alterouValores == true) {
        _atualizaDados();
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup() {
    return [
      PopupMenuItem<String>(
          value: ACAO_EDITAR,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Editar'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Excluir'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_VISUALIZAR,
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Visualizar'),
              )
            ],
          )
      )
    ];
  }

  void _atualizaDados() async {
    setState(() {
      carregando = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao = prefs.getString(FiltroPage.CHAVE_CAMPO_ORDENACAO) ?? PontoTuristico.CAMPO_ID;
    final usarOrdemDecrescente = prefs.getBool(FiltroPage.CHAVE_USAR_ORDEM_DECERSCENTE) == true;
    final filtroNome = prefs.getString(FiltroPage.CHAVE_FILTRO_NOME) ?? '';
    final filtroDetalhe = prefs.getString(FiltroPage.CHAVE_FILTRO_DETALHE) ?? '';
    final filtroData = prefs.getString(FiltroPage.CHAVE_FILTRO_DATA) ?? '';
    final pontosTuristicosListar = await _dao.listar(
        filtroNome: filtroNome,
        filtroDetalhe: filtroDetalhe,
        filtroData: filtroData,
        usarOrdemDecrescente: usarOrdemDecrescente,
        campoOrdenacao: campoOrdenacao
    );
    setState(() {
      pontosTuristicos.clear();
      if (pontosTuristicosListar.isNotEmpty) {
        pontosTuristicos.addAll(pontosTuristicosListar);
      }
    });
    setState(() {
      carregando = false;
    });
  }

  void _abrirForm({PontoTuristico? pontoTuristico}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
              pontoTuristico != null ? 'Alterar Ponto Turístico ${pontoTuristico.id}' : 'Novo Ponto Turístico'
          ),
          content: ConteudoFormDialog(key: key, pontoTuristico: pontoTuristico),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancelar")
            ),
            TextButton(
                onPressed: () {
                  if (key.currentState?.dadosValidados() != true) {
                    return;
                  }
                  Navigator.of(context).pop();
                  final novoPontoTuristico = key.currentState!.pontoTuristico;
                  _dao.salvar(novoPontoTuristico).then((success) {
                    if (success) {
                      _atualizaDados();
                    }
                  });
                  _atualizaDados();
                },
                child: Text("Salvar")
            ),
          ],
        ),
    );
  }

  void _excluir(PontoTuristico pontoTuristico) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('ATENÇÃO'),
                ),
              ],
            ),
            content: Text('Este registro será deletado definitivamente'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (pontoTuristico.id == null) {
                    return;
                  }
                  _dao.excluir(pontoTuristico.id!).then((value) {
                    if (value) {
                      _atualizaDados();
                    }
                  });
                },
                child: Text('Ok'),
              ),
            ],
          );
        }
    );
  }
}