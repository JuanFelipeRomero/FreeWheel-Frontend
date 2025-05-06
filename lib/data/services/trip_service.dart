import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:freewheel_frontend/data/models/trip_models.dart';

class TripService {
  // URL base configurada desde las variables de entorno
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  // Método para buscar viajes disponibles
  Future<TripSearchResponse> searchTrips({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required DateTime date,
    required int requiredSeats,
    int searchRadiusKm = 5,
    String? horaInicioDesde,
    String? horaInicioHasta,
  }) async {
    try {
      // Formato de fecha para la API (yyyy-MM-dd) - compatible con LocalDate de Java
      final dateFormatter = DateFormat('yyyy-MM-dd');
      final formattedDate = dateFormatter.format(date);

      // Construir la URL base sin parámetros
      final url = Uri.parse('$baseUrl/viajes/buscar');

      // Crear objeto JSON para el cuerpo de la solicitud
      final Map<String, dynamic> requestBody = {
        'latitudOrigenBusqueda': originLat,
        'longitudOrigenBusqueda': originLng,
        'latitudDestinoBusqueda': destinationLat,
        'longitudDestinoBusqueda': destinationLng,
        'fecha': formattedDate,
        'radioBusquedaKm': searchRadiusKm,
        'numeroAsientosRequeridos': requiredSeats,
      };

      if (horaInicioDesde != null) {
        requestBody['horaInicioDesde'] = horaInicioDesde;
      }
      if (horaInicioHasta != null) {
        requestBody['horaInicioHasta'] = horaInicioHasta;
      }

      print('🔍 Enviando petición POST a: $url');
      print('🔍 Cuerpo de la petición: ${jsonEncode(requestBody)}');

      // Realizar la petición HTTP POST con el cuerpo JSON
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Si hay un token de autorización, agregarlo aquí:
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Verificar si la respuesta es exitosa (código 200)
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        try {
          final List<dynamic> data = json.decode(response.body);
          print('✅ Respuesta recibida: ${response.body}');

          // Convertir la respuesta en nuestro modelo
          return TripSearchResponse.fromJson(data);
        } catch (parseError) {
          print('⚠️ Error al parsear la respuesta: $parseError');
          print('⚠️ Cuerpo de la respuesta: ${response.body}');

          // Si ocurre un error al parsear, devolvemos una respuesta de error
          return TripSearchResponse.error(
            'Error al procesar la respuesta: $parseError',
          );
        }
      } else {
        print(
          '❌ Error en la petición: ${response.statusCode} - ${response.body}',
        );
        return TripSearchResponse.error(
          'Error en la búsqueda (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('❌ Excepción durante la búsqueda: $e');
      return TripSearchResponse.error('Error de conexión: $e');
    }
  }
}
