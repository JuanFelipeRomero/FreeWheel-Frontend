import "package:flutter/material.dart";
import "home_screen.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.expand(child: LoginForm()));
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(36),
      child: Form(
        //key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Iniciar sesion', style: TextStyle(fontSize: 20)),

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

//Funcion para crear campos con estilos personalizados
Widget _buildTextFiel({required label}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label, //recibe el label como parametro
      hintText: 'Digite su correo',
    ),
  );
}
