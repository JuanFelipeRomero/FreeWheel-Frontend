import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/data/state/trip_state.dart';
import 'package:freewheel_frontend/presentation/screens/active_trip_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  final TripService _tripService = TripService();
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _tripService.getDriverTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis viajes')),
      body: FutureBuilder<List<Trip>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error en DriverTripsScreen: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar los viajes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tripsFuture = _tripService.getDriverTrips();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final trips = snapshot.data ?? [];

          if (trips.isEmpty) {
            return const Center(child: Text('No tienes viajes programados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final tripState = Provider.of<TripState>(context, listen: true);
              final bool currentTripIsActive =
                  tripState.activeTrip?.id == trip.id;
              final bool isCanceled = trip.estado == 'CANCELADO';

              // Determine button style and text based on trip status
              String buttonText = 'Comenzar viaje';
              Color buttonColor = Colors.green;
              VoidCallback? onPressed = () async {
                if (tripState.isTripActive && !currentTripIsActive) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ya tienes un viaje en curso. Finalízalo antes de iniciar uno nuevo.',
                      ),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                  try {
                    final success = await _tripService.startTrip(trip.id);
                    Navigator.pop(context); // Close loading dialog

                    if (success) {
                      tripState.setActiveTrip(trip);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveTripScreen(trip: trip),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al iniciar viaje: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              };

              if (currentTripIsActive && trip.estado == 'iniciado') {
                buttonText = 'Reanudar Viaje';
                buttonColor = Colors.blue; // Or a different color for resume
                onPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ActiveTripScreen(trip: tripState.activeTrip!),
                    ),
                  );
                };
              } else if (trip.estado == 'finalizado') {
                buttonText = 'Viaje Finalizado';
                buttonColor = Colors.grey;
                onPressed = null; // Disable button
              } else if (trip.estado == 'iniciado' && !currentTripIsActive) {
                // This case handles a trip that is 'iniciado' but not the active one.
                // This might happen if the app was closed and reopened.
                // We allow to "Reanudar" it, which will set it as active.
                buttonText = 'Reanudar Viaje (Iniciado)';
                buttonColor = Colors.orange; // A distinct color
                onPressed = () async {
                  if (tripState.isTripActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ya tienes un viaje en curso. Finalízalo antes de reanudar este.',
                        ),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                  try {
                    // No need to call _tripService.startTrip(trip.id) as it's already started.
                    // We just set it as the active trip.
                    tripState.setActiveTrip(trip);
                    Navigator.pop(context); // Close loading dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveTripScreen(trip: trip),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al reanudar viaje: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                };
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: isCanceled ? Colors.grey.shade400 : Colors.grey.shade300
                  ),
                ),
                elevation: isCanceled ? 1 : 3,
                color: isCanceled ? Colors.grey.shade200 : null,
                child: Opacity(
                  opacity: isCanceled ? 0.7 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.mapMarkerAlt,
                              color: isCanceled ? Colors.grey : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'De: ${trip.direccionOrigen}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCanceled ? Colors.grey.shade700 : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'A: ${trip.direccionDestino}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCanceled ? Colors.grey.shade700 : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isCanceled ? 'Cancelado' :
                              trip.estado == 'finalizado'
                                  ? 'Completado'
                                  : trip.estado == 'iniciado'
                                  ? 'En curso'
                                  : 'Programado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color:
                                isCanceled ? Colors.grey :
                                trip.estado == 'finalizado'
                                    ? Colors.grey
                                    : trip.estado == 'iniciado'
                                    ? Colors.blueAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.calendarAlt,
                                      size: 14,
                                      color: isCanceled ? Colors.grey : Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(DateTime.parse(trip.fecha)),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isCanceled ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.clock,
                                      size: 14,
                                      color: isCanceled ? Colors.grey : Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      trip.horaInicio,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isCanceled ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '\\\$${trip.precioAsiento.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isCanceled ? Colors.grey : Colors.green,
                              ),
                            ),
                          ],
                        ),

                        // Only show buttons for non-canceled trips
                        if (!isCanceled) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: FaIcon(
                                onPressed == null
                                    ? FontAwesomeIcons.checkCircle
                                    : currentTripIsActive && trip.estado == 'iniciado'
                                    ? FontAwesomeIcons.playCircle
                                    : FontAwesomeIcons.play,
                                size: 18,
                              ),
                              label: Text(buttonText),
                              onPressed: onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          // Show cancel button only when trip is not started or finished
                          if (trip.estado != 'iniciado' && trip.estado != 'finalizado')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.ban,
                                    size: 18,
                                  ),
                                  label: const Text('Cancelar viaje'),
                                  onPressed: () async {
                                    // Show confirmation dialog
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Center(
                                          child: Text(
                                            'Cancelar Viaje',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: const BoxDecoration(
                                                color: Colors.amber,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.warning_rounded,
                                                  size: 40,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            const Text(
                                              '¿Seguro que quieres cancelar?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Volver',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.redAccent,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Cancelar',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                                        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                        );

                                        await _tripService.cancelTrip(trip.id);

                                        Navigator.pop(context); // Close loading dialog
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Viaje cancelado correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        // Refresh trips list
                                        setState(() {
                                          _tripsFuture = _tripService.getDriverTrips();
                                        });
                                      } catch (e) {
                                        Navigator.pop(context); // Close loading dialog
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al cancelar viaje: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
