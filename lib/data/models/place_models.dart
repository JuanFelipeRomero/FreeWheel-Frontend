class PlaceAutocompletePrediction {
  final String description;
  final String placeId;

  PlaceAutocompletePrediction({
    required this.description,
    required this.placeId,
  });

  factory PlaceAutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompletePrediction(
      description: json['description'] as String? ?? 'Sin descripción',
      placeId: json['place_id'] as String? ?? '',
    );
  }
}

// Para el resultado final que devolveremos (incluyendo coordenadas)
class PlaceResult {
  final String description;
  final String placeId;
  final double? lat;
  final double? lng;

  PlaceResult({
    required this.description,
    required this.placeId,
    this.lat,
    this.lng,
  });
}
