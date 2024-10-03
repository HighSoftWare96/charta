import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GeoLocatorHelper {
  final _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  StreamSubscription<Position>? _subscription = null;

  subscribe(void Function(Position current) onUpdate) {
    if (_subscription != null) {
      throw 'Already subscribed to location!';
    }

    _subscription =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((Position? position) {
      if (position != null) {
        onUpdate(position);
      }
    });
  }

  unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }
}
