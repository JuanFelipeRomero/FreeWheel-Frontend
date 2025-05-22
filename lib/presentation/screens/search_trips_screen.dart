import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

import 'package:freewheel_frontend/data/models/place_models.dart';
import 'package:freewheel_frontend/presentation/screens/place_search_screen.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';
import 'package:freewheel_frontend/data/services/trip_service.dart';
import 'package:freewheel_frontend/presentation/screens/trip_list_screen.dart';

class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  // --- Variables de Estado existentes ---
  DateTime? _selectedDate;
  int _numberOfSeats = 1;


  // --- Variables de Estado para Lugares (ACTUALIZADAS) ---
  PlaceResult? _originResult; // Guarda el resultado completo del origen
  PlaceResult? _destinationResult; // Guarda el resultado completo del destino

  // --- API Key y Generador de UUID ---
  final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? "";
  final _uuid = const Uuid();

  // --- Servicio de viajes ---
  final TripService _tripService = TripService();

  // --- Indicador de carga ---
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar viajes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // --- Origen (MODIFICADO) ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              // Muestra la descripción del resultado o el título por defecto
              title: _originResult?.description ?? 'Desde', // USA PlaceResult
              titleColor: _originResult == null ? Colors.grey.shade500 : null,
              onTap:
                  () => _handlePlaceSelection(
                    isOrigin: true,
                  ), // Llama al NUEVO handler
            ),

            // --- Destino (MODIFICADO) ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title:
                  _destinationResult?.description ?? 'Hasta', // USA PlaceResult
              titleColor:
                  _destinationResult == null ? Colors.grey.shade500 : null,
              onTap:
                  () => _handlePlaceSelection(
                    isOrigin: false,
                  ), // Llama al NUEVO handler
            ),

            // --- Fecha ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.calendar,
              title: 'Fecha',
              displayValue:
                  _selectedDate == null
                      ? 'DD/MM/AAAA'
                      : dateFormatter.format(_selectedDate!),
              textColor: _selectedDate == null ? Colors.grey.shade500 : null,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(
                          context,
                        ).colorScheme.copyWith(primary: primaryColor),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),

            // --- Numero de asientos ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.users,
              title: 'Número de asientos',
              displayValue: _numberOfSeats.toString(),
              onTap: () async {
                final int? selectedSeats = await _showSeatSelectorDialog();
                if (selectedSeats != null) {
                  setState(() {
                    _numberOfSeats = selectedSeats;
                  });
                }
              },
            ),

            const Spacer(),

            // --- Botón de búsqueda ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null // Deshabilita el botón mientras está cargando
                        : () async {
                          // Verifica si tenemos los resultados con coordenadas
                          if (_originResult?.lat != null &&
                              _destinationResult?.lat != null &&
                              _selectedDate != null) {
                            setState(() {
                              _isLoading = true; // Activar indicador de carga
                            });

                            try {
                              print(
                                'Buscando viaje desde ${_originResult!.description} (${_originResult!.lat},${_originResult!.lng}) '
                                'hasta ${_destinationResult!.description} (${_destinationResult!.lat},${_destinationResult!.lng}) '
                                'el ${dateFormatter.format(_selectedDate!)} con $_numberOfSeats asientos',
                              );

                              // Realizar la búsqueda usando el servicio
                              final TripSearchResponse response =
                                  await _tripService.searchTrips(
                                    originLat: _originResult!.lat!,
                                    originLng: _originResult!.lng!,
                                    destinationLat: _destinationResult!.lat!,
                                    destinationLng: _destinationResult!.lng!,
                                    date: _selectedDate!,
                                    requiredSeats: _numberOfSeats,
                                  );

                              if (!mounted) return;

                              // Mostrar los resultados en la consola
                              if (response.success) {
                                print(
                                  '🚗 Viajes encontrados: ${response.trips.length}',
                                );
                                if (response.trips.isNotEmpty) {
                                  for (final trip in response.trips) {
                                    print(
                                      '  - ID: ${trip.id}, Conductor: ${trip.nombreConductor} ${trip.apellidoConductor}',
                                    );
                                    print(
                                      '    Origen: ${trip.direccionOrigen}, Destino: ${trip.direccionDestino}',
                                    );
                                    print(
                                      '    Fecha: ${trip.fecha}, Hora: ${trip.horaInicio} - ${trip.horaFin}',
                                    );
                                    print(
                                      '    Asientos disponibles: ${trip.asientosDisponibles}, Precio: \$${trip.precioAsiento}',
                                    );
                                    print(
                                      '    Vehículo: ${trip.vehiculoMarca} ${trip.vehiculoModelo} (${trip.vehiculoColor})',
                                    );
                                    print(
                                      '    Placa: ${trip.vehiculoPlaca}, Tipo: ${trip.vehiculoTipo}',
                                    );
                                    print(
                                      '    Calificación conductor: ${trip.calificacionConductor}',
                                    );
                                    print('    Estado: ${trip.estado}');
                                    print('    ----------------------------');
                                  }
                                } else {
                                  print(
                                    '👎 No se encontraron viajes disponibles para esta búsqueda.',
                                  );
                                }

                                // Navegar a la pantalla de resultados de viajes
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripListScreen(
                                      trips: response.trips.map((trip) {
                                        // Add the requested seats count to each trip
                                        trip.asientosSolicitados = _numberOfSeats;
                                        return trip;
                                      }).toList(),
                                    ),
                                  ),
                                );
                              } else {
                                // Mostrar mensaje de error
                                print(
                                  '❌ Error en la búsqueda: ${response.message}',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${response.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('⚠️ Excepción durante la búsqueda: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error de conexión: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading =
                                      false; // Desactivar indicador de carga
                                });
                              }
                            }
                          } else {
                            // Lógica para indicar qué falta
                            String missing = "";
                            if (_originResult?.lat == null) {
                              missing += "origen válido, ";
                            }
                            if (_destinationResult?.lat == null) {
                              missing += "destino válido, ";
                            }
                            if (_selectedDate == null) missing += "fecha, ";
                            if (missing.isNotEmpty) {
                              missing = missing.substring(
                                0,
                                missing.length - 2,
                              );
                              print('Por favor selecciona: $missing');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Por favor selecciona: $missing',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade400, // Color cuando está deshabilitado
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Buscar viajes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper para los campos (Modificado para aceptar titleColor) ---
  Widget _buildInputField({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? displayValue,
    Color?
    titleColor, // Color específico para el título (usado para placeholder)
    Color? textColor, // Color específico para displayValue/trailing
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final defaultTextColor = theme.colorScheme.onSurface.withOpacity(0.9);
    final defaultTitleColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return Container(
      // ... (decoración sin cambios) ...
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
          title: Text(
            title,
            style: TextStyle(
              color:
                  titleColor ?? defaultTitleColor, // Usa titleColor o default
              fontSize: 15,
            ),
            overflow:
                TextOverflow.ellipsis, // Evita overflow si el nombre es largo
            maxLines: 1,
          ),
          trailing:
              displayValue != null
                  ? Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? defaultTextColor,
                    ),
                  )
                  : trailing,
        ),
      ),
    );
  }

  // --- Diálogo selector de asientos (sin cambios) ---
  Future<int?> _showSeatSelectorDialog() async {
    int currentSelection = _numberOfSeats;
    // ... (resto del código del diálogo igual que antes) ...
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Número de asientos'),
              content: Row(
                /* ... Contenido del diálogo ... */
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        currentSelection > 1
                            ? () {
                              setDialogState(() {
                                currentSelection--;
                              });
                            }
                            : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$currentSelection',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed:
                        currentSelection < 8
                            ? () {
                              setDialogState(() {
                                currentSelection++;
                              });
                            }
                            : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              actions: <Widget>[
                /* ... Botones Cancelar y Aceptar ... */
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(currentSelection);
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            );
          },
        );
      },
    );
  }

  // --- Lógica para Google Places Autocomplete ---
  Future<void> _handlePlaceSelection({required bool isOrigin}) async {
    // Verifica API Key
    if (kGoogleApiKey.isEmpty ||
        kGoogleApiKey == "TU_API_KEY_POR_DEFECTO_SI_FALLA") {
      print("ERROR: API Key de Google no configurada.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error de configuración: Falta la clave de API de Google Maps.',
            ),
          ),
        );
      }
      return;
    }

    // Genera un NUEVO session token para esta sesión de búsqueda
    final sessionToken = _uuid.v4();
    print(
      "Generated session token for ${isOrigin ? 'Origin' : 'Destination'}: $sessionToken",
    );

    // Abre la pantalla de búsqueda y espera el resultado (PlaceResult)
    final PlaceResult? result = await Navigator.push<PlaceResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(sessionToken: sessionToken),
      ),
    );

    // Si el usuario seleccionó un lugar y volvió con datos
    if (result != null) {
      setState(() {
        if (isOrigin) {
          _originResult = result; // Guarda el resultado completo
          print(
            'Origen actualizado: ${result.description} (${result.lat}, ${result.lng})',
          );
        } else {
          _destinationResult = result; // Guarda el resultado completo
          print(
            'Destino actualizado: ${result.description} (${result.lat}, ${result.lng})',
          );
        }
      });
    } else {
      print("Place selection cancelled or failed.");
    }
  }
}
