import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/data/services/register_vehicle_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DriverService {
  final AuthService _authService = AuthService();
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<bool> registerDriverWithLicense(File frontLicenseImage, File backLicenseImage) async {
    try {
      final userData = await _authService.getUserData();
      final userId = userData?['id'];

      if (userId == null) {
        throw Exception('No se pudo obtener la información del usuario');
      }

      final uri = Uri.parse('$baseUrl/conductores/registrar-con-licencia');
      final request = http.MultipartRequest('POST', uri);

      // Agregar el usuario_id
      request.fields['usuarioId'] = userId.toString();

      // Agregar las imagenes de la licencia
      request.files.add(await http.MultipartFile.fromPath(
        'licenciaFrontal',
        frontLicenseImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'licenciaTrasera',
        backLicenseImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Agregar el authorization header
      final token = await _authService.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Enviar la request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response to get driver data
        final responseData = await response.stream.bytesToString();
        final driverData = jsonDecode(responseData);

        // Log the driver data for debugging
        print('Driver response data: $driverData');

        // Save driver data for later use in vehicle registration
        await VehicleService.saveDriverData(driverData);

        return true;
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('Error en la solicitud: ${response.statusCode}, $responseData');
      }
    } catch (e) {
      print('Error registering driver: $e');
      rethrow; // Rethrow to handle in UI
    }
  }
}