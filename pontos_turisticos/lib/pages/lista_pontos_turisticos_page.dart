import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pontos_turisticos/pages/conteudo_form_dialog.dart';
import 'package:pontos_turisticos/pages/filtro_page.dart';
import '../model/ponto_turistico.dart';

class ListaPontosTuristicosPage extends StatefulWidget {

  @override
  _ListaPontosTuristicosPageState createState() => _ListaPontosTuristicosPageState();
}

class _ListaPontosTuristicosPageState extends State<ListaPontosTuristicosPage> {

  static const ACAO_EDITAR = 'Editar';
  static const ACAO_EXCLUIR = 'Excluir';

  final pontosTuristicos = <PontoTuristico>[];
  int _ultimoId = 0;

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
            title: Text('${pontoTuristico.id} - ${pontoTuristico.descricao}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(pontoTuristicoAtual: pontoTuristico, index: index);
            }
            if (valorSelecionado == ACAO_EXCLUIR) {
              _excluir(index);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: pontosTuristicos.length,
    );
  }

  void _abrirForm({PontoTuristico? pontoTuristicoAtual, int? index}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(pontoTuristicoAtual != null ? 'Alterar Ponto Turístico ${pontoTuristicoAtual.id}' : 'Novo Ponto Turístico'),
            content: ConteudoFormDialog(key: key, pontoTuristico: pontoTuristicoAtual),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar")
              ),
              TextButton(
                  onPressed: () {
                    if (key.currentState != null && key.currentState!.dadosValidados()) {
                      setState(() {
                        final novoPontoTuristico = key.currentState!.pontoTuristico;
                        if (index == null) {
                          novoPontoTuristico.id = ++_ultimoId;
                          pontosTuristicos.add(novoPontoTuristico);
                        } else {
                          pontosTuristicos[index] = novoPontoTuristico;
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Salvar")
              ),
            ],
          );
        }
    );
  }

  void _abrirPaginaFiltro() {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.ROUTE_NAME).then((alterouValores) {
      if (alterouValores == true) {

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
      )
    ];
  }

  void _excluir(int index) {
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
                  setState(() {
                    pontosTuristicos.removeAt(index);
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