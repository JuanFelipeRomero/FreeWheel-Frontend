import 'package:flutter/material.dart';

class PassengerProfileScreen extends StatelessWidget {
  // Constructor básico
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Pasajero')),
      body: const Center(
        child: Text(
          'Pantalla de Perfil de Pasajero en desarrollo',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
