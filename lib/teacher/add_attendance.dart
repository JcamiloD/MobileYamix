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

    String userId = payload['id'].toString();  // Extraemos el id_usuario del token

    // Realizar la petición HTTP solo si el token es válido
    final response = await http.get(Uri.parse('http://192.168.1.9:4000/api/clasePorUsuario/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> classes = json.decode(response.body);
      setState(() {
        classIds = {
          for (var cls in classes)
            cls['nombre_curso']: cls['id_clase'].toString(),
        };
        selectedClassId = classIds.isNotEmpty ? classIds.values.first : null;
      });

      if (selectedClassId != null) {
        fetchStudents(selectedClassId!); // Cargar estudiantes para la clase inicial
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


  Future<void> fetchStudents(String classId) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://192.168.1.9:4000/api/claseEstudiante/$classId'));

    if (response.statusCode == 200) {
      final List<dynamic> userData = json.decode(response.body);
      setState(() {
        students = userData.map((json) => User.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Error al cargar los estudiantes');
    }
  }

  Future<void> saveAttendance() async {
  final String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

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
      Uri.parse('http://192.168.1.9:4000/api/crear_asistencia'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asistencia guardada correctamente')),
      );
    } else {
      // Extraer el mensaje de error de la respuesta y mostrarlo
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
  final String gmail;
  final String contrasena;
  final String roll;
  final String clase;
  bool present;

  User({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.gmail,
    required this.contrasena,
    required this.roll,
    required this.clase,
    this.present = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      gmail: json['gmail'] ?? '',
      contrasena: json['contrasena'] ?? '',
      roll: json['roll'] ?? '',
      clase: json['nombre_clase'] ?? '',
    );
  }
}
