import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../static/mydrawe.dart';
import 'package:intl/intl.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({Key? key}) : super(key: key);

  @override
  _AsistenciaScreenState createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  List<dynamic> asistencias = [];
  String? selectedClase;
  DateTime? selectedDate;
  bool isLoading = true;
  dynamic selectedAsistencia;
  Map<int, bool> asistenciaEstudiantes =
      {}; // Almacena la asistencia de cada estudiante
  Map<int, bool> tempAsistenciaEstudiantes =
      {}; // Almacena los valores originales antes de editar

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
  }

  Future<void> fetchAsistencias() async {
    setState(() {
      isLoading = true;
    });

    int? userId;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) {
        throw Exception('Token no encontrado');
      }

      String decodedPayload = utf8
          .decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))); 
      Map<String, dynamic> payload = jsonDecode(decodedPayload);
      if (!payload.containsKey('id')) {
        throw Exception('id_usuario no encontrado en el token');
      }
      userId = payload['id'];

      if (userId == null) {
        throw Exception('User ID no disponible');
      }

      final response = await http.get(
        Uri.parse('http://35.199.176.100/api/traerAsistenciaProfe/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          asistencias = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error al traer asistencias: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> actualizarAsistencia(int idEstudiante, int presente) async {
    if (selectedAsistencia == null) {
      print('selectedAsistencia es null');
      return;
    }

    final response = await http.put(
      Uri.parse(
          'http://35.199.176.100/api/actualizar_asistencia_estudiantes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_asistencia': selectedAsistencia['id_asistencia'],
        'id_estudiante': idEstudiante,
        'presente': presente,
      }),
    );

    if (response.statusCode == 200) {
      fetchAsistencias(); 
    } else {
      print('Error al actualizar asistencia: ${response.statusCode}');
    }
  }

  Future<void> guardarAsistencia() async {
    if (selectedAsistencia == null) {
      print('selectedAsistencia es null');
      return;
    }

    List<Map<String, dynamic>> asistenciaUpdates = [];
    for (var idEstudiante in asistenciaEstudiantes.keys) {
      int presente = asistenciaEstudiantes[idEstudiante]!
          ? 1
          : 0; 
      asistenciaUpdates.add({
        'id_usuario': idEstudiante.toString(),
        'presente': presente,
      });
    }

    final response = await http.put(
      Uri.parse(
          'http://35.199.176.100/api/actualizar_asistencia_estudiantes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_asistencia': selectedAsistencia['id_asistencia'],
        'cambios': asistenciaUpdates,
      }),
    );

    if (response.statusCode == 200) {
       ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Asistencia guardada correctamente')),
  );
      fetchAsistencias();
      
    } else {
      print('Error al guardar asistencia: ${response.statusCode}');
    }
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void limpiarFiltros() {
    setState(() {
      selectedClase = null;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredAsistencias = asistencias.where((asistencia) {
      if (selectedDate == null) return true;

      DateTime asistenciaDate =
          DateFormat('yyyy-MM-dd').parse(asistencia['fecha_asistencia']);
      return selectedDate!.isAtSameMomentAs(asistenciaDate);
    }).toList();

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
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => seleccionarFecha(context),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: limpiarFiltros,
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredAsistencias.length,
                      itemBuilder: (context, index) {
                        var asistencia = filteredAsistencias[index];
                        String formattedDate =
                            DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(asistencia['fecha_asistencia']));

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                                '${asistencia['nombre_curso']} - $formattedDate'),
                            subtitle: Text(
                                'Instructor: ${asistencia['nombre_instructor']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  selectedAsistencia =
                                      asistencia; 
                                  asistenciaEstudiantes.clear(); 
                                  for (var estudiante
                                      in asistencia['estudiantes']) {
                                    asistenciaEstudiantes[estudiante['id_usuario']] =
                                        estudiante['presente'] == 'sí';
                                  }
                                });

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Detalles de Asistencia"),
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return Column(
                                          children: [
                                            Text(
                                                'Curso: ${asistencia['nombre_curso']}'),
                                            Text(
                                                'Instructor: ${asistencia['nombre_instructor']}'),
                                            ...asistencia['estudiantes']
                                                .map<Widget>((estudiante) {
                                              return CheckboxListTile(
                                                title: Text(estudiante[
                                                    'nombre_usuario']),
                                                value: asistenciaEstudiantes[estudiante['id_usuario']] ?? false,
                                                onChanged: (value) {
                                                  setState(() {
                                                    asistenciaEstudiantes[
                                                            estudiante['id_usuario']] =
                                                        value ?? false;
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ],
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          guardarAsistencia();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Guardar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
