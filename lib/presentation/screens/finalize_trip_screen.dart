import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/data/state/trip_state.dart';
import 'package:provider/provider.dart';

class FinalizeTripScreen extends StatefulWidget {
  final Trip trip;
  final double totalAmount; // Assuming a double for the amount

  const FinalizeTripScreen({
    Key? key,
    required this.trip,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<FinalizeTripScreen> createState() => _FinalizeTripScreenState();
}

class _FinalizeTripScreenState extends State<FinalizeTripScreen> {
  bool _isLoading = false;
  final TripService _tripService = TripService();

  Future<void> _finalizeTrip() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _tripService.finalizeTrip(widget.trip.id);

      Provider.of<TripState>(context, listen: false).clearActiveTrip();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje finalizado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        int popCount = 0;
        Navigator.of(context).popUntil((route) {
          return popCount++ == 2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar el viaje: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '\$${widget.totalAmount.toStringAsFixed(0)}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Finalizar Viaje'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Cada pasajero debe pagar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                formattedAmount,
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizeTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            'Terminar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
