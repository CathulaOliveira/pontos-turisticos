import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pontos_turisticos/model/ponto_turistico.dart';


class DetalhesPontoTuristicoPage extends StatefulWidget {
  final PontoTuristico pontoTuristico;

  const DetalhesPontoTuristicoPage({Key? key, required this.pontoTuristico}) : super(key: key);

  @override
  _DetalhesPontoTuristicoPageState createState() => _DetalhesPontoTuristicoPageState();
}

class _DetalhesPontoTuristicoPageState extends State<DetalhesPontoTuristicoPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Ponto Turístico'),
      ) ,
      body: _criaBody() ,
    );
  }

  Widget _criaBody(){
    return Padding(
        padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          Row(
            children: [
              Campo(descricao:'Código: '),
              Valor(valor: '${widget.pontoTuristico.id}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao:'Nome: '),
              Valor(valor: '${widget.pontoTuristico.nome}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao:'Descrição: '),
              Valor(valor: '${widget.pontoTuristico.descricao}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao:'Detalhes: '),
              Valor(valor: '${widget.pontoTuristico.detalhes}'),
            ],
          ),
          Row(
            children: [
              Campo(descricao:'Data: '),
              Valor(valor: '${widget.pontoTuristico.data}'),
            ],
          ),
        ],
      ),
    );
  }
}

class Campo extends StatelessWidget{
  final String descricao;

  const Campo({Key? key,required this.descricao}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return Expanded(
      flex: 1,
        child: Text(descricao,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        ),
    );
  }
}

class Valor extends StatelessWidget{
  final String valor;

  const Valor({Key? key,required this.valor}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return Expanded(
      flex: 4,
      child: Text(valor),
    );
  }
}