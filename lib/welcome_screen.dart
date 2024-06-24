import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  
Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir $url';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
              Color(0xffB81736),
              Color.fromARGB(255, 65, 39, 39),
            ])),
        child: Column(children: [
          const SizedBox(
            height: 90,
          ),
          const Text(
            'Yamix',
            style: TextStyle(
              fontFamily: 'SuperItalic',
              fontSize: 90,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 70,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Agrega espacio horizontal
            child: const Text(
              'Bienvenido al nuevo administrador móvil de Yamix',
              textAlign: TextAlign.center, // Centra el texto
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Spacer(),
          const Text(
            'Nuestras redes sociales',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.facebook,
                    color: Colors.white),
                onPressed: () =>
                    _launchURL('https://www.facebook.com'),
              ),
              IconButton(
                icon:
                    const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                onPressed: () =>
                    _launchURL('https://www.twitter.com/tu_pagina'),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.instagram,
                    color: Colors.white),
                onPressed: () =>
                    _launchURL('https://www.instagram.com/tu_pagina'),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.linkedin,
                    color: Colors.white),
                onPressed: () =>
                    _launchURL('https://www.linkedin.com/tu_pagina'),
              ),
              
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}