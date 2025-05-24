import "package:flutter/material.dart";
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/presentation/screens/register_screen.dart';
import 'package:freewheel_frontend/presentation/screens/registration_screen.dart'; // Corrected import name if needed
import "../shell/main_screen.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.expand(child: LoginForm()));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    // It's safer to check if currentState is not null before calling validate
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Check if the widget is still mounted before navigating
        if (!mounted) return;

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciales incorrectas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
         // Check if the widget is still mounted before showing SnackBar
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexion'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
         // Check if the widget is still mounted before updating state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } // Added closing brace for the if statement
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(36),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Correo", style: TextStyle(fontSize: 16)),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'correo@ejemplo.com'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                 if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                return null;
              },
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Contraseña", style: TextStyle(fontSize: 16)),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: '••••••'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () => _login(context),
                  style: ButtonStyle(
                    // *** FIX: Use MaterialStateProperty instead of WidgetStateProperty ***
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blueAccent,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                     minimumSize: MaterialStateProperty.all<Size>( // Added minimum size like in register screen
                        const Size(double.infinity, 50),
                     ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿No tienes una cuenta?'),
                TextButton(
                  onPressed: () {
                    // Use pushReplacement if you don't want users going back to login from register
                    Navigator.pushReplacement( // Changed from push to pushReplacement
                      context,
                      MaterialPageRoute(
                        // Ensure the screen name matches your file/class name
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// You might need to import RegisterScreen if it's not already imported
// import 'package:freewheel_frontend/presentation/screens/register_screen.dart';