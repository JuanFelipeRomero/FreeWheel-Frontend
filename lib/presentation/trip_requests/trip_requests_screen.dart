import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_request.dart'; // Import the moved TripRequest model
import 'package:freewheel_frontend/data/services/trip_service.dart'; // Import TripService
import 'package:freewheel_frontend/presentation/trip_requests/passenger_details_screen.dart';
import 'package:freewheel_frontend/presentation/trip_requests/trip_request_accepted_screen.dart'; // Import the new screen
import 'package:freewheel_frontend/presentation/trip_requests/trip_request_rejected_screen.dart'; // Import the new screen

class TripRequestsScreen extends StatefulWidget {
  const TripRequestsScreen({super.key, this.tripId});

  final String?
  tripId; // Still can be used to filter if needed, though new service fetches all for driver

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  final TripService _tripService = TripService();
  late Future<List<TripRequest>> _tripRequestsFuture;
  bool _isProcessing = false; // To prevent multiple submissions
  String?
  _currentlyProcessingRequestId; // Assuming you add _currentlyProcessingRequestId state

  @override
  void initState() {
    super.initState();
    _tripRequestsFuture = _fetchTripRequests();
  }

  Future<List<TripRequest>> _fetchTripRequests() async {
    try {
      // If a specific tripId is provided to the screen, and you want to filter client-side:
      // You might want to adjust the service or filter here if the API doesn't support it directly.
      // For now, this fetches all requests for the driver.
      final allRequests = await _tripService.getTripRequestsForDriver();
      if (widget.tripId != null) {
        return allRequests.where((req) => req.tripId == widget.tripId).toList();
      }
      return allRequests;
    } catch (e) {
      print('Error fetching trip requests for screen: $e');
      // Rethrow to be caught by FutureBuilder, or handle error state differently
      rethrow;
    }
  }

  Future<void> _acceptRequest(TripRequest request) async {
    if (_isProcessing) return; // Prevent multiple clicks
    setState(() {
      _isProcessing = true;
      _currentlyProcessingRequestId = request.id;
    });

    try {
      final success = await _tripService.acceptTripRequest(request.id);
      if (success && mounted) {
        // Navigate to the success screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => TripRequestAcceptedScreen(
                  passengerName: request.passengerName,
                ),
          ),
        );
        // Refresh the list of requests
        setState(() {
          _tripRequestsFuture = _fetchTripRequests();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept request. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error accepting request: $e');
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _currentlyProcessingRequestId = null;
      });
    }
  }

  Future<void> _rejectRequest(TripRequest request) async {
    if (_isProcessing) return; // Prevent multiple clicks
    setState(() {
      _isProcessing = true;
      _currentlyProcessingRequestId =
          request.id; // Track which item is being processed
    });

    try {
      final success = await _tripService.rejectTripRequest(request.id);
      if (success && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => TripRequestRejectedScreen(
                  passengerName: request.passengerName,
                ),
          ),
        );
        // Refresh the list of requests
        setState(() {
          _tripRequestsFuture = _fetchTripRequests();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject request. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error rejecting request: $e');
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _currentlyProcessingRequestId = null; // Reset after operation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tripId == null
              ? 'Solicitudes de viaje'
              : 'Requests for My Trip ${widget.tripId}',
        ),
      ),
      body: FutureBuilder<List<TripRequest>>(
        future: _tripRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading requests: ${snapshot.error}. Please try again later.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                widget.tripId == null
                    ? 'No pending requests at the moment.'
                    : 'No pending requests for this specific trip.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final requestsToShow = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requestsToShow.length,
            itemBuilder: (context, index) {
              final request = requestsToShow[index];
              final bool isPending = request.status == 'PENDIENTE';
              final bool isAccepted = request.status == 'ACEPTADO';
              final bool isRejected = request.status == 'RECHAZADO';

              // Get status color
              final Color statusColor = isPending
                  ? Colors.blue
                  : isAccepted
                  ? Colors.green
                  : Colors.red;

              return GestureDetector(
                onTap: () async {
                  // Navigate to passenger details screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassengerDetailsScreen(request: request),
                    ),
                  );

                  // Handle the result if the user took action in the details screen
                  if (result != null && result is Map<String, dynamic>) {
                    if (result['action'] == 'accept' && result['id'] == request.id) {
                      await _acceptRequest(request);
                    } else if (result['action'] == 'reject' && result['id'] == request.id) {
                      await _rejectRequest(request);
                    }
                  }
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
                      // Header with passenger info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: statusColor.withOpacity(0.2),
                              child: Text(
                                request.passengerName.isNotEmpty ?
                                request.passengerName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.passengerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.event_seat, size: 14, color: Colors.grey[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${request.requestedSeats ?? 1} asientos',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      request.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trip details section
                      Container(
                        padding: const EdgeInsets.fromLTRB(24,16,24,16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del viaje',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                                Icons.location_on,
                                'Origen',
                                request.origin ?? 'No disponible'
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                                Icons.location_on_outlined,
                                'Destino',
                                request.destination ?? 'No disponible'
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                                Icons.calendar_today,
                                'Fecha',
                                request.departureDate ?? 'No disponible'
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                                Icons.access_time,
                                'Hora',
                                request.departureTime ?? 'No disponible'
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      if (isPending)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _acceptRequest(request),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _rejectRequest(request),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  isAccepted ? Icons.check_circle : Icons.cancel,
                                  color: isAccepted ? Colors.green : Colors.red,
                                  size: 36,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAccepted ? 'Aceptado' : 'Rechazado',
                                  style: TextStyle(
                                    color: isAccepted ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Loading indicator
                      if (_isProcessing && request.id == _currentlyProcessingRequestId)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
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

}
