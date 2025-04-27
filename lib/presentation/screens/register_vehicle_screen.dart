import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freewheel_frontend/data/services/register_vehicle_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RegisterVehicleScreen extends StatefulWidget {
  const RegisterVehicleScreen({super.key});

  @override
  State<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehicleScreen> {
  final VehicleService _vehicleService = VehicleService();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();

  // Files
  File? _licenciaTransitoImage;
  File? _soatPdf;
  File? _certificadoRevisionPdf;
  File? _vehicleImage;

  bool _isLoading = false;

  // Lists for dropdowns
  final List<String> _tipoVehiculos = ['Sedan', 'SUV', 'Hatchback', 'Camioneta', 'Otro'];
  String? _selectedTipo;

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _colorController.dispose();
    _tipoController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _takeVehiclePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Save image to app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedImagePath = path.join(
        appDir.path,
        'vehicle_image_$timestamp$fileName',
      );

      final File savedImage = File(savedImagePath);
      await savedImage.writeAsBytes(await photo.readAsBytes());

      setState(() {
        _vehicleImage = savedImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar la foto: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _takeLicenciaTransitoPhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Save image to app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedImagePath = path.join(
        appDir.path,
        'licencia_transito_$timestamp$fileName',
      );

      final File savedImage = File(savedImagePath);
      await savedImage.writeAsBytes(await photo.readAsBytes());

      setState(() {
        _licenciaTransitoImage = savedImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar la foto: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickSoatPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('No se pudo obtener la ruta del archivo');
      }

      // Save PDF to app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(filePath);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedPdfPath = path.join(
        appDir.path,
        'soat_$timestamp$fileName',
      );

      final File originalFile = File(filePath);
      final File savedFile = await originalFile.copy(savedPdfPath);

      setState(() {
        _soatPdf = savedFile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar el PDF: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickCertificadoRevisionPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('No se pudo obtener la ruta del archivo');
      }

      // Save PDF to app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(filePath);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedPdfPath = path.join(
        appDir.path,
        'certificado_revision_$timestamp$fileName',
      );

      final File originalFile = File(filePath);
      final File savedFile = await originalFile.copy(savedPdfPath);

      setState(() {
        _certificadoRevisionPdf = savedFile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar el PDF: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submitVehicleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_licenciaTransitoImage == null ||
        _soatPdf == null ||
        _certificadoRevisionPdf == null ||
        _vehicleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes subir todos los documentos requeridos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _vehicleService.registerVehicle(
        placa: _placaController.text,
        marca: _marcaController.text,
        modelo: _modeloController.text,
        anio: _anioController.text,
        color: _colorController.text,
        tipo: _selectedTipo ?? _tipoVehiculos[0],
        capacidadPasajeros: _capacidadController.text,
        licenciaTransito: _licenciaTransitoImage!,
        soat: _soatPdf!,
        certificadoRevision: _certificadoRevisionPdf!,
        foto: _vehicleImage!,
      );

      if (success) {
        // Delete temporary files
        await _deleteTemporaryFiles();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Vehículo registrado correctamente! Ya puedes comenzar a usar la aplicación como conductor.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar el vehículo: $e'),
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

  Future<void> _deleteTemporaryFiles() async {
    try {
      // Delete licencia transito image
      if (_licenciaTransitoImage != null && await _licenciaTransitoImage!.exists()) {
        await _licenciaTransitoImage!.delete();
      }

      // Delete SOAT PDF
      if (_soatPdf != null && await _soatPdf!.exists()) {
        await _soatPdf!.delete();
      }

      // Delete certificado revision PDF
      if (_certificadoRevisionPdf != null && await _certificadoRevisionPdf!.exists()) {
        await _certificadoRevisionPdf!.delete();
      }

      // Delete vehicle image
      if (_vehicleImage != null && await _vehicleImage!.exists()) {
        await _vehicleImage!.delete();
      }

      setState(() {
        _licenciaTransitoImage = null;
        _soatPdf = null;
        _certificadoRevisionPdf = null;
        _vehicleImage = null;
      });
    } catch (e) {
      print('Error eliminando archivos temporales: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Vehículo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de tu vehículo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Para completar tu registro como conductor, necesitamos información del vehículo que utilizarás.',
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // Placa
                    TextFormField(
                      controller: _placaController,
                      decoration: const InputDecoration(
                        labelText: 'Placa',
                        hintText: 'Ingresa la placa del vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.car_rental),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        UpperCaseTextFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la placa del vehículo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Marca
                    TextFormField(
                      controller: _marcaController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        hintText: 'Ingresa la marca del vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.branding_watermark),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la marca del vehículo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Modelo
                    TextFormField(
                      controller: _modeloController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        hintText: 'Ingresa el modelo del vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.model_training),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el modelo del vehículo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Año
                    TextFormField(
                      controller: _anioController,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        hintText: 'Ingresa el año del vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el año del vehículo';
                        }
                        if (int.tryParse(value) == null) {
                          return 'El año debe ser un número';
                        }
                        final year = int.parse(value);
                        final currentYear = DateTime.now().year;
                        if (year < 1980 || year > currentYear) {
                          return 'Ingresa un año válido (1980-$currentYear)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Color
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'Ingresa el color del vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.color_lens),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el color del vehículo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Tipo de vehículo (dropdown)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: _tipoVehiculos.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTipo = newValue;
                        });
                      },
                      value: _selectedTipo ?? _tipoVehiculos[0],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona el tipo de vehículo';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Capacidad de pasajeros
                    TextFormField(
                      controller: _capacidadController,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad de pasajeros',
                        hintText: 'Número de pasajeros',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la capacidad de pasajeros';
                        }
                        if (int.tryParse(value) == null) {
                          return 'La capacidad debe ser un número';
                        }
                        final capacity = int.parse(value);
                        if (capacity < 1 || capacity > 9) {
                          return 'La capacidad debe estar entre 1 y 9 pasajeros';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Documentos del vehículo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Licencia de tránsito (foto)
                    _buildDocumentUploadSection(
                      title: 'Licencia de tránsito',
                      subtitle: 'Toma una foto clara de la licencia de tránsito de tu vehículo',
                      icon: Icons.featured_play_list,
                      isImage: true,
                      file: _licenciaTransitoImage,
                      onPressed: _takeLicenciaTransitoPhoto,
                      buttonText: 'Tomar foto de licencia',
                    ),

                    const SizedBox(height: 24),

                    // SOAT (PDF)
                    _buildDocumentUploadSection(
                      title: 'SOAT',
                      subtitle: 'Sube el PDF del SOAT vigente de tu vehículo',
                      icon: Icons.health_and_safety,
                      isImage: false,
                      file: _soatPdf,
                      onPressed: _pickSoatPdf,
                      buttonText: 'Seleccionar PDF de SOAT',
                    ),

                    const SizedBox(height: 24),

                    // Certificado de revisión técnico-mecánica (PDF)
                    _buildDocumentUploadSection(
                      title: 'Certificado de revisión técnico-mecánica',
                      subtitle: 'Sube el PDF del certificado de revisión técnico-mecánica vigente',
                      icon: Icons.engineering,
                      isImage: false,
                      file: _certificadoRevisionPdf,
                      onPressed: _pickCertificadoRevisionPdf,
                      buttonText: 'Seleccionar PDF de certificado',
                    ),

                    const SizedBox(height: 24),

                    // Foto del vehículo
                    _buildDocumentUploadSection(
                      title: 'Foto del vehículo',
                      subtitle: 'Toma una foto clara y completa de tu vehículo',
                      icon: Icons.directions_car,
                      isImage: true,
                      file: _vehicleImage,
                      onPressed: _takeVehiclePhoto,
                      buttonText: 'Tomar foto del vehículo',
                    ),

                    const SizedBox(height: 40),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitVehicleRegistration,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            theme.colorScheme.primary,
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
                          'Registrar Vehículo',
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
            ),
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isImage,
    required File? file,
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 16),

          if (file != null)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF seleccionado: ${path.basename(file.path)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isImage ? Icons.image : Icons.picture_as_pdf,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isImage ? 'No hay foto seleccionada' : 'No hay PDF seleccionado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(isImage ? Icons.camera_alt : Icons.upload_file),
              label: Text(buttonText),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}