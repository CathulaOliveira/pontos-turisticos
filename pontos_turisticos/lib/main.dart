import 'package:flutter/material.dart';
import 'package:pontos_turisticos/pages/filtro_page.dart';
import 'package:pontos_turisticos/pages/lista_pontos_turisticos_page.dart';

void main() {
  runApp(const CadastroApp());
}

class CadastroApp extends StatelessWidget {
  const CadastroApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pontos Turísticos',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: ListaPontosTuristicosPage(),
      routes: {
        FiltroPage.ROUTE_NAME: (BuildContext context) => FiltroPage(),
      },
    );
  }
}
