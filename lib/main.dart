import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      title: 'Hola mundo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Free Wheel", style: TextStyle(fontSize: 40)),

            const SizedBox(height: 80),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FilledButton(
                    onPressed: () => _toLoginSreen(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                    child: const Text("Iniciar sesión"),
                  ),
                  FilledButton(
                    onPressed: () => _toRegisterScreen(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                    child: const Text("Registrarse"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _toLoginSreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}

void _toRegisterScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const RegisterScreen()),
  );
}
