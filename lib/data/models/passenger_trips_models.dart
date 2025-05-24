// Models for the API response
class PassengerTrip {
  final int id;
  final TripDetail viaje;
  final Passenger? pasajero; // Make nullable
  final int asientosSolicitados;
  final bool pagoRealizado;
  final String estado;

  PassengerTrip({
    required this.id,
    required this.viaje,
    this.pasajero, // Remove required keyword
    required this.asientosSolicitados,
    required this.pagoRealizado,
    required this.estado,
  });

  factory PassengerTrip.fromJson(Map<String, dynamic> json) {
    return PassengerTrip(
      id: json['id'],
      viaje: TripDetail.fromJson(json['viaje']),
      pasajero: json['pasajero'] != null
          ? Passenger.fromJson(json['pasajero'])
          : null,
      asientosSolicitados: json['asientosSolicitados'],
      pagoRealizado: json['pagoRealizado'],
      estado: json['estado'],
    );
  }
}

class TripDetail {
  final int id;
  final int conductorId;
  final String fecha;
  final String horaInicio;
  final String? horaFin;
  final int precioAsiento;
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
  final String? fotoConductor;
  final String telefonoConductor;
  final double? calificacionConductor;
  final String vehiculoPlaca;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final String vehiculoColor;
  final String vehiculoTipo;
  final String? vehiculoFoto;

  TripDetail({
    required this.id,
    required this.conductorId,
    required this.fecha,
    required this.horaInicio,
    this.horaFin,
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
    this.fotoConductor,
    required this.telefonoConductor,
    this.calificacionConductor,
    required this.vehiculoPlaca,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoColor,
    required this.vehiculoTipo,
    this.vehiculoFoto,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) {
    return TripDetail(
      id: json['id'],
      conductorId: json['conductorId'],
      fecha: json['fecha'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      precioAsiento: json['precioAsiento'],
      asientosDisponibles: json['asientosDisponibles'],
      direccionOrigen: json['direccionOrigen'],
      latitudOrigen: json['latitudOrigen'],
      longitudOrigen: json['longitudOrigen'],
      direccionDestino: json['direccionDestino'],
      latitudDestino: json['latitudDestino'],
      longitudDestino: json['longitudDestino'],
      estado: json['estado'],
      nombreConductor: json['nombreConductor'],
      apellidoConductor: json['apellidoConductor'],
      fotoConductor: json['fotoConductor'],
      telefonoConductor: json['telefonoConductor'],
      calificacionConductor: json['calificacionConductor'],
      vehiculoPlaca: json['vehiculoPlaca'],
      vehiculoMarca: json['vehiculoMarca'],
      vehiculoModelo: json['vehiculoModelo'],
      vehiculoColor: json['vehiculoColor'],
      vehiculoTipo: json['vehiculoTipo'],
      vehiculoFoto: json['vehiculoFoto'],
    );
  }
}

class Passenger {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String? fotoPerfil;
  final String organizacionCodigo;
  final int? conductorId;
  final bool driver;

  Passenger({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    this.fotoPerfil,
    required this.organizacionCodigo,
    this.conductorId,
    required this.driver,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      telefono: json['telefono'],
      fotoPerfil: json['fotoPerfil'],
      organizacionCodigo: json['organizacionCodigo'],
      conductorId: json['conductorId'],
      driver: json['driver'],
    );
  }
}