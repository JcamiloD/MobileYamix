import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../static/mydrawe.dart';

import 'edit_news.dart'; // Importa tu pantalla de edición

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _eventos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEventos();
  }

  Future<void> fetchEventos() async {
    final response = await http
        .get(Uri.parse('https://fullrestapi.onrender.com/eventos'));

    if (response.statusCode == 200) {
      try {
        final responseBody = response.body; // Print the response for debugging
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        final List<dynamic> data =
            jsonResponse['eventos']; // Adjust to the correct structure
        setState(() {
          _eventos = data;
          _isLoading = false;
        });
      } catch (e) {
        print("Error al convertir data: $e"); // Print the error for debugging
        setState(() {
          _errorMessage = 'Error al convertir  data';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Error al cargar eventos';
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteEvento(String id) async {
    final url = Uri.parse('https://fullrestapi.onrender.com/eventos/$id');

    try {
      final response = await http.delete(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _eventos.removeWhere((evento) => evento['id_evento'] == id);
        });
        _refreshScreen(); // Llamamos al método para refrescar la pantalla
      } else {
        _showErrorDialog(
            'No se pudo eliminar el evento: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error al intentar eliminar el evento: $e');
    }
  }

void _refreshScreen() {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  fetchEventos(); 
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffB81736),
                Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Eventos'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : ListView.builder(
                    itemCount: _eventos.length,
                    itemBuilder: (context, index) {
                      final evento = _eventos[index];
                      return EventoCard(
                        key: Key(evento['id_evento']
                            .toString()), // Usar una clave única
                        evento: evento,
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text(
                                    '¿Estás seguro de que quieres eliminar este evento?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Eliminar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      deleteEvento(
                                          evento['id_evento'].toString());
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class EventoCard extends StatelessWidget {
  final Map<String, dynamic> evento;
  final VoidCallback onDelete;

  const EventoCard({
    Key? key,
    required this.evento,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String nombreEvento = evento['nombre_evento'];
    final String descripcion = evento['descripcion'];
    final String tipoEvento = evento['tipo_evento'];
    final String ubicacion = evento['ubicacion'];
    final String fechaHoraInicio = evento['fecha_hora_inicio'].toString();
    final String fechaHoraFinal = evento['fecha_hora_final'].toString();

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.calendar),
            title: Text(nombreEvento),
            subtitle: Text(
                'Descripción: $descripcion\nTipo: $tipoEvento\nUbicación: $ubicacion\nInicio: $fechaHoraInicio\nFinal: $fechaHoraFinal'),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarEventoScreen(
                        evento: evento,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
