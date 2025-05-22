import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/presentation/screens/passenger_profile_screen.dart';

import '../trip_requests/trip_request_error.dart';
import '../trip_requests/trip_request_successfull.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del viaje',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content with trip details (scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Space for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with price and date information
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20, top: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormat.format(trip.precioAsiento),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'por asiento',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trip.fecha,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            trip.horaInicio.length >= 5
                                ? trip.horaInicio.substring(0, 5)
                                : trip.horaInicio,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Origin and destination
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ruta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          children: [
                            Icon(
                              FontAwesomeIcons.locationDot,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey.shade300,
                            ),
                            Icon(
                              FontAwesomeIcons.locationDot,
                              color: Colors.red.shade400,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.direccionOrigen,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                trip.direccionDestino,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Driver information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conductor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerProfileScreen(
                              userId: trip.conductorId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                trip.fotoConductor.isNotEmpty
                                    ? trip.fotoConductor
                                    : 'https://ui-avatars.com/api/?name=${trip.nombreConductor}+${trip.apellidoConductor}&background=random',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${trip.nombreConductor} ${trip.apellidoConductor}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      Text(
                                        "Ver mas detalles",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Vehicle information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehículo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (trip.vehiculoFoto.isNotEmpty)
                            CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: trip.vehiculoFoto.isNotEmpty
                            ? NetworkImage(trip.vehiculoFoto)
                                : null,
                            child: trip.vehiculoFoto.isEmpty
                            ? Icon(
                            FontAwesomeIcons.car,
                            size: 30,
                            color: Colors.grey,
                            )
                                : null,
                            )
                          else
                            Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.car,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${trip.vehiculoMarca} ${trip.vehiculoModelo}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildVehicleInfo(
                                        FontAwesomeIcons.palette,
                                        trip.vehiculoColor
                                    ),
                                    const SizedBox(width: 16),
                                    _buildVehicleInfo(
                                        FontAwesomeIcons.car,
                                        trip.vehiculoTipo
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildVehicleInfo(
                                    FontAwesomeIcons.idCard,
                                    'Placa: ${trip.vehiculoPlaca}'
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Available seats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asientos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${trip.asientosDisponibles}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Solicitados',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${trip.asientosSolicitados ?? 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // Fixed button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24,16,24,18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        currencyFormat.format(
                          trip.precioAsiento * (trip.asientosSolicitados ?? 1),
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _reserveSeat(context, trip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reservar ${trip.asientosSolicitados ?? 1} ${(trip.asientosSolicitados ?? 1) > 1 ? 'asientos' : 'asiento'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  void _reserveSeat(BuildContext context, Trip trip) async {
    final TripService tripService = TripService();

    final int seatsToRequest = trip.asientosSolicitados ?? 1;

    // Validate if there are enough seats available
    if (trip.asientosDisponibles < seatsToRequest) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationErrorScreen(
              message: 'No hay suficientes asientos disponibles para esta solicitud.',
              onDismiss: () {
                Navigator.pop(context); // Close error screen
              },
            ),
          ),
        );
      }
      return;
    }

    // Log the data that will be sent in the request
    print('📤 RESERVA - Enviando solicitud con datos:');
    print('📤 RESERVA - Viaje ID: ${trip.id}');
    print('📤 RESERVA - Asientos solicitados: $seatsToRequest');
    print('📤 RESERVA - Origen: ${trip.direccionOrigen}');
    print('📤 RESERVA - Destino: ${trip.direccionDestino}');
    print('📤 RESERVA - Conductor: ${trip.nombreConductor} ${trip.apellidoConductor} (ID: ${trip.conductorId})');

    try {
      final bool success = await tripService.requestSeatReservation(
        tripId: trip.id,
        seatsRequested: seatsToRequest,
      );

      print('📥 RESERVA - Respuesta: ${success ? "Exitosa" : "Fallida"}');

      if (success && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationSuccessScreen(
              message: 'Solicitud de reserva por $seatsToRequest ${seatsToRequest > 1 ? "asientos" : "asiento"} enviada correctamente.\n\nEl conductor recibirá tu solicitud y te notificará cuando sea aceptada.',
              onDismiss: () {
                Navigator.pop(context); // Close success screen
                Navigator.pop(context); // Return to trip list screen
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ RESERVA - Error: $e');

      // Extract error message from JSON response
      String errorMessage = 'No se pudo procesar tu solicitud';

      if (e.toString().contains('Failed to request seat reservation:')) {
        try {
          // Extract the JSON part from the exception message
          String jsonStr = e.toString().split('Failed to request seat reservation: ')[1];
          Map<String, dynamic> errorResponse = json.decode(jsonStr);

          if (errorResponse.containsKey('error')) {
            errorMessage = errorResponse['error'];
          }
        } catch (parseError) {
          print('Error parsing error response: $parseError');
        }
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationErrorScreen(
              message: errorMessage,
              onDismiss: () {
                Navigator.pop(context); // Close error screen
              },
            ),
          ),
        );
      }
    }
  }

// Success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Reduced bottom padding
          title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'Solicitud enviada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(2, 8, 2, 8), // Reduced vertical padding
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to trip list screen
                },
                child: Text(
                  'Aceptar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

// Error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Reduced bottom padding
          backgroundColor: Colors.white,
          title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8), // Reduced vertical padding
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to trip list screen
                },
                child: Text(
                  'Aceptar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}