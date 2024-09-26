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
  late TextEditingController duracionController;

  late TextEditingController notificarController;
  late TextEditingController descripcionNotificacionController;

  String? selectedClase; // Variable para la clase seleccionada
  final List<String> clases = ['Boxeo', 'Mixtas', 'Parkour']; // Ejemplo sin duplicados

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.evento['nombre_evento']);
    descripcionController = TextEditingController(text: widget.evento['descripcion']);
    tipoController = TextEditingController(text: widget.evento['tipo_evento']);
    ubicacionController = TextEditingController(text: widget.evento['ubicacion']);
    fechaInicioController = TextEditingController(text: widget.evento['fecha_hora_inicio'].toString());
    fechaFinalController = TextEditingController(text: widget.evento['fecha_hora_final'].toString());
    duracionController = TextEditingController(text: widget.evento['duracion']?.toString() ?? '');

    notificarController = TextEditingController(text: widget.evento['notificar'] ?? 'No disponible');
    descripcionNotificacionController = TextEditingController(text: widget.evento['descripcion_notificacion'] ?? 'No disponible');

    // Establecer la clase seleccionada
    selectedClase = widget.evento['tipo_evento'];
    // Verificar si selectedClase está en la lista de clases
    if (!clases.contains(selectedClase)) {
      selectedClase = null; // Si no está, restablecer a null
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    tipoController.dispose();
    ubicacionController.dispose();
    fechaInicioController.dispose();
    fechaFinalController.dispose();
    duracionController.dispose();
    
    notificarController.dispose();
    descripcionNotificacionController.dispose();
    
    super.dispose();
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

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
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
      }
    }
  }

  Future<void> _guardarCambios() async {
    // Mapeo de la clase seleccionada a su correspondiente número
    int? claseNumero;
    if (selectedClase == 'Boxeo') {
      claseNumero = 3;
    } else if (selectedClase == 'Mixtas') {
      claseNumero = 2;
    } else if (selectedClase == 'Parkour') {
      claseNumero = 1;
    }

    final updatedEvento = {
      'id_evento': widget.evento['id_evento'],
      'nombre_evento': nombreController.text,
      'descripcion': descripcionController.text,
      'tipo_evento': tipoController.text,
      'ubicacion': ubicacionController.text,
      'fecha_hora_inicio': fechaInicioController.text,
      'fecha_hora_final': fechaFinalController.text,
      'duracion': duracionController.text,
      'notificar': notificarController.text,
      'descripcion_notificacion': descripcionNotificacionController.text,
      'id_clase': claseNumero, 
    };

    final response = await http.post(
      Uri.parse('http://192.168.27.228:4000/api/actualizar_evento/${widget.evento['id_evento']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedEvento),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => NewsScreen(),
      ));
    } else {
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
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
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(fechaFinalController),
              ),
              TextField(
                controller: duracionController,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: selectedClase,
                hint: const Text('Seleccione una Clase'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedClase = newValue;
                  });
                },
                items: clases.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: notificarController,
                decoration: const InputDecoration(
                  labelText: 'Notificar',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              TextField(
                controller: descripcionNotificacionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de Notificación',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 223, 22, 22)), // Color del texto del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _guardarCambios,
                  child: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
