import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';

class RateTripScreen extends StatefulWidget {
  final Trip trip;

  const RateTripScreen({super.key, required this.trip});

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  final TripService _tripService = TripService();
  final TextEditingController _commentController = TextEditingController();

  int _currentRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una calificación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _tripService.submitTripRating(
        tripId: widget.trip.id,
        rating: _currentRating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Calificación enviada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar a la pantalla anterior con resultado exitoso
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calificar viaje',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del viaje
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del viaje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTripInfoRow(
                    FontAwesomeIcons.locationDot,
                    'Origen',
                    widget.trip.direccionOrigen,
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildTripInfoRow(
                    FontAwesomeIcons.flagCheckered,
                    'Destino',
                    widget.trip.direccionDestino,
                    Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildTripInfoRow(
                    FontAwesomeIcons.user,
                    'Conductor',
                    '${widget.trip.nombreConductor} ${widget.trip.apellidoConductor}',
                    Colors.blue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sección de calificación
            Text(
              '¿Cómo calificarías este viaje?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Estrellas de calificación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentRating = starIndex;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            starIndex <= _currentRating
                                ? FontAwesomeIcons.solidStar
                                : FontAwesomeIcons.star,
                            size: 40,
                            color:
                                starIndex <= _currentRating
                                    ? Colors.amber.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getRatingText(_currentRating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Campo de comentario
            Text(
              'Comentario (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia sobre este viaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 32),

            // Botón de enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Enviar calificación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón de cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return 'Selecciona una calificación';
    }
  }
}
