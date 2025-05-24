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
  final int conductorId;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final double precioAsiento;
  final int asientosDisponibles;
  final String direccionOrigen;
  final double latitudOrigen;
  final double longitudOrigen;
  final String direccionDestino;
  final double latitudDestino;
  final double longitudDestino;
  final String estado;
  final String nombreConductor;
  final String apellidoConductor;
  final String fotoConductor;
  final String telefonoConductor;
  final double calificacionConductor;
  final String vehiculoPlaca;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final String vehiculoColor;
  final String vehiculoTipo;
  final String vehiculoFoto;
  int? asientosSolicitados;

  Trip({
    required this.id,
    required this.conductorId,

    this.asientosSolicitados,

    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.precioAsiento,
    required this.asientosDisponibles,
    required this.direccionOrigen,
    required this.latitudOrigen,
    required this.longitudOrigen,
    required this.direccionDestino,
    required this.latitudDestino,
    required this.longitudDestino,
    required this.estado,
    required this.nombreConductor,
    required this.apellidoConductor,
    required this.fotoConductor,
    required this.telefonoConductor,
    required this.calificacionConductor,
    required this.vehiculoPlaca,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoColor,
    required this.vehiculoTipo,
    required this.vehiculoFoto,

  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int? ?? 0,
      conductorId: json['conductorId'] as int? ?? 0,

      asientosSolicitados: json['asientosSolicitados'] as int? ?? 0,

      fecha: json['fecha'] as String? ?? '',
      horaInicio: json['horaInicio'] as String? ?? '',
      horaFin: json['horaFin'] as String? ?? '',
      precioAsiento: (json['precioAsiento'] as num?)?.toDouble() ?? 0.0,
      asientosDisponibles: json['asientosDisponibles'] as int? ?? 0,
      direccionOrigen:
          json['direccionOrigen'] as String? ?? 'Origen desconocido',
      latitudOrigen: (json['latitudOrigen'] as num?)?.toDouble() ?? 0.0,
      longitudOrigen: (json['longitudOrigen'] as num?)?.toDouble() ?? 0.0,
      direccionDestino:
          json['direccionDestino'] as String? ?? 'Destino desconocido',
      latitudDestino: (json['latitudDestino'] as num?)?.toDouble() ?? 0.0,
      longitudDestino: (json['longitudDestino'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] as String? ?? 'DESCONOCIDO',
      nombreConductor: json['nombreConductor'] as String? ?? 'Desconocido',
      apellidoConductor: json['apellidoConductor'] as String? ?? '',
      fotoConductor: json['fotoConductor'] as String? ?? '',
      telefonoConductor: json['telefonoConductor'] as String? ?? '',
      calificacionConductor:
          (json['calificacionConductor'] as num?)?.toDouble() ?? 0.0,
      vehiculoPlaca: json['vehiculoPlaca'] as String? ?? '',
      vehiculoMarca: json['vehiculoMarca'] as String? ?? '',
      vehiculoModelo: json['vehiculoModelo'] as String? ?? '',
      vehiculoColor: json['vehiculoColor'] as String? ?? '',
      vehiculoTipo: json['vehiculoTipo'] as String? ?? '',
      vehiculoFoto: json['vehiculoFoto'] as String? ?? '',
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
