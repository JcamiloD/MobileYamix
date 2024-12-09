import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../static/mydrawe.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<User> students = [];
  Map<String, String> classIds = {}; // Clases cargadas dinámicamente
  bool isLoading = true;
  String? selectedClassId;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      // Obtener el token de SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) {
        throw Exception('Token no encontrado');
      }

      // Decodificar el token
      String decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1])));
      Map<String, dynamic> payload = jsonDecode(decodedPayload);

      if (!payload.containsKey('id')) {
        throw Exception('id_usuario no encontrado en el token');
      }

      String userId = payload['id'].toString();

      // Realizar la petición HTTP
      final response = await http.get(Uri.parse('http://35.199.176.100/api/clasePorUsuario/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> classes = json.decode(response.body);
        setState(() {
          classIds = {
            for (var cls in classes) cls['nombre_curso']: cls['id_clase'].toString(),
          };
          selectedClassId = classIds.isNotEmpty ? classIds.values.first : null;
        });

        if (selectedClassId != null) {
          fetchStudents(selectedClassId!);
        }
      } else {
        throw Exception('Error al cargar las clases');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar las clases: $e');
    }
  }

Future<void> fetchStudents(String? classId) async {
  if (classId == null) {
    // Manejar el caso en que no se ha seleccionado una clase
    setState(() {
      students = [];
      isLoading = false;
    });
    print("Error: No se ha seleccionado una clase.");
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final response = await http.get(Uri.parse('http://35.199.176.100/api/claseEstudiante/$classId?fecha_asistencia=${selectedDate}'));
    print("Estado de la respuesta: ${response.statusCode}");
    print("Cuerpo de la respuesta: ${response.body}");
    if (response.statusCode == 200) {
  final List<dynamic> userData = json.decode(response.body);
  setState(() {
    students = userData.map((json) => User.fromJson(json)).toList();
    isLoading = false;
  });
} else {
  throw Exception('Error al cargar los estudiantes');
}

  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error al cargar los estudiantes: $e');
  }
}


  Future<void> saveAttendance() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay estudiantes para guardar la asistencia.')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'id_clase': selectedClassId,
      'fecha_asistencia': formattedDate,
      'estudiantes': students.map((student) {
        return {
          'id_usuario': student.id,
          'presente': student.present ? 1 : 0,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://35.199.176.100/api/crear_asistencia'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia guardada correctamente')),
        );
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String errorMessage = responseData['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al comunicarse con el servidor: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      if (selectedClassId != null) {
        fetchStudents(selectedClassId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia'),
        actions: [
          TextButton(
            onPressed: () {
              if (students.isNotEmpty) {
                saveAttendance();
              }
            },
            child: Text(
              'Agregar Asistencia',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        backgroundColor: Color(0xffB81736),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (classIds.isNotEmpty)
                  DropdownButton<String>(
                    value: classIds.keys.firstWhere((k) => classIds[k] == selectedClassId, orElse: () => ''),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedClassId = classIds[newValue!];
                        fetchStudents(selectedClassId!);
                      });
                    },
                    items: classIds.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ListTile(
                  title: Text("Fecha de Asistencia: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text('${student.nombre} ${student.apellido}'),
                        subtitle: Text('Clase: ${student.clase.isNotEmpty ? student.clase : "Clase no asignada"}'),
                        trailing: Checkbox(
                          value: student.present,
                          onChanged: (bool? value) {
                            setState(() {
                              student.present = value!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class User {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String clase;
  bool present;

  User({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.clase,
    this.present = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'] ?? 0, // Manejo de nulos
      nombre: json['nombre'] ?? 'Sin nombre', // Valor predeterminado
      apellido: json['apellido'] ?? 'Sin apellido',
      correo: json['correo'] ?? 'Sin correo',
      clase: json['clase'] ?? 'Sin clase',
    );
  }
}
