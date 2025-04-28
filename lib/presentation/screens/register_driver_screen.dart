import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/services/register_driver_service.dart';
import 'package:freewheel_frontend/presentation/screens/register_vehicle_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final ImagePicker _picker = ImagePicker();
  final DriverService _driverService = DriverService();

  File? _frontLicenceImage;
  File? _backLicenceImage;
  bool _isLoading = false;

  Future<void> _takePicture(bool isFrontSide) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80
      );

      if (photo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      //Guardar imagen y obtener la ruta
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedImagePath = path.join(
        appDir.path,
        '${isFrontSide ? 'front' : 'back'}_license_$timestamp$fileName',
      );

      final File savedImage = File(savedImagePath);
      await savedImage.writeAsBytes(await photo.readAsBytes());

      setState(() {
        if (isFrontSide) {
          _frontLicenceImage = savedImage;
        } else {
          _backLicenceImage = savedImage;
        }
        _isLoading = false;
      });

      // If front side was just taken, automatically request back side
      if (isFrontSide && _backLicenceImage == null) {
        // Add a slight delay to allow the UI to update
        Future.delayed(const Duration(milliseconds: 500), () {
          _showBackSideDialog();
        });
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al tomar la foto'),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  void _showBackSideDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Parte trasera de la licencia'),
          content: const Text('Ahora necesitamos una foto de la parte trasera de tu licencia de conducir.'),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              _takePicture(false);
            },
            child: const Text('Continuar'))
          ],
        ),
    );
  }

  Future<void> _submitDriverRegistration() async {
    if (_frontLicenceImage == null || _backLicenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes tomar foto de ambos lados de tu licencia'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String frontImagePath = _frontLicenceImage!.path;
      final String backImagePath = _backLicenceImage!.path;

      // Using the service to register driver
      final success = await _driverService.registerDriverWithLicense(
          _frontLicenceImage!,
          _backLicenceImage!
      );

      if (success) {
        // Delete temporary images after successful submission
        await _deleteTemporaryImages(frontImagePath, backImagePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Solicitud enviada correctamente! Ahora registra tu vehículo.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to vehicle registration screen instead of popping
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterVehicleScreen(),
            ),
          );

          // The bool result will still be refreshed by the system automatically
          // when the user returns to the profile screen after vehicle registration
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTemporaryImages(String frontPath, String backPath) async {
    try {
      // Delete front license image
      final frontFile = File(frontPath);
      if (await frontFile.exists()) {
        await frontFile.delete();
      }

      // Delete back license image
      final backFile = File(backPath);
      if (await backFile.exists()) {
        await backFile.delete();
      }

      setState(() {
        _frontLicenceImage = null;
        _backLicenceImage = null;
      });

    } catch (e) {
      print('Error al eliminar las imagenes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regístrate como conductor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registro de conductor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Para verificar tu identidad como conductor, necesitamos fotos de ambos lados de tu licencia de conducir.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            // Front side license
            Text(
              'Parte frontal de la licencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            _buildLicenseImageSection(
              _frontLicenceImage,
              true,
              'Tomar foto del frente',
            ),

            const SizedBox(height: 24),

            // Back side license
            Text(
              'Parte trasera de la licencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            _buildLicenseImageSection(
              _backLicenceImage,
              false,
              'Tomar foto del reverso',
            ),

            const SizedBox(height: 40),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _frontLicenceImage != null && _backLicenceImage != null
                    ? _submitDriverRegistration
                    : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade300;
                      }
                      return theme.colorScheme.primary;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text(
                  'Enviar solicitud',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseImageSection(File? image, bool isFrontSide, String buttonText) {
    return Column(
      children: [
        if (image != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => _takePicture(isFrontSide),
                      tooltip: 'Tomar otra foto',
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin foto',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _takePicture(isFrontSide),
            icon: const Icon(Icons.camera_alt),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}