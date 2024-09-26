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
  final TextEditingController _fechaHoraInicioController =
      TextEditingController();
  final TextEditingController _fechaHoraFinalController =
      TextEditingController();

  // Nuevos controladores
  final TextEditingController _notificarController = TextEditingController();
  final TextEditingController _descripcionNotificacionController =
      TextEditingController();
  final TextEditingController _duracionController = TextEditingController();

  String? _claseSeleccionada; // Variable para la clase seleccionada
  final List<String> _clases = ['Mixtas', 'Parkour', 'Boxeo'];

  final String apiUrl =
      'http://192.168.27.228:4000/api/agregar_evento'; // Cambiado el endpoint

  final TextStyle _labelStyle = const TextStyle(
    color: Color(0xffB81736),
    fontWeight: FontWeight.bold,
  );

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm:ss'); // Formato de 24 horas
    return format.format(dt);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime); // Formato de fecha y hora
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            readOnly: true,
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
                    DateTime selectedDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      timePicked.hour,
                      timePicked.minute,
                    );
                    _fechaHoraInicioController.text =
                        formatDateTime(selectedDateTime);
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
          ),
          TextFormField(
            controller: _fechaHoraFinalController,
            decoration: InputDecoration(
              labelText: 'Fecha y Hora Final',
              labelStyle: _labelStyle,
            ),
            readOnly: true,
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
                    DateTime selectedDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      timePicked.hour,
                      timePicked.minute,
                    );
                    _fechaHoraFinalController.text =
                        formatDateTime(selectedDateTime);
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
          ),
          // Nuevos campos para notificar y descripción de la notificación
          TextFormField(
            controller: _notificarController,
            decoration: InputDecoration(
              labelText: 'Notificar',
              labelStyle: _labelStyle,
            ),
          ),
          TextFormField(
            controller: _descripcionNotificacionController,
            decoration: InputDecoration(
              labelText: 'Descripción de la Notificación',
              labelStyle: _labelStyle,
            ),
            maxLines: 3,
          ),
          // Campo para Duración
          TextFormField(
            controller: _duracionController,
            decoration: InputDecoration(
              labelText: 'Duración (minutos)',
              labelStyle: _labelStyle,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese la duración';
              }
              return null;
            },
          ),
          // Selector para Clase
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Clase',
              labelStyle: _labelStyle,
            ),
            value: _claseSeleccionada,
            items: _clases.map((String clase) {
              return DropdownMenuItem<String>(
                value: clase,
                child: Text(clase),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _claseSeleccionada = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, seleccione una clase';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Mapeo de clase a número
                  String claseMapeada = '';
                  switch (_claseSeleccionada) {
                    case 'Parkour':
                      claseMapeada = '1';
                      break;
                    case 'Mixtas':
                      claseMapeada = '2';
                      break;
                    case 'Boxeo':
                      claseMapeada = '3';
                      break;
                  }

                  var data = {
                    'nombre_evento': _nombreEventoController.text,
                    'descripcion': _descripcionController.text,
                    'tipo_evento': _tipoEventoController.text,
                    'ubicacion': _ubicacionController.text,
                    'fecha_inicio': _fechaHoraInicioController.text,
                    'fecha_fin': _fechaHoraFinalController.text,
                    'id_clase': claseMapeada,
                    'duracion': _duracionController.text,
                    'notificar': _notificarController.text,
                    'descripcion_notificacion':
                        _descripcionNotificacionController.text,
                  };

                  try {
                    final response = await http.post(
                      Uri.parse(apiUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(data),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Evento agregado exitosamente')),
                      );

                      // Refrescar la página
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddEventScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error al agregar el evento')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error de conexión')),
                    );
                  }
                }
              },
              child: const Text('Agregar Evento'),
            ),
          ),
        ],
      ),
    );
  }
}
