import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_request.dart'; // Import the moved TripRequest model
import 'package:freewheel_frontend/data/services/trip_service.dart'; // Import TripService
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
              ? 'All My Trip Requests'
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
            itemCount: requestsToShow.length,
            itemBuilder: (context, index) {
              final request = requestsToShow[index];
              final bool isPending = request.status == 'PENDIENTE';
              final bool isAccepted = request.status == 'ACEPTADO';
              final bool isRejected = request.status == 'RECHAZADO';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(request.passengerName),
                  subtitle: Text(
                    'Trip ID: ${request.tripId} (Req ID: ${request.id})\nStatus: ${request.status}',
                  ),
                  trailing:
                      _isProcessing &&
                              request.id == _currentlyProcessingRequestId
                          ? const CircularProgressIndicator()
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPending)
                                TextButton(
                                  onPressed: () => _acceptRequest(request),
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              if (isAccepted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  semanticLabel: 'Accepted',
                                ),
                              if (isPending) const SizedBox(width: 8),
                              if (isPending)
                                TextButton(
                                  onPressed: () => _rejectRequest(request),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              if (isRejected)
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  semanticLabel: 'Rejected',
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
}
