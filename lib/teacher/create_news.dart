import 'dart:convert';
import 'package:flutter/material.dart';
import '../static/mydrawe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenedor con el degradado que cubre toda la parte superior
          Container(
            height: 80, // Ajusta la altura según sea necesario
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
          ),
          // El contenido principal de la aplicación
          Column(
            children: [
              AppBar(
                title: const Text('Agregar Evento'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AddEventForm(),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}

class AddEventForm extends StatefulWidget {
  @override
  _AddEventFormState createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreEventoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoEventoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaHoraInicioController = TextEditingController();
  final TextEditingController _fechaHoraFinalController = TextEditingController();

  final String apiUrl = 'https://fullrestapi.onrender.com/evento';

  final TextStyle _labelStyle = const TextStyle(
    color: Color(0xffB81736),
    fontWeight: FontWeight.bold,
  );

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // Formato de 12 horas con AM/PM
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nombreEventoController,
              decoration: InputDecoration(
                labelText: 'Nombre del Evento',
                labelStyle: _labelStyle,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese el nombre del evento';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: _labelStyle,
              ),
              maxLines: 3,
            ),
            TextFormField(
              controller: _tipoEventoController,
              decoration: InputDecoration(
                labelText: 'Tipo de Evento',
                labelStyle: _labelStyle,
              ),
            ),
            TextFormField(
              controller: _ubicacionController,
              decoration: InputDecoration(
                labelText: 'Ubicación',
                labelStyle: _labelStyle,
              ),
              maxLines: 1,
            ),
            TextFormField(
              controller: _fechaHoraInicioController,
              decoration: InputDecoration(
                labelText: 'Fecha y Hora de Inicio',
                labelStyle: _labelStyle,
              ),
              readOnly: true, // Para evitar que el usuario escriba directamente en el campo
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  TimeOfDay? timePicked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timePicked != null) {
                    setState(() {
                      // Construir la cadena en el formato deseado (ejemplo: YYYY-MM-DD HH:mm AM/PM)
                      String formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} '
                          '${formatTimeOfDay(timePicked)}';
                      _fechaHoraInicioController.text = formattedDate;
                    });
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese la fecha y hora de inicio';
                }
                return null;
              },
              maxLines: 2,
            ),
            TextFormField(
              controller: _fechaHoraFinalController,
              decoration: InputDecoration(
                labelText: 'Fecha y Hora Final',
                labelStyle: _labelStyle,
              ),
              readOnly: true, // Para evitar que el usuario escriba directamente en el campo
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  TimeOfDay? timePicked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timePicked != null) {
                    setState(() {
                      // Construir la cadena en el formato deseado (ejemplo: YYYY-MM-DD HH:mm AM/PM)
                      String formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} '
                          '${formatTimeOfDay(timePicked)}';
                      _fechaHoraFinalController.text = formattedDate;
                    });
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese la fecha y hora final';
                }
                return null;
              },
              maxLines: 2,
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var data = {
                      'nombre_evento': _nombreEventoController.text,
                      'descripcion': _descripcionController.text,
                      'tipo_evento': _tipoEventoController.text,
                      'ubicacion': _ubicacionController.text,
                      'fecha_hora_inicio': _fechaHoraInicioController.text,
                      'fecha_hora_final': _fechaHoraFinalController.text,
                    };

                    try {
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: json.encode(data),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                      );

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Evento agregado correctamente')),
                        );
                        _nombreEventoController.clear();
                        _descripcionController.clear();
                        _tipoEventoController.clear();
                        _ubicacionController.clear();
                        _fechaHoraInicioController.clear();
                        _fechaHoraFinalController.clear();
                      } else {
                        print('Error al agregar el evento: ${response.statusCode}');
                      }
                    } catch (e) {
                      print('Error de red: $e');
                    }
                  }
                },
                
                child: const Text(
                  
                  'Agregar Evento',
                  style: TextStyle(
                    color: Color.fromRGBO(184, 23, 54, 1),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    
                  ),
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}