import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/presentation/screens/passenger_profile_screen.dart';

import '../../data/services/trip_service.dart';

class TripListScreen extends StatelessWidget {
  final List<Trip> trips;

  const TripListScreen({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Viajes disponibles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: trips.isEmpty ? _buildEmptyState(context) : _buildTripList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.faceSadTear,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay viajes disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Intenta con otros criterios de búsqueda',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.arrowLeft),
            label: const Text('Volver a buscar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(context, trip);
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Column(
        children: [
          // Sección superior con conductor e info básica
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Foto de perfil del conductor (clickable)
                GestureDetector(
                  onTap: () {
                    // Imprimir el ID del conductor para depuración
                    print(
                      '⚠️ ID del conductor que se está pasando: ${trip.conductorId}',
                    );

                    // Verificar que el ID del conductor sea válido
                    if (trip.conductorId > 0) {
                      // Navegar a la pantalla de perfil del conductor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PassengerProfileScreen(
                                userId: trip.conductorId,
                              ),
                        ),
                      );
                    } else {
                      // Mostrar un mensaje de error si el ID no es válido
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo cargar el perfil del conductor',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          trip.fotoConductor.isNotEmpty
                              ? trip.fotoConductor
                              : 'https://ui-avatars.com/api/?name=${trip.nombreConductor}+${trip.apellidoConductor}&background=random',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Información del conductor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.nombreConductor} ${trip.apellidoConductor}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.calificacionConductor.toStringAsFixed(1),
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
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(trip.precioAsiento),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'por persona',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Separador
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          // Sección principal con detalles del viaje
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Origen y destino
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            trip.direccionDestino,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Fecha, hora y asientos
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      FontAwesomeIcons.calendar,
                      trip.fecha,
                    ),
                    _buildInfoItem(
                      context,
                      FontAwesomeIcons.clock,
                      trip.horaInicio.substring(0, 5),
                    ),
                    _buildInfoItem(
                      context,
                      FontAwesomeIcons.userGroup,
                      '${trip.asientosDisponibles} asientos',
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Detalles del vehículo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.car,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${trip.vehiculoMarca} ${trip.vehiculoModelo}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.palette,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trip.vehiculoColor,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        trip.vehiculoPlaca,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de reservar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _reserveSeat(context, trip);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reservar asiento',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text, {
    bool isLast = false,
  }) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 16,
                width: 1,
                color: Colors.grey.shade300,
              ),
            ),
        ],
      ),
    );
  }



  // Add this method to the TripListScreen class
  void _reserveSeat(BuildContext context, Trip trip) async {
    final TripService tripService = TripService();

    // Get the number of seats requested by the user during search
    // If the trip doesn't have the requested seats info, default to 1
    final int seatsToRequest = trip.asientosSolicitados ?? 1;

    // Validate if there are enough seats available
    if (trip.asientosDisponibles < seatsToRequest) {
      _showDialog(
          context,
          'No hay suficientes asientos',
          'Lo sentimos, no hay suficientes asientos disponibles para esta solicitud.',
          isError: true
      );
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

      if (success) {
        _showDialog(
            context,
            'Solicitud enviada',
            'Tu solicitud de reserva por $seatsToRequest ${seatsToRequest > 1 ? "asientos" : "asiento"} ha sido enviada correctamente. El conductor recibirá tu solicitud.'
        );
      }
    } catch (e) {
      print('❌ RESERVA - Error: $e');
      _showDialog(
          context,
          'Error',
          'No se pudo procesar tu solicitud: ${e.toString()}',
          isError: true
      );
    }
  }

  // Helper method to show dialogs
  void _showDialog(BuildContext context, String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade50 : Colors.white,
          titleTextStyle: TextStyle(
            color: isError ? Colors.red.shade700 : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          contentTextStyle: TextStyle(
            color: isError ? Colors.red.shade700 : Colors.black87,
            fontSize: 16,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: isError ? Colors.red.shade700 : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
