// dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateTripResponse {
  final bool success;
  final String message;
  CreateTripResponse({required this.success, required this.message});
}

class CreateTripService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<CreateTripResponse> createTrip({
    required String conductorId,
    required String fecha,
    required String horaInicio,
    String? horaFin,
    required double precioAsiento,
    required int asientosDisponibles,
    required String direccionOrigen,
    required double latitudOrigen,
    required double longitudOrigen,
    required String direccionDestino,
    required double latitudDestino,
    required double longitudDestino,
    required String estado,
  }) async {
    final url = Uri.parse('$baseUrl/viajes/crear');
    final requestBody = {
      'conductorId': conductorId,
      'fecha': fecha,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'precioAsiento': precioAsiento,
      'asientosDisponibles': asientosDisponibles,
      'direccionOrigen': direccionOrigen,
      'latitudOrigen': latitudOrigen,
      'longitudOrigen': longitudOrigen,
      'direccionDestino': direccionDestino,
      'latitudDestino': latitudDestino,
      'longitudDestino': longitudDestino,
      'estado': estado,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CreateTripResponse(
        success: true,
        message: data['message'] ?? 'Trip created successfully',
      );
    } else {
      return CreateTripResponse(
        success: false,
        message: 'Failed to create trip: ${response.statusCode} - ${response.body}',
      );
    }
  }
}