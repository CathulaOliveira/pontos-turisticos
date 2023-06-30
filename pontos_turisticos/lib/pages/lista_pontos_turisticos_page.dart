import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
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
  var locationServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _permissoesPermitidas();
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

  void abrirLocalizacaoNoMapa(double latitude, double longitude) {
    MapsLauncher.launchCoordinates(latitude, longitude);
  }

  void _obterLocalizacaoAtual(PontoTuristico pontoTuristico) async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      pontoTuristico.latitude = position.latitude;
      pontoTuristico.longitude = position.longitude;
    });
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá habilitar o serviço'
          ' de localização');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recurso '
            'por falta de permissão');
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá acessar '
          'as configurações do app para permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK')
          )
        ],
      ),
    );
  }

  _verificarLocalizacao(PontoTuristico pontoTuristico) async {
    if (pontoTuristico.latitude != null && pontoTuristico.longitude != null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Atenção'),
          content: Text('Verifique se a Localição esta correta'),
          actions: [
            TextButton(
                onPressed: () => abrirLocalizacaoNoMapa(pontoTuristico.latitude!, pontoTuristico.longitude!),
                child: Text('OK')
            )
          ],
        ),
      );
    }

  }
}