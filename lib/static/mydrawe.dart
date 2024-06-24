import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../teacher/add_attendance.dart';
import '../teacher/attendance.dart';


import '../teacher/create_news.dart';
import '../teacher/index.dart';
import '../teacher/news.dart';
import '../login_screen.dart' as login_screen;

class MyDrawer extends StatelessWidget {
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
                  builder: (context) =>  AttendancePage(),
                ),
              );
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
                  builder: (context) => const NewsScreen(),
                ),
              );
              // Navegar a la pantalla de Panel de Novedades
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Agregar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEventScreen(),
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
    );
  }
}
