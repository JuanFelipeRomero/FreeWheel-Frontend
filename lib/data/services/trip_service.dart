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
  }) async {
    try {
      // Formato de fecha para la API (dd/MM/yyyy)
      final dateFormatter = DateFormat('dd/MM/yyyy');
      final formattedDate = dateFormatter.format(date);

      // Construir la URL con los parámetros
      final url = Uri.parse(
        '$baseUrl/viajes/buscar?'
        'latitudOrigenBusqueda=$originLat'
        '&longitudOrigenBusqueda=$originLng'
        '&latitudDestinoBusqueda=$destinationLat'
        '&longitudDestinoBusqueda=$destinationLng'
        '&fecha=$formattedDate'
        '&radioBusquedaKm=$searchRadiusKm'
        '&numeroAsientosRequeridos=$requiredSeats',
      );

      print('🔍 Enviando petición a: $url');

      // Realizar la petición HTTP
      final response = await http.get(url);

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
