import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authService.logOut();
            if(context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
              );
            }
          },

          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(
            Colors.redAccent,
          ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            )
          ),
        ),
          child: const Text("Cerrar Sesion",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      ),
    ));
  }
}