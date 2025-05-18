class TripRequest {
  final String id;
  final String passengerName;
  final String tripId;
  final String status;
  // Add other relevant details from your API response if needed

  const TripRequest({
    required this.id,
    required this.passengerName,
    required this.tripId,
    required this.status,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    // Access nested passenger data
    final passengerData = json['pasajero'] as Map<String, dynamic>?;
    final passengerFirstName = passengerData?['nombre'] as String? ?? 'N/A';
    final passengerLastName = passengerData?['apellido'] as String? ?? '';

    return TripRequest(
      id: json['id'].toString(),
      passengerName: '$passengerFirstName $passengerLastName'.trim(),
      tripId: json['viajeId'].toString(),
      status: json['estado'] as String? ?? 'UNKNOWN',
    );
  }

  // Optional: toJson method if you ever need to send this object back to an API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerName': passengerName,
      'tripId': tripId,
      'status': status,
    };
  }
}
