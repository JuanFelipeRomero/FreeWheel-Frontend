import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/user_models.dart';
import 'package:freewheel_frontend/data/services/user_service.dart';

class PassengerProfileScreen extends StatefulWidget {
  final int userId;

  const PassengerProfileScreen({
    super.key,
    required this.userId, // Ahora es requerido, sin valor por defecto
  });

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  final UserService _userService = UserService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Imprimir el ID del usuario que se va a cargar
      print('🔍 Cargando perfil del usuario con ID: ${widget.userId}');

      // Usar el método para obtener perfil de conductor en lugar de perfil de usuario
      final profile = await _userService.getDriverProfile(widget.userId);

      if (profile != null) {
        print(
          '✅ Perfil cargado correctamente - Conductor ID: ${profile.id}, Nombre: ${profile.nombre} ${profile.apellido}',
        );
      } else {
        print(
          '❌ No se pudo obtener el perfil del conductor con ID: ${widget.userId}',
        );
      }

      setState(() {
        _userProfile = profile;
        _isLoading = false;

        if (profile == null) {
          _errorMessage = 'No se pudo cargar el perfil del conductor';
        }
      });
    } catch (e) {
      print('❌ Error al cargar el perfil: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Conductor'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_userProfile == null) {
      return const Center(child: Text('Información no disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto de perfil
          _buildProfilePicture(),

          const SizedBox(height: 24),

          // Nombre completo
          Text(
            '${_userProfile!.nombre} ${_userProfile!.apellido}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Información de contacto y otros detalles
          _buildInfoCard(
            title: 'Información de contacto',
            content: [
              _buildInfoRow(
                Icons.email,
                'Correo electrónico',
                _userProfile!.correo,
              ),
              _buildInfoRow(Icons.phone, 'Teléfono', _userProfile!.telefono),
            ],
          ),

          const SizedBox(height: 16),

          // Información organizacional
          _buildInfoCard(
            title: 'Información organizacional',
            content: [
              _buildInfoRow(
                Icons.business,
                'Organización',
                _userProfile!.organizacionCodigo,
              ),
              if (_userProfile!.driver)
                _buildInfoRow(Icons.drive_eta, 'Conductor', 'Sí'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child:
            _userProfile?.fotoPerfil != null
                ? Image.network(
                  _userProfile!.fotoPerfil!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error,
                        size: 40,
                        color: Colors.red,
                      ),
                    );
                  },
                )
                : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
