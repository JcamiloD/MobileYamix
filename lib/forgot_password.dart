import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:http/http.dart' as http;
import 'reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _showCodeInput = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _generatedCode = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryCode() async {
    String email = _emailController.text;

    if (email.isNotEmpty) {
      final response = await http.get(Uri.parse('https://fullrestapi.onrender.com/user/check-email/$email'));

      if (response.statusCode == 200) {
        String username = 'yamix892@gmail.com';
        String password = 'btqn ltln mahm ohrv';

        final smtpServer = gmail(username, password);
        final colombiaTimeZone = tz.getLocation('America/Bogota');
        final now = tz.TZDateTime.now(colombiaTimeZone);
        final formattedDate = DateFormat('hh:mm a').format(now);

        _generatedCode = (Random().nextInt(900000) + 100000).toString();

        final message = Message()
          ..from = Address(username, '🥷🏽 YAMIX 🥷🏽')
          ..recipients.add(email)
          ..subject = 'Código de un solo uso :: $formattedDate'
          ..text = 'Tu código de recuperación es: $_generatedCode'
          ..html = "<p>Tu código de recuperación es: <b>$_generatedCode</b></p>";

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: $sendReport');

          _userEmail = email;

          if (mounted) {
            setState(() {
              _showCodeInput = true;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de recuperación enviado.')),
          );
        } on MailerException catch (e) {
          print('Mensasje no enviado.');
          for (var p in e.problems) {
            print('problema: ${p.code}: ${p.msg}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar el código de recuperación: ${e.toString()}')),
          );
        }
      } else if (response.statusCode == 404) {
        // El correo no existe
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo no encontrado.')),
        );
      } else {
        // Error al verificar el correo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al verificar el correo.')),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _showCodeInput = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo electrónico.')),
      );
    }
  }

  void _onSubmitCode() {
    if (_codeController.text == _generatedCode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen(userId: _userEmail)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de recuperación incorrecto.')),
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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                padding: EdgeInsets.only(top: 50.0, left: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recuperar Contraseña',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: 'SuperItalic',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ingresa tu correo electrónico para recibir un código.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
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
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffB81736),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _sendRecoveryCode,
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
                            'Recibir Código',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                    if (_showCodeInput)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Código de Recuperación',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _onSubmitCode,
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
                                  'Enviar Código',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
