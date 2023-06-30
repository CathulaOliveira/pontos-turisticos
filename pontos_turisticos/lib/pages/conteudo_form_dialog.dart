import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pontos_turisticos/model/ponto_turistico.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:pontos_turisticos/pages/pesquisa_screen.dart';

class ConteudoFormDialog extends StatefulWidget {

  final PontoTuristico? pontoTuristico;

  ConteudoFormDialog({Key? key, this.pontoTuristico}) : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final detalhesController = TextEditingController();
  final dataController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.pontoTuristico != null) {
      nomeController.text = widget.pontoTuristico!.nome;
      descricaoController.text = widget.pontoTuristico!.descricao;
      detalhesController.text = widget.pontoTuristico!.detalhes;
      dataController.text = widget.pontoTuristico!.dataFormatado;
      latitudeController.text = widget.pontoTuristico!.latitude.toString();
      longitudeController.text = widget.pontoTuristico!.longitude.toString();
    } else {
      dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nomeController,
            decoration: InputDecoration(labelText: 'Nome'),
            validator: (String? valor){
              if (valor == null || valor.isEmpty) {
                return 'Informe o nome';
              }
              return null;
            },
          ),
          TextFormField(
            controller: descricaoController,
            decoration: InputDecoration(labelText: 'Descrição'),
            validator: (String? valor){
              if (valor == null || valor.isEmpty) {
                return 'Informe a descrição';
              }
              return null;
            },
          ),
          TextFormField(
            controller: detalhesController,
            decoration: InputDecoration(labelText: 'Detalhes'),
            validator: (String? valor){
              if (valor == null || valor.isEmpty) {
                return 'Informe as detalhes';
              }
              return null;
            },
          ),
          TextFormField(
            controller: dataController,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Data',
              prefixIcon: IconButton(
                onPressed: _mostraCalendario,
                icon: Icon(Icons.calendar_today),
              ),
              suffixIcon: IconButton(
                onPressed: () => dataController.clear(),
                icon: Icon(Icons.close),
              ),
            ),
            readOnly: true,
          ),
          TextButton(
              onPressed: _obterLocalizacaoAtual,
              child: Text('Verificar localização atual')
          ),
          TextButton(
              onPressed: _abrirPesquisa,
              child: Text('Informar localização')
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Latitude: ${latitudeController.text}\nLongitude: ${longitudeController.text}',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    latitudeController.text = position.latitude.toString();
    longitudeController.text = position.longitude.toString();
    abrirLocalizacaoNoMapa(position.latitude, position.longitude);
  }

  void abrirLocalizacaoNoMapa(double latitude, double longitude) {
    MapsLauncher.launchCoordinates(latitude, longitude);
  }

  void _abrirPesquisa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PesquisaScreen(),
      ),
    ).then((selectedLocation) {
      if (selectedLocation != null) {
        latitudeController.text = selectedLocation.latitude.toString();
        longitudeController.text = selectedLocation.longitude.toString();
      }
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

  bool dadosValidados() => formKey.currentState!.validate() == true;

  PontoTuristico get pontoTuristico => PontoTuristico(
    id: widget.pontoTuristico?.id,
    nome: nomeController.text,
    descricao: descricaoController.text,
    data: dataController.text.isEmpty ? null : _dateFormat.parse(dataController.text),
    detalhes: detalhesController.text,
    latitude: double.parse(latitudeController.text),
    longitude: double.parse(longitudeController.text),
  );

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

}