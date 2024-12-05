import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de importar esta librería

import '../teacher/add_attendance.dart';
import '../teacher/attendance.dart';
import '../teacher/create_news.dart';
import '../teacher/index.dart';
import '../teacher/news.dart';
import '../login_screen.dart' as login_screen;

class MyDrawer extends StatelessWidget {
  // Función de logout
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    
    // Redirigir a la pantalla de inicio de sesión después del logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const login_screen.LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            child: SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Asistencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.check),
            title: const Text('Panel de asistencia'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AsistenciaScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Agregar asistencia'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendancePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const FaIcon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              logout(context); // Llama a la función de logout
            },
          ),
        ],
      ),
    );
  }
}
