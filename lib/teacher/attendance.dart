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
                  AsistenciaCard(titulo: 'Mixtas', clase: 'Mixtas'),
                  AsistenciaCard(titulo: 'Boxeo', clase: 'boxeo'),
                  AsistenciaCard(titulo: 'Parkour', clase: 'parkour'),
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
  List<Estudiante> estudiantes = [];
  bool isLoading = true;
  TextEditingController fechaController = TextEditingController();
  String? fecha; // Almacena la fecha
  int? idClase; // Almacena el id_clase

  @override
  void initState() {
    super.initState();
    fetchAsistencia(); // Llama al método sin pasar la clase
  }

  Future<void> fetchAsistencia({String? fecha}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String baseUrl = 'http://192.168.27.228:4000/api/obtenerAsistencias';
      Map<String, String> queryParams = {
        'clase': widget.clase, // Incluyendo la clase en la solicitud
      };

      String queryString = Uri(queryParameters: queryParams).query;
      String url = '$baseUrl?$queryString';

      print('URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Filtrar las asistencias por clase
        List<dynamic> asistenciaClase = jsonData
            .where((element) => element['nombre_clase'] == widget.clase)
            .toList();

        // Filtrar la asistencia de acuerdo con la fecha seleccionada
        if (fecha != null && fecha.isNotEmpty) {
          asistenciaClase = asistenciaClase.where((asistencia) {
            DateTime parsedDate =
                DateTime.parse(asistencia['fecha_asistencia']);
            String formattedDate =
                '${parsedDate.toIso8601String().split('T')[0]}'; // Solo fecha (YYYY-MM-DD)
            return formattedDate == fecha; // Comparar solo la parte de la fecha
          }).toList();
        }

        List<Estudiante> allEstudiantes = [];

        if (asistenciaClase.isNotEmpty) {
          for (var asistencia in asistenciaClase) {
            final List<dynamic> data = asistencia['estudiantes'];
            allEstudiantes.addAll(data
                .map(
                    (json) => Estudiante.fromJson(json, asistencia['id_clase']))
                .toList());
            this.fecha = asistencia[
                'fecha_asistencia']; // Extraer la fecha de asistencia
            this.idClase = asistencia[
                'id_clase']; // Almacena el id_clase desde el objeto de asistencia
          }
        }

        setState(() {
          estudiantes = allEstudiantes;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load asistencias: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        estudiantes = [];
        isLoading = false;
      });
    }
  }

  void handleCheckboxChange(int idUsuario, bool newValue) {
    setState(() {
      for (var estudiante in estudiantes) {
        if (estudiante.idUsuario == idUsuario) {
          estudiante.presente = newValue ? 'sí' : 'no';
          break;
        }
      }
    });
  }

  Future<void> updateAsistencia(List<Estudiante> estudiantes) async {
    if (estudiantes.isEmpty)
      return; // Asegúrate de que hay estudiantes antes de continuar

    int idAsistencia = estudiantes[0]
        .idAsistencia; // Usa el idAsistencia del primer estudiante

    try {
      String baseUrl =
          'http://192.168.27.228:4000/api/actualizarasis/$idAsistencia';

      // Verifica que la fecha no sea nula
      if (fecha == null || fecha!.isEmpty) {
        print('Error: fecha no está definida.');
        return; // Salir si la fecha no está definida
      }

      // Usa el id_clase almacenado desde el objeto de asistencia
      if (idClase == null) {
        print('Error: id_clase no está definida.');
        return; // Salir si el id_clase no está definido
      }

      // Convertir la fecha a DateTime y formatear
      DateTime fechaDateTime = DateTime.parse(
          fecha!); // Asumiendo que `fecha` está en formato 'YYYY-MM-DD'
      String formattedFecha =
          '${fechaDateTime.toIso8601String().split('.')[0]}:00'; // Convierte a ISO 8601 y agrega ':00'

      // Mapeo de estudiantes: convertir presente a 1 (sí) o 0 (no)
      final List<Map<String, dynamic>> updates = estudiantes
          .map((e) => {
                'id_usuario': e.idUsuario,
                'presente': e.presente == 'sí'
                    ? 1
                    : 0, // Convertir 'sí' a 1 y cualquier otra cosa a 0
              })
          .toList();

      // Debugging: imprimir los datos que se enviarán
      print('Datos a enviar:');
      print({
        'estudiantes': updates,
        'fecha_asistencia': formattedFecha, // Envía la fecha formateada
        'id_clase': idClase, // Envía id_clase
      });

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'estudiantes': updates,
          'fecha_asistencia': formattedFecha, // Envía la fecha formateada
          'id_clase': idClase, // Envía id_clase
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Las asistencias se han actualizado correctamente.'),
            duration: Duration(seconds: 2), // Duración de la SnackBar
          ),
        );
      } else {
        print('Failed to update asistencia: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update asistencia: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
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
                          fetchAsistencia(fecha: fecha);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: estudiantes.isEmpty
                      ? const Center(
                          child: Text('Asistencia no encontrada'),
                        )
                      : ListView.builder(
                          itemCount: estudiantes.length,
                          itemBuilder: (context, index) {
                            final estudiante = estudiantes[index];
                            return Card(
                              child: ListTile(
                                title: Text(estudiante.nombreUsuario),
                                trailing: Checkbox(
                                  value: estudiante.presente == 'sí',
                                  onChanged: (newValue) {
                                    handleCheckboxChange(
                                        estudiante.idUsuario, newValue!);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateAsistencia(estudiantes);
                  },
                  child: const Text('Actualizar Asistencia'),
                ),
              ],
            ),
    );
  }
}

class Estudiante {
  final int idUsuario;
  final String nombreUsuario;
  String presente;
  final int idAsistencia;

  Estudiante({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.presente,
    required this.idAsistencia,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json, int idClase) {
    return Estudiante(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      presente: json['presente'] ?? 'no', // Por defecto a 'no'
      idAsistencia: json['id_asistencia'],
    );
  }
}
