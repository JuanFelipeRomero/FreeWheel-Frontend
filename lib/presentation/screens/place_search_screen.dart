// Crea un nuevo archivo, ej: lib/presentation/screens/place_search_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:freewheel_frontend/data/models/place_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaceSearchScreen extends StatefulWidget {
  // Recibe el session token generado en la pantalla anterior
  final String sessionToken;

  const PlaceSearchScreen({super.key, required this.sessionToken});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce; // Para el debouncing de las llamadas API
  List<PlaceAutocompletePrediction> _suggestions = [];
  late final String kGoogleApiKey; // API Key

  @override
  void initState() {
    super.initState();
    kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? ""; // Carga la API Key
    if (kGoogleApiKey.isEmpty) {
      print("ERROR CRITICO: API Key no encontrada en PlaceSearchScreen");
      // Podrías mostrar un error o cerrar la pantalla
    }
    // Listener para el campo de texto
    _controller.addListener(() {
      // Cancela el timer anterior si existe
      _debounce?.cancel();
      // Inicia un nuevo timer para esperar antes de buscar
      _debounce = Timer(const Duration(milliseconds: 600), () {
        if (_controller.text.isNotEmpty) {
          _fetchAutocompleteSuggestions(_controller.text);
        } else {
          // Limpia sugerencias si el campo está vacío
          if (mounted) {
            setState(() {
              _suggestions = [];
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel(); // Asegúrate de cancelar el timer al salir
    super.dispose();
  }

  // --- Lógica para llamar al Autocomplete API ---
  Future<void> _fetchAutocompleteSuggestions(String input) async {
    if (kGoogleApiKey.isEmpty) return; // No hacer nada si no hay key

    // Construye la URL de la API
    // !!! Reemplaza 'co' por tu código de país si es necesario !!!
    final String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    final String request =
        '$baseUrl?input=${Uri.encodeComponent(input)}&key=$kGoogleApiKey&sessiontoken=${widget.sessionToken}&language=es&components=country:co&types=geocode|establishment';

    print("Autocomplete Request URL: $request"); // Para debugging

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'OK') {
          // Parsear las predicciones
          final List<dynamic> predictionsJson = result['predictions'];
          if (mounted) {
            // Verifica si el widget aún está montado
            setState(() {
              _suggestions =
                  predictionsJson
                      .map((p) => PlaceAutocompletePrediction.fromJson(p))
                      .toList();
            });
          }
        } else if (result['status'] == 'ZERO_RESULTS') {
          if (mounted) {
            setState(() {
              _suggestions = [];
            }); // Limpia si no hay resultados
          }
          print("Autocomplete status: ${result['status']}");
        } else {
          print(
            "Error en Autocomplete API: ${result['status']} - ${result['error_message']}",
          );
          if (mounted) {
            setState(() {
              _suggestions = [];
            });
          }
          // Mostrar error al usuario si es necesario
        }
      } else {
        print("Error HTTP en Autocomplete: ${response.statusCode}");
        if (mounted) {
          setState(() {
            _suggestions = [];
          });
        }
        // Mostrar error al usuario
      }
    } catch (e) {
      print("Excepción en _fetchAutocompleteSuggestions: $e");
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
      // Mostrar error al usuario
    }
  }

  // --- Lógica para llamar al Place Details API ---
  Future<PlaceResult?> _getPlaceDetailsForSuggestion(
    PlaceAutocompletePrediction suggestion,
  ) async {
    if (kGoogleApiKey.isEmpty) return null;

    final String baseUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";
    // Campos solicitados: coordenadas y dirección formateada
    final String fields = "geometry/location,formatted_address";
    final String request =
        '$baseUrl?place_id=${suggestion.placeId}&key=$kGoogleApiKey&sessiontoken=${widget.sessionToken}&language=es&fields=$fields';

    print("Place Details Request URL: $request"); // Para debugging

    try {
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'OK') {
          final placeDetails = result['result'];
          final location = placeDetails['geometry']?['location'];
          return PlaceResult(
            description:
                suggestion.description, // Usa la descripción del autocomplete
            placeId: suggestion.placeId,
            lat: location?['lat'],
            lng: location?['lng'],
          );
        } else {
          print(
            "Error en Place Details API: ${result['status']} - ${result['error_message']}",
          );
          // Podrías devolver solo la descripción si fallan los detalles
          return PlaceResult(
            description: suggestion.description,
            placeId: suggestion.placeId,
          );
        }
      } else {
        print("Error HTTP en Place Details: ${response.statusCode}");
        return PlaceResult(
          description: suggestion.description,
          placeId: suggestion.placeId,
        ); // Fallback
      }
    } catch (e) {
      print("Excepción en _getPlaceDetailsForSuggestion: $e");
      return PlaceResult(
        description: suggestion.description,
        placeId: suggestion.placeId,
      ); // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true, // Abre el teclado automáticamente
          decoration: InputDecoration(
            hintText: 'Introduce dirección...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        // Puedes añadir más estilo al AppBar si quieres
      ),
      body: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            title: Text(suggestion.description),
            leading: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () async {
              print("Suggestion tapped: ${suggestion.description}");
              // Obtener detalles (incluyendo coordenadas)
              final PlaceResult? placeResult =
                  await _getPlaceDetailsForSuggestion(suggestion);
              // Cerrar esta pantalla y devolver el resultado a la pantalla anterior
              if (mounted && placeResult != null) {
                Navigator.pop(context, placeResult);
              } else if (mounted) {
                // Si _getPlaceDetails falló pero tenemos la sugerencia básica
                Navigator.pop(
                  context,
                  PlaceResult(
                    description: suggestion.description,
                    placeId: suggestion.placeId,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
