import "dart:convert";

import "package:flutter/material.dart";
import "home_screen.dart";
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.expand(child: LoginForm()));
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  Future<List<dynamic>?> fetchLogin() async {
    try {
      final url = Uri.parse('http://localhost:8081/auth/login');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(36),
      child: Form(
        //key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar sesion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Correo")),
            TextFormField(
              decoration: const InputDecoration(hintText: 'correo@ejemplo.com'),
            ),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Contraseña")),
            TextFormField(
              decoration: const InputDecoration(hintText: '••••••'),
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: () => _toHomeScreen(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blueAccent,
                ),
              ),
              child: const Text("Iniciar sesión"),
            ),
          ],
        ),
      ),
    );
  }
}

void _toHomeScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}
