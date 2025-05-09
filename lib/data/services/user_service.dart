import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freewheel_frontend/data/models/user_models.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Import for MediaType

class UserService {
  // URL base desde variables de entorno
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  // Método para registrar un usuario sin foto de perfil
  Future<UserRegistrationResponse> registerUser(UserRegistration user) async {
    try {
      // Construir la URL para el endpoint de registro
      final url = Uri.parse('$baseUrl/auth');

      print('🔍 Enviando petición de registro a: $url');

      // Convertir modelo a JSON y realizar la petición HTTP POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      print('📤 Datos enviados: ${user.toJson()}');

      // Verificar si la respuesta es exitosa (código 2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Registro exitoso: ${response.body}');

        // Decodificar la respuesta JSON
        final Map<String, dynamic> data = json.decode(response.body);
        return UserRegistrationResponse.fromJson(data);
      } else {
        print(
          '❌ Error en el registro: ${response.statusCode} - ${response.body}',
        );

        // Intentar extraer mensaje de error de la respuesta
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              'Error en el registro (${response.statusCode})';
          return UserRegistrationResponse.error(errorMessage);
        } catch (parseError) {
          // Si no se puede parsear la respuesta, devolver error genérico
          return UserRegistrationResponse.error(
            'Error en el registro (${response.statusCode}): ${response.reasonPhrase}',
          );
        }
      }
    } catch (e) {
      print('❌ Excepción durante el registro: $e');
      return UserRegistrationResponse.error('Error de conexión: $e');
    }
  }

  // Método para registrar un usuario con foto de perfil
  Future<UserRegistrationResponse> registerUserWithImage({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String password,
    required String organizacionCodigo,
    required File profileImage,
  }) async {
    try {
      // Construir la URL para el endpoint de registro con imagen
      final url = Uri.parse('$baseUrl/auth/with-image');

      print('🔍 Enviando petición de registro con imagen a: $url');

      // Crear una solicitud multipart
      final request = http.MultipartRequest('POST', url);

      // Agregar datos de texto
      request.fields['nombre'] = nombre;
      request.fields['apellido'] = apellido;
      request.fields['correo'] = correo;
      request.fields['telefono'] = telefono;
      request.fields['password'] = password;
      request.fields['organizacionCodigo'] = organizacionCodigo;

      // Determinar el tipo MIME de la imagen
      final fileName = path.basename(profileImage.path);
      final mimeType =
          lookupMimeType(profileImage.path) ??
          'image/jpeg'; // Default a JPEG si no se puede determinar

      print('📤 Archivo: $fileName, Tipo MIME: $mimeType');

      // Agregar la imagen con el tipo MIME correcto
      final imageStream = http.ByteStream(profileImage.openRead());
      final imageLength = await profileImage.length();

      final imageField = http.MultipartFile(
        'profileImage',
        imageStream,
        imageLength,
        filename: fileName,
        contentType: MediaType.parse(
          mimeType,
        ), // Especificar el tipo MIME correcto
      );

      request.files.add(imageField);

      print('📤 Enviando formulario multipart con imagen...');

      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Verificar si la respuesta es exitosa (código 2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Registro con imagen exitoso: ${response.body}');

        // Decodificar la respuesta JSON
        final Map<String, dynamic> data = json.decode(response.body);
        return UserRegistrationResponse.fromJson(data);
      } else {
        print(
          '❌ Error en el registro con imagen: ${response.statusCode} - ${response.body}',
        );

        // Intentar extraer mensaje de error de la respuesta
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              'Error en el registro (${response.statusCode})';
          return UserRegistrationResponse.error(errorMessage);
        } catch (parseError) {
          // Si no se puede parsear la respuesta, devolver error genérico
          return UserRegistrationResponse.error(
            'Error en el registro (${response.statusCode}): ${response.reasonPhrase}',
          );
        }
      }
    } catch (e) {
      print('❌ Excepción durante el registro con imagen: $e');
      return UserRegistrationResponse.error('Error de conexión: $e');
    }
  }

  // Método para obtener el perfil de un usuario
  Future<UserProfile?> getUserProfile(int userId) async {
    try {
      // Construir la URL para el endpoint de usuario
      final url = Uri.parse('$baseUrl/usuarios/$userId');

      print('🔍 Obteniendo perfil de usuario con ID $userId: $url');

      // Realizar la petición HTTP GET
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Respuesta del servidor - Código: ${response.statusCode}');

      // Verificar si la respuesta es exitosa (código 2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Perfil obtenido exitosamente: ${response.body}');

        // Decodificar la respuesta JSON
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        print(
          '❌ Error al obtener perfil: ${response.statusCode} - ${response.body}',
        );

        // Intentar mostrar detalles del error si hay una respuesta JSON
        try {
          final errorData = json.decode(response.body);
          print('📋 Detalles del error: $errorData');
        } catch (e) {
          // Si no es JSON, mostrar el cuerpo de la respuesta tal cual
          print('📋 Cuerpo de la respuesta: ${response.body}');
        }

        return null;
      }
    } catch (e) {
      print('❌ Excepción al obtener perfil de usuario: $e');
      return null;
    }
  }

  // Método para obtener el perfil de un conductor
  Future<UserProfile?> getDriverProfile(int driverId) async {
    try {
      // Construir la URL para el endpoint de conductor
      final url = Uri.parse('$baseUrl/conductores/$driverId');

      print('🔍 Obteniendo perfil de conductor con ID $driverId: $url');

      // Realizar la petición HTTP GET
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Respuesta del servidor - Código: ${response.statusCode}');

      // Verificar si la respuesta es exitosa (código 2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Perfil de conductor obtenido exitosamente: ${response.body}');

        // Decodificar la respuesta JSON
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        print(
          '❌ Error al obtener perfil de conductor: ${response.statusCode} - ${response.body}',
        );

        // Intentar mostrar detalles del error si hay una respuesta JSON
        try {
          final errorData = json.decode(response.body);
          print('📋 Detalles del error: $errorData');
        } catch (e) {
          // Si no es JSON, mostrar el cuerpo de la respuesta tal cual
          print('📋 Cuerpo de la respuesta: ${response.body}');
        }

        return null;
      }
    } catch (e) {
      print('❌ Excepción al obtener perfil de conductor: $e');
      return null;
    }
  }
}
