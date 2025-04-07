import "package:flutter/material.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Home Screen", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.redAccent,
                ),
              ),
              child: Text('Cerrar Sesion'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
    return Scaffold(
      body: Center(child: 
      Text("Home page", style: TextStyle(fontSize: 24))
      ),
    );
*/
