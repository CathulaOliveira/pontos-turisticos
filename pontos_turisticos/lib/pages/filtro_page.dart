import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pontos_turisticos/model/ponto_turistico.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiltroPage extends StatefulWidget {

  static const ROUTE_NAME = '/filtro';
  static const CHAVE_CAMPO_ORDENACAO = 'campoOrdenacao';
  static const CHAVE_USAR_ORDEM_DECERSCENTE = 'usarOrdemDecrescente';
  static const CHAVE_FILTRO_NOME = 'filtroNome';
  static const CHAVE_FILTRO_DETALHE = 'filtroDetalhe';
  static const CHAVE_FILTRO_DATA = 'filtroData';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {

  final _camposParaOrdenacao = {
    PontoTuristico.CAMPO_ID: 'Código',
    PontoTuristico.CAMPO_NOME: 'Nome',
    PontoTuristico.CAMPO_DATA: 'Data'
  };

  late final SharedPreferences pref;

  final nomeController = TextEditingController();
  final detalheController = TextEditingController();
  final dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  String campoOrdenacao = PontoTuristico.CAMPO_ID;
  bool usarOrdemDecrescente = false;
  bool _alterouValores = false;


  @override
  void initState() {
    super.initState();
    _carregarSharedPreferences();
    dataController.addListener(() {
      _onFiltroDataChange();
    });
  }

  Widget build (BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: Text('Filtro e Ordenação')),
        body: _criarBody(),
      ),
      onWillPop: _onClickVoltar,
    );
  }

  Widget _criarBody() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text('Campo para ordenação'),
        ),
        for (final campo in _camposParaOrdenacao.keys)
          Row(
            children: [
              Radio(
                value: campo,
                groupValue: campoOrdenacao,
                onChanged: _onCampoOrdenacaoChange,
              ),
              Text(_camposParaOrdenacao[campo] ?? ''),
            ],
          ),
        Divider(),
        Row(
          children: [
            Checkbox(
              value: usarOrdemDecrescente,
              onChanged: _onUsarOrdemDecrescenteChange,
            ),
            Text('Usar ordem decrescente')
          ],
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(labelText: 'Nome começa com:'),
            controller: nomeController,
            onChanged: _onFiltroNomeChange,
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(labelText: 'Detalhe contem:'),
            controller: detalheController,
            onChanged: _onFiltroDetalheChange,
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Data de inclusão',
              prefixIcon: IconButton(
                onPressed: _mostraCalendario,
                icon: Icon(Icons.calendar_today),
              ),
              suffixIcon: IconButton(
                onPressed: () => dataController.clear(),
                icon: Icon(Icons.close),
              ),
            ),
            controller: dataController,
          ),
        ),
      ],
    );
  }

  Future<bool> _onClickVoltar() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }

  void _carregarSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    pref = prefs;
    setState(() {
      campoOrdenacao = pref.getString(FiltroPage.CHAVE_CAMPO_ORDENACAO) ?? PontoTuristico.CAMPO_ID;
      usarOrdemDecrescente = pref.getBool(FiltroPage.CHAVE_USAR_ORDEM_DECERSCENTE) ?? false;
      nomeController.text = pref.getString(FiltroPage.CHAVE_FILTRO_NOME) ?? '';
      detalheController.text = pref.getString(FiltroPage.CHAVE_FILTRO_DETALHE) ?? '';
      dataController.text = pref.getString(FiltroPage.CHAVE_FILTRO_DATA) ?? '';
    });
  }

  void _mostraCalendario() {
    final dataFormatada = dataController.text;
    var data = DateTime.now();
    if (dataFormatada.isNotEmpty) {
      data = _dateFormat.parse(dataFormatada);
    }
    showDatePicker(
      context: context,
      initialDate: data,
      firstDate: data.subtract(Duration(days: 365*5)),
      lastDate: data.add(Duration(days: 365*5)),
    ).then((DateTime? dataSelecionda) {
      if (dataSelecionda != null) {
        setState(() {
          dataController.text = _dateFormat.format(dataSelecionda);
        });
      }
    },
    );
  }

  void _onCampoOrdenacaoChange(String? valor) {
    pref.setString(FiltroPage.CHAVE_CAMPO_ORDENACAO, valor ?? '');
    _alterouValores = true;
    setState(() {
      campoOrdenacao = valor ?? '';
    });
  }

  void _onUsarOrdemDecrescenteChange(bool? valor) {
    pref.setBool(FiltroPage.CHAVE_USAR_ORDEM_DECERSCENTE, valor == true);
    _alterouValores = true;
    setState(() {
      usarOrdemDecrescente = valor == true;
    });
  }

  void _onFiltroNomeChange(String? valor) {
    pref.setString(FiltroPage.CHAVE_FILTRO_NOME, valor ?? '');
    _alterouValores = true;
  }


  void _onFiltroDetalheChange(String? valor) {
    pref.setString(FiltroPage.CHAVE_FILTRO_DETALHE, valor ?? '');
    _alterouValores = true;
  }

  void _onFiltroDataChange() {
    pref.setString(FiltroPage.CHAVE_FILTRO_DATA, dataController.text ?? '');
    _alterouValores = true;
  }
}