import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/presentation/screens/create_trip_screen.dart';
import 'package:freewheel_frontend/presentation/screens/driver_trips_screen.dart';
import 'package:freewheel_frontend/presentation/trip_requests/trip_requests_screen.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Conductor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Panel de Conductor',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: const Text(
                'Aquí podrás gestionar tu información y tus viajes como conductor',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 32),

            // First row of cards
            Row(
              children: [
                // Viajes card
                Expanded(
                  child: _buildServiceCard(
                    context,
                    FontAwesomeIcons.car,
                    'Viajes',
                    'Ver tus viajes como conductor',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverTripsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Publicar viaje card
                Expanded(
                  child: _buildServiceCard(
                    context,
                    FontAwesomeIcons.plus,
                    'Publicar viaje',
                    'Crear un nuevo viaje',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTripScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Second row of cards
            Row(
              children: [
                // Solicitudes card
                Expanded(
                  child: _buildServiceCard(
                    context,
                    FontAwesomeIcons.bell,
                    'Solicitudes',
                    'Ver solicitudes de pasajeros',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripRequestsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Mi Vehículo card
                Expanded(
                  child: _buildServiceCard(
                    context,
                    FontAwesomeIcons.carSide,
                    'Mi Vehículo',
                    'Gestionar información del vehículo',
                        () => {print('vehiculos')},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      VoidCallback onTap,
      ) {
    return SizedBox(
      height: 220, // Fixed height for consistent card size
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        color: Colors.grey.shade50,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}