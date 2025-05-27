import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/state/trip_state.dart';
import 'package:freewheel_frontend/presentation/screens/finalize_trip_screen.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActiveTripScreen extends StatefulWidget {
  final Trip trip;

  const ActiveTripScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  late Timer _timer;

  String get _formattedTime {
    final tripState = Provider.of<TripState>(context, listen: false);
    if (tripState.tripStartTime == null) {
      return "00:00:00"; // Default or loading state
    }
    final duration = DateTime.now().difference(tripState.tripStartTime!);
    final hours = (duration.inSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((duration.inSeconds % 3600) ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    Provider.of<TripState>(context, listen: false).setActiveTrip(widget.trip);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.route,
                size: 60,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Viaje en curso',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                _formattedTime,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildLocationRow(
                FontAwesomeIcons.mapPin,
                widget.trip.direccionOrigen,
                Colors.green,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: FaIcon(
                  FontAwesomeIcons.ellipsisVertical,
                  size: 24,
                  color: Colors.grey.shade400,
                ),
              ),
              _buildLocationRow(
                FontAwesomeIcons.flagCheckered,
                widget.trip.direccionDestino,
                Colors.redAccent,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(
                    FontAwesomeIcons.solidCircleCheck,
                    size: 20,
                  ),
                  label: const Text(
                    'Finalizar viaje',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FinalizeTripScreen(
                              trip: widget.trip,
                              totalAmount: widget.trip.precioAsiento,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
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

  Widget _buildLocationRow(IconData icon, String location, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
