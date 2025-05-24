import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/data/models/passenger_trips_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/presentation/activity_screens/active_trip_details.dart';

class ActiveTripsScreen extends StatefulWidget {
  const ActiveTripsScreen({super.key});

  @override
  State<ActiveTripsScreen> createState() => _ActiveTripsScreenState();
}

class _ActiveTripsScreenState extends State<ActiveTripsScreen> {
  final TripService _tripService = TripService();
  // Initialize with a value right away
  late Future<List<PassengerTrip>> _tripsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    // Initialize date formatting and then set the future
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() {
          _tripsFuture = _getPassengerTrips();
        });
      }
    });
  }

  Future<List<PassengerTrip>> _getPassengerTrips() async {
    try {
      return await _tripService.getPassengerTrips();
    } catch (e) {
      print('Error in screen fetching passenger trips: $e');

      // Check if this is the "no trips found" error by looking for the specific message
      if (e.toString().contains("No se encontraron viajes") ||
          e.toString().contains("no data array found")) {
        // Just return an empty list for "no trips found" errors
        return [];
      }

      // For other errors, rethrow so the error UI is shown
      rethrow;
    }
  }

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
        title: const Text('Mis Viajes Activos'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _tripsFuture = _getPassengerTrips();
          });
        },
        child: FutureBuilder<List<PassengerTrip>>(
          future: _tripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar los viajes: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tripsFuture = _getPassengerTrips();
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron viajes activos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes viajes iniciados o por iniciar en este momento.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final trips = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) => _buildTripCard(trips[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripCard(PassengerTrip trip) {
    final statusColor = _getStatusColor(trip.estado);

    // Format trip details
    final dateFormat = DateFormat('EEEE, d MMMM, y', 'es_ES');
    final DateTime tripDate = DateFormat('yyyy-MM-dd').parse(trip.viaje.fecha);
    final String formattedDate = dateFormat.format(tripDate);
    final String capitalizedDate = formattedDate.substring(0, 1).toUpperCase() + formattedDate.substring(1);

    // Format time
    final String formattedTime = trip.viaje.horaInicio.substring(0, 5);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveTripDetailsScreen(trip: trip),
          ),
        );
      },
      child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip status header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(trip.viaje.estado),
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusText(trip.viaje.estado),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trip.estado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Driver info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        image: trip.viaje.fotoConductor != null
                            ? DecorationImage(
                          image: NetworkImage(trip.viaje.fotoConductor!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: trip.viaje.fotoConductor == null
                          ? Icon(Icons.person, size: 36, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trip.viaje.nombreConductor} ${trip.viaje.apellidoConductor}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.car_rental, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.viaje.vehiculoMarca} ${trip.viaje.vehiculoModelo} - ${trip.viaje.vehiculoColor}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                trip.viaje.vehiculoPlaca,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Trip details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles del viaje',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _detailRow(Icons.calendar_today, 'Fecha', capitalizedDate),
                    const SizedBox(height: 8),
                    _detailRow(Icons.access_time, 'Hora de salida', formattedTime),
                    const SizedBox(height: 8),
                    _detailRow(Icons.location_on, 'Origen', trip.viaje.direccionOrigen),
                    const SizedBox(height: 8),
                    _detailRow(Icons.location_on_outlined, 'Destino', trip.viaje.direccionDestino),
                    const SizedBox(height: 8),
                    _detailRow(
                        Icons.event_seat,
                        'Asientos',
                        '${trip.asientosSolicitados} asiento${trip.asientosSolicitados > 1 ? "s" : ""} reservado${trip.asientosSolicitados > 1 ? "s" : ""}'
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                        Icons.attach_money,
                        'Precio',
                        '\$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(trip.viaje.precioAsiento * trip.asientosSolicitados)} COP'
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                        Icons.payments,
                        'Estado de pago',
                        trip.pagoRealizado ? 'Pagado' : 'Pendiente de pago'
                    ),
                  ],
                ),
              ),

              // Actions
              if (_shouldShowActions(trip.estado, trip.viaje.estado))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          // Then replace the existing "Cancelar reserva" button code with this:
                      if (trip.estado == 'ACEPTADO' || trip.estado == 'PENDIENTE')
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar cancelación'),
                                  content: const Text('¿Estás seguro de que deseas cancelar esta reserva? Esta acción no se puede deshacer.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('No, mantener reserva'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Sí, cancelar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ) ?? false;

                            if (confirmed && mounted) {
                              try {
                                final bool success = await _tripService.cancelReservation(
                                  tripId: trip.viaje.id,
                                );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reserva cancelada correctamente')),
                                  );

                                  // Reemplaza la pantalla actual por una nueva instancia
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ActiveTripsScreen()),
                                  );
                                   // Go back to the previous screen
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al cancelar la reserva: ${e.toString()}')),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cancel),
                          label: const Text(
                            'Cancelar reserva',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACEPTADO':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.amber;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String tripState) {
    switch (tripState) {
      case 'iniciado':
        return Icons.directions_car_filled;
      case 'por iniciar':
        return Icons.schedule;
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String tripState) {
    switch (tripState) {
      case 'iniciado':
        return 'Viaje en curso';
      case 'por iniciar':
        return 'Viaje programado';
      case 'finalizado':
        return 'Viaje finalizado';
      case 'cancelado':
        return 'Viaje cancelado';
      default:
        return 'Estado desconocido';
    }
  }

  bool _shouldShowActions(String reservationState, String tripState) {
    return (reservationState == 'PENDIENTE' || reservationState == 'ACEPTADO');
  }
}