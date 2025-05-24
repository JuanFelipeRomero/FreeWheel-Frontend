import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/user_models.dart';
import 'package:freewheel_frontend/data/services/user_service.dart';
import 'package:freewheel_frontend/presentation/screens/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.expand(child: RegisterForm()));
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizacionCodigoController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizacionCodigoController.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = UserRegistration(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        password: _passwordController.text,
        organizacionCodigo: _organizacionCodigoController.text.trim(),
      );

      final response = await _userService.registerUser(user);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Por favor inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Error durante el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Registrarse',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Nombre", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(hintText: 'Juan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Apellido", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(hintText: 'Perez'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Correo", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _correoController,
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

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Teléfono", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(hintText: '3211234567'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu teléfono';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Contraseña", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: '••••••'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Confirmar contraseña", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(hintText: '••••••'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Código Organización", style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                controller: _organizacionCodigoController,
                decoration: const InputDecoration(hintText: '####'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código de organización';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _register(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blueAccent,
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 50),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}