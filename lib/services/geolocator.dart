import 'dart:async';

import 'package:Charta/services/mapHandler.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class UserLocationUpdate {
  Point location;
  double bearing;

  UserLocationUpdate(this.location, this.bearing);
}

class GeoLocatorHelper {
  StreamSubscription<UserLocationUpdate?>? _subscription;
  String puckLayerName = getPuckLayerName();

  subscribe(void Function(UserLocationUpdate update) onUpdate) {
    if (_subscription != null) {
      throw 'Already subscribed to location!';
    }

    if (mapHandler.map == null) {
      throw 'Map tracker not ready!';
    }

    _subscription = _createMapStream().listen((data) {
      if (data != null) onUpdate(data);
    });
  }

  unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  Stream<UserLocationUpdate?> _createMapStream() {
    return Stream.periodic(const Duration(milliseconds: 500), (_) async {
      final layerExists =
          await mapHandler.map!.style.styleLayerExists(puckLayerName);

      if (layerExists) {
        final layer = await mapHandler.map!.style.getLayer(puckLayerName);
        final location = (layer as LocationIndicatorLayer).location;
        final bearing = layer.bearing;

        if (location == null ||
            location[0] == null ||
            location[1] == null ||
            bearing == null) {
          return null;
        }

        return UserLocationUpdate(
            Point(coordinates: Position(location[1]!, location[0]!)), bearing);
      }

      return null;
    }).asyncMap((event) async => await event);
  }
}

final geolocator = GeoLocatorHelper();
