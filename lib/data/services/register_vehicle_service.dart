// lib/data/services/register_vehicle_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleService {
  final AuthService _authService = AuthService();
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  static const String _driverDataKey = 'driver_data';

  // Method to save driver data after registration
  static Future<bool> saveDriverData(Map<String, dynamic> driverData) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_driverDataKey, jsonEncode(driverData));
  }

  // Method to get driver data
  Future<Map<String, dynamic>?> getDriverData() async {
    final prefs = await SharedPreferences.getInstance();
    final driverData = prefs.getString(_driverDataKey);
    if (driverData != null && driverData.isNotEmpty) {
      return jsonDecode(driverData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> registerVehicle({
    required String placa,
    required String marca,
    required String modelo,
    required String anio,
    required String color,
    required String tipo,
    required String capacidadPasajeros,
    required File licenciaTransito,
    required File soat,
    required File certificadoRevision,
    required File foto,
  }) async {
    try {
      // Get driver data to obtain driverId
      final driverData = await getDriverData();
      final driverId = driverData?['id'];

      if (driverId == null) {
        throw Exception('No se pudo obtener la información del conductor');
      }

      // Print for debugging
      print('Driver data: $driverData');
      print('Driver ID: $driverId');

      final uri = Uri.parse('$baseUrl/vehiculos/registrar-con-documentos');
      final request = http.MultipartRequest('POST', uri);

      // Add text fields - ensure they're properly formatted as strings
      request.fields['placa'] = placa;
      request.fields['marca'] = marca;
      request.fields['modelo'] = modelo;
      request.fields['anio'] = anio;
      request.fields['color'] = color;
      request.fields['tipo'] = tipo;
      request.fields['capacidadPasajeros'] = capacidadPasajeros;
      request.fields['conductorId'] = driverId.toString();

      // Logging request fields for debugging
      print('Request fields: ${request.fields}');

      // Add files with proper content types
      request.files.add(await http.MultipartFile.fromPath(
        'licenciaTransito',
        licenciaTransito.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'soat',
        soat.path,
        contentType: MediaType('application', 'pdf'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'certificadoRevision',
        certificadoRevision.path,
        contentType: MediaType('application', 'pdf'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Add authorization header
      final token = await _authService.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Check if all files exist
      print('Files exist: ${await licenciaTransito.exists()}, ${await soat.exists()}, ${await certificadoRevision.exists()}, ${await foto.exists()}');

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Always log the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}, $responseData');
      }
    } catch (e) {
      print('Error registering vehicle: $e');
      rethrow;
    }
  }
}