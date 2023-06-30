import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PesquisaScreen extends StatefulWidget {
  @override
  _PesquisaScreenState createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  late TextEditingController _controller;
  late LatLng _selectedLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pesquisarPontoTuristico(String endereco) async {
    List<Location> locations = await locationFromAddress(endereco);

    if (locations.isNotEmpty) {
      double latitude = locations.first.latitude;
      double longitude = locations.first.longitude;

      setState(() {
        _selectedLocation = LatLng(latitude, longitude);
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ponto Turístico não encontrado'),
          content: Text('O ponto turístico pesquisado não foi encontrado.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _selecionarLocalizacao() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar Ponto Turístico'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Nome do Ponto Turístico',
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-23.550520, -46.633308),
                zoom: 14.0,
              ),
              onTap: (LatLng position) {
                setState(() {
                  _selectedLocation = position;
                });
              },
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _pesquisarPontoTuristico(_controller.text),
            child: Text('Pesquisar'),
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Latitude: ${_selectedLocation.latitude}\nLongitude: ${_selectedLocation.longitude}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ElevatedButton(
            onPressed: () => _selecionarLocalizacao(),
            child: Text('Usar localização'),
          ),
        ],
      ),
    );
  }
}