import 'package:flutter/material.dart';
import '../../data/models/trip_request.dart';

class PassengerDetailsScreen extends StatelessWidget {
  final TripRequest request;

  const PassengerDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del pasajero'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile photo/avatar
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.blue.withOpacity(0.2),
              backgroundImage: request.passengerPhoto != null && request.passengerPhoto!.isNotEmpty
                  ? NetworkImage(request.passengerPhoto!)
                  : null,
              child: (request.passengerPhoto == null || request.passengerPhoto!.isEmpty)
                  ? Text(
                request.passengerName.isNotEmpty
                    ? request.passengerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              )
                  : null,
            ),

            const SizedBox(height: 24),

            // Passenger information card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Información del pasajero",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Name
                    _infoRow(
                      Icons.person,
                      "Nombre",
                      request.passengerName,
                    ),

                    const SizedBox(height: 26),

                    _infoRow(
                      Icons.email,
                      "Correo",
                      request.passengerEmail ?? "Información no disponible",
                    ),

                    const SizedBox(height: 26),

                    _infoRow(
                      Icons.phone,
                      "Teléfono",
                      request.passengerPhone ?? "Información no disponible",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDIENTE':
        return Colors.blue;
      case 'ACEPTADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}