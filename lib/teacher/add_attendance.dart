import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<User> parkourStudents = [];
  List<User> boxingStudents = [];
  List<User> mixedStudents = [];
  bool isLoading = true;
  String? selectedClass;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://fullrestapi.onrender.com/users')); // Reemplaza con la IP de tu computadora

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> users = data['data'];
      setState(() {
        parkourStudents = users
            .where((user) => user['roll'] == 'estudiante' && user['clase'] == 'Parkour')
            .map((json) => User.fromJson(json))
            .toList();
        boxingStudents = users
            .where((user) => user['roll'] == 'estudiante' && user['clase'] == 'Boxeo')
            .map((json) => User.fromJson(json))
            .toList();
        mixedStudents = users
            .where((user) => user['roll'] == 'estudiante' && user['clase'] == 'Mixtas')
            .map((json) => User.fromJson(json))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load attendees');
    }
  }

  Future<void> saveAttendance(String className, List<User> students) async {
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month}-${now.day}";

    for (var student in students) {
      final response = await http.post(
        Uri.parse('https://fullrestapi.onrender.com/asistencia'), // Reemplaza con la IP de tu computadora
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': student.id,
          'nombre_usuario': student.nombre,
          'apellido': student.apellido,
          'clase': student.clase,
          'fecha_actual': formattedDate,
          'estado_asistencia': student.present ? 'Presente' : 'Ausente',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save attendance');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Asistencia guardada correctamente para $className')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia'),
        actions: [
          TextButton(
            onPressed: selectedClass != null
                ? () {
                    switch (selectedClass) {
                      case 'Parkour':
                        saveAttendance(selectedClass!, parkourStudents);
                        break;
                      case 'Boxeo':
                        saveAttendance(selectedClass!, boxingStudents);
                        break;
                      case 'Mixtas':
                        saveAttendance(selectedClass!, mixedStudents);
                        break;
                    }
                  }
                : null,
            child: Text(
              'Guardar Cambios',
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
          : ListView(
              children: [
                _buildClassSection('Parkour', parkourStudents, selectedClass == 'Parkour'),
                _buildClassSection('Boxeo', boxingStudents, selectedClass == 'Boxeo'),
                _buildClassSection('Mixtas', mixedStudents, selectedClass == 'Mixtas'),
              ],
            ),
    );
  }

  Widget _buildClassSection(String className, List<User> students, bool isSelected) {
    return ExpansionTile(
      title: Text(className),
      onExpansionChanged: (expanded) {
        setState(() {
          if (expanded) {
            selectedClass = className;
          } else {
            selectedClass = null;
          }
        });
      },
      initiallyExpanded: isSelected,
      children: isSelected
          ? students.map((student) {
              return ListTile(
                leading: Icon(Icons.person),
                title: Text('${student.nombre} ${student.apellido}'),
                trailing: Checkbox(
                  value: student.present,
                  onChanged: (bool? value) {
                    setState(() {
                      student.present = value!;
                    });
                  },
                ),
              );
            }).toList()
          : [],
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
    id: json['id_usuario'] ?? 0,  // Ejemplo: proporciona 0 si 'id_usuario' es nulo
    nombre: json['nombre'] ?? '',
    apellido: json['apellido'] ?? '',
    gmail: json['gmail'] ?? '',
    contrasena: json['contrasena'] ?? '',
    roll: json['roll'] ?? '',
    clase: json['clase'] ?? '',
  );
}

}
