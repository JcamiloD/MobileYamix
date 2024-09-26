import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Importar la biblioteca intl

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
  bool isLoading = true;
  String? selectedClassId;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada

  // Mapa de clases a sus IDs
  final Map<String, String> classIds = {
    'Parkour': '1', // Cambia por los IDs correctos
    'Mixtas': '2',
    'Boxeo': '3',
  };

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    setState(() {
      selectedClassId = classIds['Parkour']; // Seleccionamos por defecto una clase
    });
    await fetchStudents(selectedClassId!);
  }

  Future<void> fetchStudents(String classId) async {
    final response = await http.get(Uri.parse('http://192.168.27.228:4000/api/claseEstudiante/$classId'));

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
      throw Exception('Failed to load students');
    }
  }

  Future<void> saveAttendance() async {
  final String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  // Verificar que hay estudiantes
  if (students.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No hay estudiantes para guardar la asistencia.')),
    );
    return; // Salir si no hay datos
  }

  // Estructurar los datos que se necesitan
  final Map<String, dynamic> data = {
    'id_clase': selectedClassId, // ID de la clase seleccionada
    'fecha_asistencia': formattedDate, // Fecha seleccionada
    'estudiantes': students.map((student) {
      return {
        'id_usuario': student.id,
        'presente': student.present ? 1 : 0, // Solo envía id y estado de asistencia
      };
    }).toList(),
  };

  final response = await http.post(
    Uri.parse('http://192.168.27.228:4000/api/createAsistencia'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data), // Enviar solo los datos necesarios
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Asistencia guardada correctamente')),
    );
  } else {
    print('Response body: ${response.body}'); // Para depuración
    throw Exception('Failed to save attendance');
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
        selectedDate = picked; // Actualizar la fecha seleccionada
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
        backgroundColor: Color(0xffB81736), // Rojo oscuro personalizado
        elevation: 0, // Sin sombra
      ),
      drawer: MyDrawer(), // Suponiendo que MyDrawer es un widget personalizado de cajón
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DropdownButton<String>(
                  value: classIds.keys.firstWhere((k) => classIds[k] == selectedClassId),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClassId = classIds[newValue!]; // Actualiza el ID seleccionado
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
                  title: Text("Fecha de Asistencia: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"), // Formato de fecha
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context), // Muestra el selector de fecha
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
                              student.present = value!; // Actualiza el estado de presencia
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
