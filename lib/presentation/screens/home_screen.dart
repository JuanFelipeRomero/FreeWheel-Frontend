import 'package:flutter/material.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/presentation/screens/search_trips_screen.dart';
import 'package:freewheel_frontend/presentation/screens/trip_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TripService _tripService = TripService();
  List<Trip> _featuredTrips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeaturedTrips();
  }

  Future<void> _loadFeaturedTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final trips = await _tripService.getSomeTrips();

      setState(() {
        _featuredTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar viajes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeWheel'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeaturedTrips,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner o tarjeta principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido a FreeWheel!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Encuentra y comparte viajes de manera fácil y segura',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchTripsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buscar viajes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Título de sección
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Viajes destacados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Error message if any
              if (_errorMessage != null && !_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadFeaturedTrips,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

              // Trip list
              Expanded(
                child: _featuredTrips.isEmpty && !_isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_filled_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay viajes disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadFeaturedTrips,
                        child: const Text('Intentar de nuevo'),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _featuredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = _featuredTrips[index];

                    // Format date string
                    final date = DateTime.parse(trip.fecha);
                    final dateFormat = DateFormat.yMMMd('es_ES');

                    // Format time string
                    final timeStr = trip.horaInicio.split(':');
                    final time = TimeOfDay(
                        hour: int.parse(timeStr[0]),
                        minute: int.parse(timeStr[1])
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripDetailScreen(trip: trip)
                              )
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Origin-Destination header
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_getLocationName(trip.direccionOrigen)} → ${_getLocationName(trip.direccionDestino)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Trip details
                              Row(
                                children: [

                                  // Date and time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16),
                                            const SizedBox(width: 4),
                                            Text(dateFormat.format(date)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price and seats
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${trip.precioAsiento}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        '${trip.asientosDisponibles} asientos',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Driver info
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(trip.fotoConductor),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${trip.nombreConductor} ${trip.apellidoConductor}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      Text(' ${trip.calificacionConductor}'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to extract a shorter location name
  String _getLocationName(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return fullAddress;
  }

  // Helper method to convert time string to DateTime
  DateTime timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}