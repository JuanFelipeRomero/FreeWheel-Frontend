import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/models/trip_request.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';

import '../../presentation/activity_screens/active_trips_screen.dart';
import '../models/passenger_trips_models.dart';

class TripService {
  // URL base configurada desde las variables de entorno
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  final AuthService _authService = AuthService();

  //Metodo para obtener algunos viajes
  Future<List<Trip>> getSomeTrips() async {
    try {

      final url = Uri.parse('$baseUrl/viajes/algunos-viajes');
      print('🔍 Fetching some trips from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} trips');
        return data.map((json) => Trip.fromJson(json)).toList();
      } else {
        print('❌ Error fetching trips: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load trips (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception during fetching trips: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

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

  // Method to request seat reservation
  Future<bool> requestSeatReservation({
    required int tripId,
    required int seatsRequested,
  }) async {
    final userData = await _authService.getUserData();
    final token = await _authService.getToken();

    if (userData == null || token == null) {
      print('User not authenticated or user data/token is missing.');
      throw Exception(
        'User not authenticated. Cannot request seat reservation.',
      );
    }

    final userId = userData['id'];
    if (userId == null) {
      print('User ID not found in user data.');
      throw Exception('User ID not found. Cannot request seat reservation.');
    }

    final url = Uri.parse('$baseUrl/pasajeros/crear');
    print('📢 Requesting seat reservation: POST to $url');

    final Map<String, dynamic> requestBody = {
      "usuarioId": userId,
      "viajeId": tripId,
      "asientosSolicitados": seatsRequested,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Seat reservation requested successfully.');
        return true;
      } else {
        print(
          '❌ Error requesting seat reservation: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to request seat reservation: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during seat reservation request: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to get trip requests for a driver
  Future<List<TripRequest>> getTripRequestsForDriver() async {
    final userData = await _authService.getUserData();
    final token = await _authService.getToken();

    if (userData == null || token == null) {
      print('User not authenticated or user data/token is missing.');
      throw Exception('User not authenticated. Cannot fetch trip requests.');
    }

    // Assuming the user ID is stored with the key 'id' in userData.
    // Adjust if your key is different (e.g., '_id', 'userId').
    final userId = userData['id'];
    if (userId == null) {
      print('User ID not found in user data.');
      throw Exception('User ID not found. Cannot fetch trip requests.');
    }

    final url = Uri.parse(
      '$baseUrl/solicitudes-reserva/conductor/usuario/$userId',
    );
    print('🔍 Fetching trip requests from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        ); // Ensure UTF-8 decoding
        print('✅ Trip requests received: ${response.body}');
        return data
            .map(
              (jsonItem) =>
                  TripRequest.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
      } else {
        print(
          '❌ Error fetching trip requests: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to load trip requests (${response.statusCode})',
        );
      }
    } catch (e) {
      print('❌ Exception during fetching trip requests: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to accept a trip request
  Future<bool> acceptTripRequest(String requestId) async {
    final token = await _authService.getToken();
    if (token == null) {
      print('User not authenticated or token is missing.');
      throw Exception('User not authenticated. Cannot accept trip request.');
    }

    final url = Uri.parse(
      '$baseUrl/solicitudes-reserva/aceptar-solicitud/$requestId',
    );
    print('📢 Accepting trip request: PUT to $url');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is also a success
        print('✅ Trip request $requestId accepted successfully.');
        // The API might return the updated request or just a success status.
        // If it returns the updated object:
        // final dynamic responseData = json.decode(response.body);
        // return TripRequest.fromJson(responseData as Map<String, dynamic>);
        // For now, assuming success if status code is 200/204 and returning true.
        return true;
      } else {
        print(
          '❌ Error accepting trip request $requestId: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to accept trip request (${response.statusCode}) - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Exception during accepting trip request $requestId: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to reject a trip request
  Future<bool> rejectTripRequest(String requestId) async {
    final token = await _authService.getToken();
    if (token == null) {
      print('User not authenticated or token is missing.');
      throw Exception('User not authenticated. Cannot reject trip request.');
    }

    final url = Uri.parse(
      '$baseUrl/solicitudes-reserva/rechazar-solicitud/$requestId',
    );
    print('📢 Rejecting trip request: PUT to $url');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Trip request $requestId rejected successfully.');
        return true;
      } else {
        print(
          '❌ Error rejecting trip request $requestId: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to reject trip request (${response.statusCode}) - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Exception during rejecting trip request $requestId: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to finalize a trip
  Future<void> finalizeTrip(int tripId) async {
    final token = await _authService.getToken();
    if (token == null) {
      print('User not authenticated or token is missing.');
      // Consider throwing a specific exception type for auth errors
      throw Exception('User not authenticated. Cannot finalize trip.');
    }

    final url = Uri.parse('$baseUrl/viajes/$tripId/finalizar');
    print('📢 Finalizing trip: PUT to $url');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode({}), // Add body if required by your API
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Trip $tripId finalized successfully.');
        // No specific data needs to be returned, void is fine.
      } else {
        print(
          '❌ Error finalizing trip $tripId: ${response.statusCode} - ${response.body}',
        );
        // Consider creating custom exception types for different API errors
        throw Exception(
          'Failed to finalize trip (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Exception during finalizing trip $tripId: $e');
      // Rethrow the exception to be caught by the caller, or handle specific network errors
      throw Exception('Error connecting to the server: $e');
    }
  }

  Future<bool> startTrip(int tripId) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('$baseUrl/viajes/$tripId/iniciar');

      print('🔍 Iniciando viaje: $url');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Viaje iniciado correctamente');
        return true;
      } else {
        print(
          '❌ Error al iniciar viaje: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to start trip (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al iniciar viaje: $e');
      rethrow;
    }
  }

  Future<bool> cancelTrip(int tripId) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('$baseUrl/viajes/cancelar-conductor/$tripId');

      print('🔍 Cancelando viaje: $url');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Viaje cancelado correctamente");
        return true;
      } else {
        print(
          '❌ Error al cancelar viaje: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to cancel trip (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al cancelar viaje: $e');
      rethrow;
    }
  }

  Future<List<Trip>> getDriverTrips() async {
    try {
      final userData = await _authService.getUserData();
      final userId = userData?['id'];
      final token = await _authService.getToken();

      if (userId == null) {
        throw Exception('User ID not available');
      }

      // Print debug information
      print('🔍 Fetching driver trips with URL: $baseUrl/viajes/listar');
      print('🔍 User ID: $userId');

      final url = Uri.parse('$baseUrl/viajes/listar').replace(
        queryParameters: {'userId': userId.toString(), 'esConductor': 'true'},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Trip.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load driver trips (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching driver trips: $e');
      rethrow;
    }
  }

  // Method to get trip history for a user
  Future<List<Trip>> getTripHistory({
    required int userId,
    required bool esConductor,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      print('User not authenticated or token is missing.');
      throw Exception('User not authenticated. Cannot fetch trip history.');
    }

    final url = Uri.parse(
      '$baseUrl/viajes/listar?userId=$userId&esConductor=$esConductor',
    );
    print('🔍 Fetching trip history from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Trip history received: ${response.body}');
        return data
            .map((jsonItem) => Trip.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      } else {
        print(
          '❌ Error fetching trip history: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch trip history: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during trip history fetch: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to check if user has rated a trip
  Future<bool> hasRatedTrip(int tripId) async {
    final userData = await _authService.getUserData();
    final token = await _authService.getToken();

    if (token == null || userData == null) {
      print('User not authenticated or token/data is missing.');
      throw Exception('User not authenticated. Cannot check trip rating.');
    }

    final userId = userData['id'];
    if (userId == null) {
      print('User ID not found in user data.');
      throw Exception('User ID not found. Cannot check trip rating.');
    }

    // Debug token and user info
    print('🔐 Token for rating check: ${token.substring(0, 20)}...');
    print('🔍 User ID: $userId');

    // Try both URL formats - with and without userId parameter
    final url = Uri.parse(
      '$baseUrl/calificaciones/viaje/$tripId/ha-calificado',
    );
    print('🔍 Checking if trip $tripId has been rated: $url');

    try {
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

      print('🔍 Headers being sent: $headers');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        print('✅ Trip rating check received: ${response.body}');
        return data['haCalificado'] as bool? ?? false;
      } else {
        print(
          '❌ Error checking trip rating: ${response.statusCode} - ${response.body}',
        );
        print('🔍 Response headers: ${response.headers}');

        // Try to get more info from response body
        String responseBody = '';
        try {
          responseBody = utf8.decode(response.bodyBytes);
        } catch (e) {
          responseBody = response.body;
        }

        print('🔍 Full response body: $responseBody');
        throw Exception(
          'Failed to check trip rating (${response.statusCode}): $responseBody',
        );
      }
    } catch (e) {
      print('❌ Exception during trip rating check: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to submit a trip rating
  Future<bool> submitTripRating({
    required int tripId,
    required int rating,
    required String comment,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      print('User not authenticated or token is missing.');
      throw Exception('User not authenticated. Cannot submit trip rating.');
    }

    final url = Uri.parse('$baseUrl/calificaciones');
    print('📝 Submitting trip rating: POST to $url');

    final Map<String, dynamic> requestBody = {
      "viajeId": tripId,
      "puntuacion": rating,
      "comentario": comment,
    };

    print('📝 Rating data: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Trip rating submitted successfully.');
        return true;
      } else {
        print(
          '❌ Error submitting trip rating: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to submit trip rating: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during trip rating submission: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }

  // Method to fetch passenger trips for current user
  Future<List<PassengerTrip>> getPassengerTrips() async {
    try {
      final userData = await _authService.getUserData();
      final userId = userData?['id'];
      final token = await _authService.getToken();

      if (userId == null) {
        throw Exception('User ID not available');
      }

      final url = Uri.parse('$baseUrl/pasajeros/viajes-usuario/$userId');
      print('🔍 Fetching passenger trips with URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Debug the response
        print('Response body: ${response.body}');

        // Check if the response is a map or list
        final dynamic decodedData = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedData is Map<String, dynamic>) {
          // If it's a map, extract the data array (adjust according to your API structure)
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            final List<dynamic> data = decodedData['data'];
            return data.map((json) => PassengerTrip.fromJson(json)).toList();
          } else {
            // If there's no 'data' key but it's still a map
            throw Exception('Unexpected response format: no data array found');
          }
        } else if (decodedData is List<dynamic>) {
          // If it's already a list, use it directly
          return decodedData
              .map((json) => PassengerTrip.fromJson(json))
              .toList();
        } else {
          throw Exception('Unexpected response format: neither Map nor List');
        }
      } else {
        throw Exception(
          'Failed to load passenger trips (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching passenger trips: $e');
      rethrow;
    }
  }

  // Add this method to lib/data/services/trip_service.dart
  Future<bool> cancelReservation({required int tripId}) async {
    final userData = await _authService.getUserData();
    final token = await _authService.getToken();

    if (userData == null || token == null) {
      print('User not authenticated or user data/token is missing.');
      throw Exception('User not authenticated. Cannot cancel reservation.');
    }

    final userId = userData['id'];
    if (userId == null) {
      print('User ID not found in user data.');
      throw Exception('User ID not found. Cannot cancel reservation.');
    }

    final url = Uri.parse('$baseUrl/pasajeros/eliminar').replace(
      queryParameters: {
        'usuarioId': userId.toString(),
        'viajeId': tripId.toString(),
      },
    );

    print('🗑️ Canceling reservation: DELETE to $url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Reservation canceled successfully.');
        return true;
      } else {
        print(
          '❌ Error canceling reservation: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to cancel reservation (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Exception during reservation cancellation: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }
}
