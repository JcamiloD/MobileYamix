import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../static/mydrawe.dart';

class AsistenciaScreen extends StatelessWidget {
  const AsistenciaScreen({Key? key}) : super(key: key);

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
            title: const Text('Asistencia'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  AsistenciaCard(
                    titulo: 'Mixtas',
                    clase: 'Mixtas',  
                  ),
                  AsistenciaCard(
                    titulo: 'Boxeo',
                    clase: 'Boxeo',
                  ),
                  AsistenciaCard(
                    titulo: 'Parkour',
                    clase: 'Parkour',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AsistenciaCard extends StatelessWidget {
  final String titulo;
  final String clase;

  const AsistenciaCard({
    Key? key,
    required this.titulo,
    required this.clase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleAsistenciaScreen(clase: clase),
            ),
          );
        },
        leading: const FaIcon(FontAwesomeIcons.check),
        title: Text(titulo),
      ),
    );
  }
}

class DetalleAsistenciaScreen extends StatefulWidget {
  final String clase;

  const DetalleAsistenciaScreen({Key? key, required this.clase})
      : super(key: key);

  @override
  _DetalleAsistenciaScreenState createState() =>
      _DetalleAsistenciaScreenState();
}

class _DetalleAsistenciaScreenState extends State<DetalleAsistenciaScreen> {
  List<Asistencia> asistencias = [];
  bool isLoading = true;
  TextEditingController fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAsistencia(widget.clase); // Llama fetchAsistencia con widget.clase
  }

  Future<void> fetchAsistencia(String clase, {String? fecha}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String baseUrl = 'https://fullrestapi.onrender.com/asistenciasC';
      Map<String, String> queryParams = {'clase': clase};
      if (fecha != null && fecha.isNotEmpty) {
        DateTime parsedDate = DateTime.parse(fecha);
        String formattedDate =
            '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
        queryParams['fecha'] = formattedDate;
      }

      String queryString = Uri(queryParameters: queryParams).query;
      String url = '$baseUrl?$queryString';

      print('URL: $url'); // Verifica la URL generada

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('asistencias') &&
            jsonData['asistencias'] != null) {
          final List<dynamic> data = jsonData['asistencias'];

          setState(() {
            asistencias =
                data.map((json) => Asistencia.fromJson(json)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            asistencias = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load asistencias: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        asistencias = [];
        isLoading = false;
      });
    }
  }

  Future<void> updateAsistencia(List<Asistencia> asistencias) async {
    try {
      String baseUrl = 'https://fullrestapi.onrender.com/asistencia';

      final List<Map<String, dynamic>> updates = asistencias.map((a) => {
        'id_usuario': a.idUsuario,
        'estado_asistencia': a.estadoAsistencia,
      }).toList();

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        print('Asistencias actualizadas correctamente');
        // Actualizar estado local después de la respuesta exitosa
        setState(() {
          // No es necesario actualizar localmente porque ya se actualizó al cambiar los checkboxes
        });
      } else {
        print('Failed to update asistencia: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update asistencia: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void handleCheckboxChange(int idUsuario, bool newValue) {
    setState(() {
      final index = asistencias
          .indexWhere((asistencia) => asistencia.idUsuario == idUsuario);
      if (index != -1) {
        asistencias[index].estadoAsistencia = newValue ? 'Presente' : 'Ausente';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clase),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: fechaController,
                    decoration: InputDecoration(
                      labelText: 'Fecha (YYYY-MM-DD)',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          String? fecha = fechaController.text.isNotEmpty
                              ? fechaController.text
                              : null;
                          fetchAsistencia(widget.clase, fecha: fecha);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: asistencias.isEmpty
                      ? const Center(
                          child: Text('Asistencia no encontrada'),
                        )
                      : ListView.builder(
                          itemCount: asistencias.length,
                          itemBuilder: (context, index) {
                            final asistencia = asistencias[index];
                            return CheckboxListTile(
                              key: ValueKey<int>(asistencia.idUsuario),
                              title: Text('${asistencia.nombreUsuario}'),
                              subtitle: Text(
                                  'Fecha: ${asistencia.fechaActual}, Estado: ${asistencia.estadoAsistencia}'),
                              value: asistencia.estadoAsistencia == 'Presente',
                              onChanged: (bool? newValue) {
                                handleCheckboxChange(
                                    asistencia.idUsuario, newValue!);
                              },
                            );
                          },
                        ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Guardar cambios
                    await updateAsistencia(asistencias);
                    // Una vez completadas las actualizaciones, mostrar un mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cambios guardados correctamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Guardar cambios'),
                ),
              ],
            ),
    );
  }
}

class Asistencia {
  final int idUsuario;
  final String nombreUsuario;
  final String clase;
  final String fechaActual;
  String estadoAsistencia;

  Asistencia({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.clase,
    required this.fechaActual,
    required this.estadoAsistencia,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      clase: json['clase'],
      fechaActual: json['fecha_actual'],
      estadoAsistencia: json['estado_asistencia'],
    );
  }
}
