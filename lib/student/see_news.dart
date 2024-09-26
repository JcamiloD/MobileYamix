import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';  // Asegúrate de agregar esta línea para decodificar el JWT.
import '../login_screen.dart' as login_screen;

import 'index.dart';

class UserNewsScreen extends StatefulWidget {
  const UserNewsScreen({super.key});

  @override
  _UserNewsScreenState createState() => _UserNewsScreenState();
}

class _UserNewsScreenState extends State<UserNewsScreen> {
  List<dynamic> _eventos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _token; // Variable para almacenar el token
  String? _clase; // Variable para almacenar la clase del usuario

  @override
  void initState() {
    super.initState();
    _loadTokenAndClass(); // Cargar token y clase al iniciar
  }

  Future<void> _loadTokenAndClass() async {
    // Obtener el token almacenado en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    
    if (token != null) {
      // Decodificar el JWT para obtener la clase del usuario
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? clase = decodedToken['clase'];  // Extraer el campo 'clase' del token

      setState(() {
        _token = token;  // Guardar el token
        _clase = clase;  // Guardar la clase
      });

      fetchEventos();  // Llamar a la función para obtener los eventos
    } else {
      setState(() {
        _errorMessage = 'Token not found';
        _isLoading = false;
      });
    }
  }

Future<void> fetchEventos() async {
  if (_token == null || _clase == null) {
    setState(() {
      _errorMessage = 'Error: Token or class is missing';
      _isLoading = false;
    });
    return;
  }

  final response = await http.get(
    Uri.parse('http://192.168.27.228:4000/api/traerEventosPorNombreClase/$_clase'),
    headers: {
      'Authorization': 'Bearer $_token',
    },
  );

  print('Response body: ${response.body}');  // Imprimir el cuerpo de la respuesta

  if (response.statusCode == 200) {
    try {
      final responseBody = response.body;
      final List<dynamic> data = json.decode(responseBody);  // Decodificar como una lista, no como un mapa
      setState(() {
        _eventos = data;  // Guardar la lista directamente
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error parsing data: $e';
        _isLoading = false;
      });
    }
  } else {
    setState(() {
      _errorMessage = 'Failed to load eventos';
      _isLoading = false;
    });
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
                Color(0xffB81736),
                Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Novedades'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/yamix.png'),
                  fit: BoxFit.contain,
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffB81736),
                    Color(0xff281537),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: null,
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Clases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userNinja),
              title: const Text('Ver Clases'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Novedades',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.newspaper),
              title: const Text('Panel de novedades'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserNewsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const FaIcon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const login_screen.LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : ListView.builder(
                    itemCount: _eventos.length,
                    itemBuilder: (context, index) {
                      final evento = _eventos[index];
                      return EventoCard(evento: evento);
                    },
                  ),
      ),
    );
  }
}
class EventoCard extends StatelessWidget {
  final Map<String, dynamic> evento;

  const EventoCard({
    Key? key,
    required this.evento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String nombreEvento = evento['nombre_evento'];
    final String descripcion = evento['descripcion'];
    final String tipoEvento = evento['tipo_evento'];
    final String ubicacion = evento['ubicacion'];
    final String fechaHoraInicio = evento['fecha_hora_inicio'].toString();
    final String fechaHoraFinal = evento['fecha_hora_final'].toString();

    // Parsear las fechas desde las cadenas
    DateTime inicio = DateTime.parse(fechaHoraInicio);
    DateTime fin = DateTime.parse(fechaHoraFinal);

    // Definir el formato deseado
    String formato = 'dd/MM/yyyy HH:mm'; // Formato deseado
    String fechaInicioFormateada = DateFormat(formato).format(inicio);
    String fechaFinalFormateada = DateFormat(formato).format(fin);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: FaIcon(FontAwesomeIcons.calendar),
            title: Text(nombreEvento),
            subtitle: Text(
                'Descripción: $descripcion\nTipo: $tipoEvento\nUbicación: $ubicacion\nInicio: $fechaInicioFormateada\nFinal: $fechaFinalFormateada'),
          ),
        ],
      ),
    );
  }
}
