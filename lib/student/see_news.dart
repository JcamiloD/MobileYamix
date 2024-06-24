import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    fetchEventos();
  }

  Future<void> fetchEventos() async {
    final response = await http
        .get(Uri.parse('https://fullrestapi.onrender.com/eventos'));

    if (response.statusCode == 200) {
      try {
        final responseBody = response.body;
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        final List<dynamic> data = jsonResponse['eventos'];
        setState(() {
          _eventos = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error parsing data';
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
                // Implementar navegación al inicio de la aplicación
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
                // Implementar navegación al panel de eventos del administrador
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
                // Implementar navegación al panel de novedades del administrador
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
                // Implementar lógica para cerrar sesión
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

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: FaIcon(FontAwesomeIcons.calendar),
            title: Text(nombreEvento),
            subtitle: Text(
                'Descripción: $descripcion\nTipo: $tipoEvento\nUbicación: $ubicacion\nInicio: $fechaHoraInicio\nFinal: $fechaHoraFinal'),
          ),
        ],
      ),
    );
  }
}
