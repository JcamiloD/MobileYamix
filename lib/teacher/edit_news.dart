import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../static/mydrawe.dart';

import 'news.dart'; // Para formatear la fecha
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarEventoScreen extends StatefulWidget {
  final Map<String, dynamic> evento;

  const EditarEventoScreen({Key? key, required this.evento}) : super(key: key);

  @override
  _EditarEventoScreenState createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController tipoController;
  late TextEditingController ubicacionController;
  late TextEditingController fechaInicioController;
  late TextEditingController fechaFinalController;

  @override
  void initState() {
    super.initState();
    nombreController =
        TextEditingController(text: widget.evento['nombre_evento']);
    descripcionController =
        TextEditingController(text: widget.evento['descripcion']);
    tipoController = TextEditingController(text: widget.evento['tipo_evento']);
    ubicacionController =
        TextEditingController(text: widget.evento['ubicacion']);
    fechaInicioController = TextEditingController(
        text: widget.evento['fecha_hora_inicio'].toString());
    fechaFinalController = TextEditingController(
        text: widget.evento['fecha_hora_final'].toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    tipoController.dispose();
    ubicacionController.dispose();
    fechaInicioController.dispose();
    fechaFinalController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime initialDate = DateTime.now(); // Fallback if parsing fails

    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.text);
      }
    } catch (e) {
      print('Error parsing date: $e');
      initialDate = DateTime.now();
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        DateTime selectedDateTime = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        // Format the selectedDateTime to the desired format (year-month-day hour:minute)
        controller.text =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
      }
    }
  }

  Future<void> _guardarCambios() async {
    // Implementa la lógica para guardar los cambios del evento
    // Puedes usar una petición HTTP PUT o PATCH para actualizar los datos en el servidor
    // Aquí solo se muestra un ejemplo básico de cómo podría funcionar

    final updatedEvento = {
      'id_evento': widget.evento['id_evento'],
      'nombre_evento': nombreController.text,
      'descripcion': descripcionController.text,
      'tipo_evento': tipoController.text,
      'ubicacion': ubicacionController.text,
      'fecha_hora_inicio': fechaInicioController.text,
      'fecha_hora_final': fechaFinalController.text,
    };

    final response = await http.put(
      Uri.parse(
          'https://fullrestapi.onrender.com/eventos/${widget.evento['id_evento']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedEvento),
    );

    if (response.statusCode == 200) {
      // Si la actualización es exitosa, regresa a la pantalla anterior y refresca
      Navigator.pop(context, true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => NewsScreen(),
      ));
    } else {
      // Muestra un mensaje de error si la actualización falla
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'No se pudo guardar los cambios. Inténtalo de nuevo.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
                Color.fromRGBO(184, 23, 54, 1),
                Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Editar Evento'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Evento',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                maxLines: 3,
              ),
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Evento',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              TextField(
                controller: fechaInicioController,
                decoration: const InputDecoration(
                  labelText: 'Fecha y Hora de Inicio',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(fechaInicioController),
              ),
              TextField(
                controller: fechaFinalController,
                decoration: const InputDecoration(
                  labelText: 'Fecha y Hora de Finalización',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 223, 22, 22)), // Color del texto del label
                  // Para cambiar el color del texto del input
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(fechaFinalController),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        // Otros estilos de botón aquí si es necesario
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          color: Colors
                              .black, // Establece el color del texto a negro
                          // Puedes añadir más estilos de texto aquí si es necesario
                        ),
                      ),
                    ),

                    const SizedBox(width: 10), // Espacio entre botones
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Cierra la pantalla actual y regresa a la anterior
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        // Otros estilos de botón aquí si es necesario
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors
                              .black, // Establece el color del texto a negro
                          // Puedes añadir más estilos de texto aquí si es necesario
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
