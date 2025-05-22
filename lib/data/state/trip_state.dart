import 'package:flutter/foundation.dart';
import 'package:freewheel_frontend/data/models/trip_models.dart';

class TripState with ChangeNotifier {
  Trip? _activeTrip;
  DateTime? tripStartTime;

  Trip? get activeTrip => _activeTrip;

  bool get isTripActive => _activeTrip != null;

  void setActiveTrip(Trip trip) {
    if (_activeTrip == null || tripStartTime == null) {
      tripStartTime = DateTime.now();
    }
    _activeTrip = trip;
    notifyListeners();
  }

  void clearActiveTrip() {
    _activeTrip = null;
    tripStartTime = null;
    notifyListeners();
  }
}
