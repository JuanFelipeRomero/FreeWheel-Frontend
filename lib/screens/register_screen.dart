import "package:flutter/material.dart";
import "package:freewheel_frontend/screens/home_screen.dart";

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.expand(child: RegisterForm()));
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

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
              'Registrarse',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Nombre")),
            TextFormField(decoration: const InputDecoration(hintText: 'Juan')),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Apellido")),
            TextFormField(decoration: const InputDecoration(hintText: 'Perez')),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Correo")),
            TextFormField(
              decoration: const InputDecoration(hintText: 'correo@ejemplo.com'),
            ),

            const SizedBox(height: 32),

            Align(alignment: Alignment.centerLeft, child: Text("Telefono")),
            TextFormField(
              decoration: const InputDecoration(hintText: '3211234567'),
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Codigo Organizacion"),
            ),
            TextFormField(decoration: const InputDecoration(hintText: '####')),

            const SizedBox(height: 32),

            FilledButton(
              onPressed: () => _toHomeScreen(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blueAccent,
                ),
              ),
              child: const Text('Registrarse'),
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
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
}
