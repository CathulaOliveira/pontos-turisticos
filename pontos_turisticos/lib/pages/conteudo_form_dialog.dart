import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pontos_turisticos/model/ponto_turistico.dart';

class ConteudoFormDialog extends StatefulWidget {

  final PontoTuristico? pontoTuristico;

  ConteudoFormDialog({Key? key, this.pontoTuristico}) : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final detalhesController = TextEditingController();
  final dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.pontoTuristico != null) {
      descricaoController.text = widget.pontoTuristico!.descricao;
      detalhesController.text = widget.pontoTuristico!.detalhes;
      dataController.text = widget.pontoTuristico!.dataFormatado;
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
        ],
      ),
    );
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
    id: widget.pontoTuristico?.id ?? 0,
    descricao: descricaoController.text,
    data: dataController.text.isEmpty ? null : _dateFormat.parse(dataController.text),
    detalhes: detalhesController.text,
  );
}