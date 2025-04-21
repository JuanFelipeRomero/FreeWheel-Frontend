// Modelo para representar al conductor de un viaje
class Driver {
  final int id;
  final String nombre;

  Driver({required this.id, required this.nombre});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? 'Desconocido',
    );
  }
}

// Modelo para representar los viajes disponibles
class Trip {
  final int id;
  final String origenNombre;
  final String destinoNombre;
  final double latitudOrigen;
  final double longitudOrigen;
  final double latitudDestino;
  final double longitudDestino;
  final DateTime fechaHoraSalida;
  final int asientosDisponibles;
  final double precioPorAsiento;
  final String estado;
  final String? detallesAdicionales;
  final Driver conductorInfo;

  Trip({
    required this.id,
    required this.origenNombre,
    required this.destinoNombre,
    required this.latitudOrigen,
    required this.longitudOrigen,
    required this.latitudDestino,
    required this.longitudDestino,
    required this.fechaHoraSalida,
    required this.asientosDisponibles,
    required this.precioPorAsiento,
    required this.estado,
    this.detallesAdicionales,
    required this.conductorInfo,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int? ?? 0,
      origenNombre: json['origenNombre'] as String? ?? 'Origen desconocido',
      destinoNombre: json['destinoNombre'] as String? ?? 'Destino desconocido',
      latitudOrigen: (json['latitudOrigen'] as num?)?.toDouble() ?? 0.0,
      longitudOrigen: (json['longitudOrigen'] as num?)?.toDouble() ?? 0.0,
      latitudDestino: (json['latitudDestino'] as num?)?.toDouble() ?? 0.0,
      longitudDestino: (json['longitudDestino'] as num?)?.toDouble() ?? 0.0,
      fechaHoraSalida:
          json['fechaHoraSalida'] != null
              ? DateTime.parse(json['fechaHoraSalida'] as String)
              : DateTime.now(),
      asientosDisponibles: json['asientosDisponibles'] as int? ?? 0,
      precioPorAsiento: (json['precioPorAsiento'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] as String? ?? 'DESCONOCIDO',
      detallesAdicionales: json['detallesAdicionales'] as String?,
      conductorInfo:
          json['conductorInfo'] != null
              ? Driver.fromJson(json['conductorInfo'] as Map<String, dynamic>)
              : Driver(id: 0, nombre: 'Conductor desconocido'),
    );
  }
}

// Modelo para la respuesta de búsqueda de viajes
class TripSearchResponse {
  final List<Trip> trips;
  final bool success;
  final String? message;

  TripSearchResponse({
    required this.trips,
    required this.success,
    this.message,
  });

  // En este caso, la respuesta de la API es directamente una lista de viajes,
  // así que adaptamos nuestro parser para manejar este formato
  factory TripSearchResponse.fromJson(List<dynamic> json) {
    final trips =
        json
            .map((tripJson) => Trip.fromJson(tripJson as Map<String, dynamic>))
            .toList();

    return TripSearchResponse(trips: trips, success: true);
  }

  // Constructor para crear una respuesta vacía o con error
  factory TripSearchResponse.error(String errorMessage) {
    return TripSearchResponse(trips: [], success: false, message: errorMessage);
  }
}
