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
  List<Map<String, dynamic>> _eventos = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    final url = Uri.parse('http://192.168.27.228:4000/api/traer_eventos'); // Cambia esto por la URL correcta

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(url);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _eventos = data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No se pudo cargar los eventos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al intentar cargar los eventos: $e';
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
    final url = Uri.parse('http://192.168.27.228:4000/api/eliminar_evento/$id');
    try {
      final response = await http.delete(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _eventos.removeWhere((evento) => evento['id_evento'] == id);
        });
        _fetchEventos();
      } else {
        _showErrorDialog('No se pudo eliminar el evento: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error al intentar eliminar el evento: $e');
    }
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
                      print('Evento en ListView: $evento'); // Mensaje para depurar cada evento
                      return EventoCard(
                        key: Key(evento['id_evento'].toString()),
                        evento: evento,
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text('¿Estás seguro de que quieres eliminar este evento?'),
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
                                      deleteEvento(evento['id_evento'].toString());
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
    final String nombreEvento = evento['nombre_evento'] ?? 'Desconocido';
    final String descripcion = evento['descripcion'] ?? 'No disponible';
    final String tipoEvento = evento['tipo_evento'] ?? 'No disponible';
    final String ubicacion = evento['ubicacion'] ?? 'No disponible';
    final String notificar = evento['notificar'] ?? 'No disponible';
    final String descripcionNotificacion = evento['descripcion_notificacion'] ?? 'No disponible';
    final String fechaHoraInicio = evento['fecha_hora_inicio']?.toString() ?? 'No disponible';
    final String fechaHoraFinal = evento['fecha_hora_final']?.toString() ?? 'No disponible';
    final String duracion = evento['duracion']?.toString() ?? 'No disponible'; // Agregar duración
    final String idClase = evento['id_clase']?.toString() ?? '0'; // Obtener el ID de clase

    // Mapa para convertir el id_clase a su nombre correspondiente
    final Map<String, String> claseMap = {
      '3': 'Boxeo',
      '2': 'Mixtas',
      '1': 'Parkour',
    };

    final String clase = claseMap[idClase] ?? 'No disponible'; // Obtener el nombre de la clase

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.calendar),
            title: Text(nombreEvento),
            subtitle: Text(
                'Descripción: $descripcion\nTipo: $tipoEvento\nUbicación: $ubicacion\nInicio: $fechaHoraInicio\nFinal: $fechaHoraFinal\nDuración: $duracion\nClase: $clase\nNotificar: $notificar\nDescripción Notificación: $descripcionNotificacion'),
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
