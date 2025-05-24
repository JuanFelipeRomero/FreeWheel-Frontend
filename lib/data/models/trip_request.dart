class TripRequest {
  final String id;
  final String passengerName;
  final String tripId;
  final String status;
  final int? requestedSeats;
  final String? origin;
  final String? destination;
  final String? departureDate;
  final String? departureTime;
  final String? passengerEmail;
  final String? passengerPhone;
  final String? passengerPhoto;

  const TripRequest({
    required this.id,
    required this.passengerName,
    required this.tripId,
    required this.status,
    this.requestedSeats,
    this.origin,
    this.destination,
    this.departureDate,
    this.departureTime,
    this.passengerEmail,
    this.passengerPhone,
    this.passengerPhoto,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    // Access nested passenger data
    final passengerData = json['pasajero'] as Map<String, dynamic>?;
    final passengerFirstName = passengerData?['nombre'] as String? ?? 'N/A';
    final passengerLastName = passengerData?['apellido'] as String? ?? '';
    final passengerEmail = passengerData?['correo'] as String?;
    final passengerPhone = passengerData?['telefono'] as String?;
    final passengerPhoto = passengerData?['fotoPerfil'] as String?;

    // Access nested trip data
    final tripData = json['viaje'] as Map<String, dynamic>?;
    print('Trip data for request ${json['id']}: $tripData');

    // Extract trip details with proper null checking
    String? origin, destination, departureDate, departureTime;

    if (tripData != null) {
      origin = tripData['direccionOrigen'] as String?;
      destination = tripData['direccionDestino'] as String?;
      departureDate = tripData['fecha'] as String?;
      departureTime = tripData['horaInicio'] as String?;
    }

    return TripRequest(
      id: json['id'].toString(),
      passengerName: '$passengerFirstName $passengerLastName'.trim(),
      tripId: json['viajeId'].toString(),
      status: json['estado'] as String? ?? 'UNKNOWN',
      requestedSeats: json['asientosSolicitados'] as int? ?? 1,
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      departureTime: departureTime,
      passengerEmail: passengerEmail,
      passengerPhone: passengerPhone,
      passengerPhoto: passengerPhoto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerName': passengerName,
      'tripId': tripId,
      'status': status,
      'requestedSeats': requestedSeats,
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'passengerEmail': passengerEmail,
      'passengerPhone': passengerPhone,
      'passengerPhoto': passengerPhoto,
    };
  }
}