import 'package:flutter/material.dart';

class TripRequestAcceptedScreen extends StatelessWidget {
  final String passengerName;

  const TripRequestAcceptedScreen({super.key, required this.passengerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade700,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Has aceptado el viaje de $passengerName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Navigate back to the requests list, potentially refreshing it.
                  // Assuming 2 pops: 1 for this screen, 1 for the previous list item detail if any.
                  // Or, if navigating directly from the list, just one pop.
                  // For simplicity, let's pop once. The list re-fetches on _acceptRequest.
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Volver a solicitudes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
