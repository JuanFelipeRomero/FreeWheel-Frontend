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

      // Log the complete driver data for debugging
      print('Complete driver data: $driverData');
      print('Driver ID being used: $driverId');

      final uri = Uri.parse('$baseUrl/vehiculos/registrar-con-documentos');
      print('API endpoint: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['placa'] = placa.trim();
      request.fields['marca'] = marca.trim();
      request.fields['modelo'] = modelo.trim();
      request.fields['anio'] = anio.trim();
      request.fields['color'] = color.trim();
      request.fields['tipo'] = tipo.trim();
      request.fields['capacidadPasajeros'] = capacidadPasajeros.trim();
      request.fields['conductorId'] = driverId.toString();

      print('Request fields: ${request.fields}');

      // Add files with proper content types
      final licenciaTransitoFile = await http.MultipartFile.fromPath(
        'licenciaTransito',
        licenciaTransito.path,
        contentType: MediaType('image', 'jpeg'),
      );

      final soatFile = await http.MultipartFile.fromPath(
        'soat',
        soat.path,
        contentType: MediaType('application', 'pdf'),
      );

      final certificadoRevisionFile = await http.MultipartFile.fromPath(
        'certificadoRevision',
        certificadoRevision.path,
        contentType: MediaType('application', 'pdf'),
      );

      final fotoFile = await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(licenciaTransitoFile);
      request.files.add(soatFile);
      request.files.add(certificadoRevisionFile);
      request.files.add(fotoFile);

      // Log file information
      print('Files being sent:');
      print('- licenciaTransito: length=${licenciaTransitoFile.length}, filename=${licenciaTransitoFile.filename}, content-type=${licenciaTransitoFile.contentType}');
      print('- soat: length=${soatFile.length}, filename=${soatFile.filename}, content-type=${soatFile.contentType}');
      print('- certificadoRevision: length=${certificadoRevisionFile.length}, filename=${certificadoRevisionFile.filename}, content-type=${certificadoRevisionFile.contentType}');
      print('- foto: length=${fotoFile.length}, filename=${fotoFile.filename}, content-type=${fotoFile.contentType}');

      // Check if files exist
      print('Files exist:');
      print('- licenciaTransito: ${await licenciaTransito.exists()}');
      print('- soat: ${await soat.exists()}');
      print('- certificadoRevision: ${await certificadoRevision.exists()}');
      print('- foto: ${await foto.exists()}');

      // Check file sizes
      print('File sizes:');
      print('- licenciaTransito: ${await licenciaTransito.length()} bytes');
      print('- soat: ${await soat.length()} bytes');
      print('- certificadoRevision: ${await certificadoRevision.length()} bytes');
      print('- foto: ${await foto.length()} bytes');

      // Add authorization header
      final token = await _authService.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // Log headers
      print('Request headers: ${request.headers}');

      // Send request
      print('Sending request...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Log response
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Vehicle registration successful!');
        await _authService.updateDriverStatus(true);
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