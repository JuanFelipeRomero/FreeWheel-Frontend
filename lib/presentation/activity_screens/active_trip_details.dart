import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:freewheel_frontend/data/models/passenger_trips_models.dart';

import '../../data/services/trip_service.dart';
import 'active_trips_screen.dart';

class ActiveTripDetailsScreen extends StatefulWidget {
  final PassengerTrip trip;

  const ActiveTripDetailsScreen({super.key, required this.trip});

  @override
  State<ActiveTripDetailsScreen> createState() => _ActiveTripDetailsScreenState();
}

class _ActiveTripDetailsScreenState extends State<ActiveTripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    // Format trip date
    final dateFormat = DateFormat('EEEE, d MMMM, y', 'es_ES');
    final DateTime tripDate = DateFormat('yyyy-MM-dd').parse(widget.trip.viaje.fecha);
    final String formattedDate = dateFormat.format(tripDate);
    final String capitalizedDate = formattedDate.substring(0, 1).toUpperCase() + formattedDate.substring(1);

    // Format time
    final String formattedTime = widget.trip.viaje.horaInicio.substring(0, 5);

    final statusColor = _getStatusColor(widget.trip.estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del viaje',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.trip.viaje.estado),
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(widget.trip.viaje.estado),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estado de reserva: ${widget.trip.estado}',
                          style: TextStyle(
                            color: statusColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Header with price and date information
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(widget.trip.viaje.precioAsiento * widget.trip.asientosSolicitados),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        widget.trip.pagoRealizado ? 'Pagado' : 'Pendiente de pago',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: widget.trip.pagoRealizado ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        capitalizedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Origin and destination
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ruta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.locationDot,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        Icon(
                          FontAwesomeIcons.locationDot,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.trip.viaje.direccionOrigen,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.trip.viaje.direccionDestino,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Driver information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conductor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: widget.trip.viaje.fotoConductor != null
                            ? NetworkImage(widget.trip.viaje.fotoConductor!)
                            : null,
                        child: widget.trip.viaje.fotoConductor == null
                            ? const Icon(Icons.person, size: 40, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.trip.viaje.nombreConductor} ${widget.trip.viaje.apellidoConductor}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  widget.trip.viaje.calificacionConductor != null
                                      ? widget.trip.viaje.calificacionConductor!.toStringAsFixed(1)
                                      : "Sin calificación",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  widget.trip.viaje.telefonoConductor,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Vehicle information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehículo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.trip.viaje.vehiculoFoto != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.trip.viaje.vehiculoFoto!,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.car,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.car,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.trip.viaje.vehiculoMarca} ${widget.trip.viaje.vehiculoModelo}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildVehicleInfo(
                                  FontAwesomeIcons.palette,
                                  widget.trip.viaje.vehiculoColor,
                                ),
                                const SizedBox(width: 16),
                                _buildVehicleInfo(
                                  FontAwesomeIcons.car,
                                  widget.trip.viaje.vehiculoTipo,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildVehicleInfo(
                              FontAwesomeIcons.idCard,
                              'Placa: ${widget.trip.viaje.vehiculoPlaca}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Seats information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asientos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Asientos reservados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.trip.asientosSolicitados}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Actions based on trip status
            if (_shouldShowActions(widget.trip))
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.trip.estado == 'PENDIENTE' || widget.trip.estado == 'ACEPTADO')
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                backgroundColor: Colors.white,
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_outlined,
                                      color: Colors.amber,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Confirmar cancelación',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  '¿Estás seguro que deseas cancelar esta reserva? Esta acción no se puede deshacer.',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(
                                          'No, volver',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'Sí, cancelar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ) ?? false;

                          if (confirmed && mounted) {
                            try {
                              final TripService tripService = TripService();
                              final success = await tripService.cancelReservation(tripId: widget.trip.viaje.id);

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reserva cancelada con éxito'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                Navigator.of(context).pop(true);
                              }
                            } catch (e) {
                              if (mounted) {
                                // Show error dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                      backgroundColor: Colors.white,
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Error',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'No se pudo cancelar la reserva: ${e.toString()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      actionsPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      actions: <Widget>[
                                        Center(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Aceptar',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          'Cancelar reserva',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACEPTADO':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.amber;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String tripState) {
    switch (tripState) {
      case 'iniciado':
        return Icons.directions_car_filled;
      case 'por iniciar':
        return Icons.schedule;
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String tripState) {
    switch (tripState) {
      case 'iniciado':
        return 'Viaje en curso';
      case 'por iniciar':
        return 'Viaje programado';
      case 'finalizado':
        return 'Viaje finalizado';
      case 'cancelado':
        return 'Viaje cancelado';
      default:
        return 'Estado desconocido';
    }
  }

  bool _shouldShowActions(PassengerTrip trip) {
    return (trip.estado == 'PENDIENTE' || trip.estado == 'ACEPTADO' );
  }
}