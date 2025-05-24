import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/presentation/screens/rate_trip_screen.dart';
import 'package:intl/intl.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<int, bool> _tripRatingStatus = {}; // Track which trips have been rated

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
  }

  Future<void> _loadTripHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = await _authService.getUserData();
      if (userData == null || userData['id'] == null) {
        throw Exception('Usuario no encontrado');
      }

      final userId = userData['id'] as int;
      final trips = await _tripService.getTripHistory(
        userId: userId,
        esConductor: false, // Por defecto, buscar como pasajero
      );

      setState(() {
        _trips = trips;
        _isLoading = false;
      });

      // Check rating status for completed trips
      await _checkRatingStatusForTrips(trips);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkRatingStatusForTrips(List<Trip> trips) async {
    for (final trip in trips) {
      if (_isTripCompleted(trip.estado)) {
        try {
          final hasRated = await _tripService.hasRatedTrip(trip.id);
          setState(() {
            _tripRatingStatus[trip.id] = hasRated;
          });
        } catch (e) {
          print('Error checking rating status for trip ${trip.id}: $e');
          // In case of error, assume it's not rated to show the button
          setState(() {
            _tripRatingStatus[trip.id] = false;
          });
        }
      }
    }
  }

  bool _isTripCompleted(String estado) {
    return estado.toUpperCase() == 'COMPLETADO' ||
        estado.toUpperCase() == 'FINALIZADO';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de viajes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

    if (_trips.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildTripList(context);
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.triangleExclamation,
            size: 60,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Error al cargar el historial',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _loadTripHistory,
            icon: const Icon(FontAwesomeIcons.arrowRotateRight),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.clockRotateLeft,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes viajes en tu historial',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aquí aparecerán tus viajes completados',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.arrowLeft),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTripHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _buildTripCard(context, trip);
        },
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    // Parse fecha y hora con formateo manual en español
    String formattedDate = trip.fecha;
    try {
      final tripDate = DateTime.parse(trip.fecha);
      // Formatear fecha manualmente en español
      final months = [
        '',
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic',
      ];
      formattedDate =
          '${tripDate.day} ${months[tripDate.month]} ${tripDate.year}';
    } catch (e) {
      print('Error parsing date: ${trip.fecha}');
    }

    // Check if trip is completed and needs rating
    final isCompleted = _isTripCompleted(trip.estado);
    final hasRated =
        _tripRatingStatus[trip.id] ??
        true; // Default to true to hide button until we know for sure
    final shouldShowRatingButton = isCompleted && !hasRated;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Column(
        children: [
          // Sección superior con fecha y estado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(trip.estado).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${trip.horaInicio} - ${trip.horaFin}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.estado),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(trip.estado),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sección de rutas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Origen
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        trip.direccionOrigen,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Línea conectora
                Row(
                  children: [
                    const SizedBox(width: 6),
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Destino
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        trip.direccionDestino,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Información adicional
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.user,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${trip.nombreConductor} ${trip.apellidoConductor}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormat.format(trip.precioAsiento),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Rating button for completed trips
                if (shouldShowRatingButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(trip),
                      icon: const Icon(FontAwesomeIcons.star, size: 16),
                      label: const Text('Calificar viaje'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Trip trip) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RateTripScreen(trip: trip)),
    );

    // Si la calificación fue exitosa, actualizar el estado local
    if (result == true) {
      setState(() {
        _tripRatingStatus[trip.id] = true; // Marcar como calificado
      });
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'COMPLETADO':
      case 'FINALIZADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'EN_CURSO':
        return Colors.blue;
      case 'PENDIENTE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String estado) {
    switch (estado.toUpperCase()) {
      case 'COMPLETADO':
      case 'FINALIZADO':
        return 'Completado';
      case 'CANCELADO':
        return 'Cancelado';
      case 'EN_CURSO':
        return 'En curso';
      case 'PENDIENTE':
        return 'Pendiente';
      default:
        return estado;
    }
  }
}
