import 'package:flutter/material.dart';
import '../static/mydrawe.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
                title: const Text('Inicio'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              const Expanded(
                child: Center(
                  child: Text('Bienvenido Profesor'),
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
