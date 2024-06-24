import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'forgot_password.dart';
import './student/index.dart';
import './teacher/index.dart';
import 'welcome_screen.dart';


//definicon de la clase LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String apiUrl = 'https://fullrestapi.onrender.com/user/login';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'gmail': email,
          'contraseña': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success']) {
          String role = jsonResponse['data']['roll'];

          if (role == 'profesor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserScreen()),
            );
          }
        } 
      } else {
        print('Error de inicio de sesión: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error de inicio de sesión'),
              content: const Text('Correo o contraseña incorrecta.'),
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
    } catch (e) {
      print('Error al conectarse al servidor: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error de conexión'),
            content: const Text('No se pudo conectar al servidor.'),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color(0xffB81736),
                    Color(0xff281537),
                  ]),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenidos',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontFamily: 'SuperItalic',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '                           A YAMIX A',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/yamix.png'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffB81736),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xff281537),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                      GestureDetector(
                        onTap: _login,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(colors: [
                              Color(0xffB81736),
                              Color(0xff281537),
                            ]),
                          ),
                          child: const Center(
                            child: Text(
                              'Entrar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
