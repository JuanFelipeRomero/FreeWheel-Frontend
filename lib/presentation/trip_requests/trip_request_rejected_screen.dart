import 'package:flutter/material.dart';

class TripRequestRejectedScreen extends StatelessWidget {
  final String passengerName;

  const TripRequestRejectedScreen({super.key, required this.passengerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeWheel'), // As per the image
        automaticallyImplyLeading:
            false, // To prevent back button if not desired
        centerTitle: false, // Align title to the left like in the image
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(
                  15,
                ), // Adjusted padding for the X icon
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade700, width: 3),
                ),
                child: Icon(Icons.close, color: Colors.red.shade700, size: 60),
              ),
              const SizedBox(height: 40),
              Text(
                'Has rechazado el viaje de $passengerName',
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
                  minimumSize: const Size(
                    200,
                    50,
                  ), // Fixed width, not double.infinity
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Pop this screen
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
