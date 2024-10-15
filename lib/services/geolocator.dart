import 'dart:async';

import 'package:Charta/services/mapTracker.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class GeoLocatorHelper {
  StreamSubscription<Point?>? _subscription;
  String puckLayerName = getPuckLayerName();

  subscribe(void Function(Point current) onUpdate) {
    if (_subscription != null) {
      throw 'Already subscribed to location!';
    }

    if (tracker.map == null) {
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

  Stream<Point?> _createMapStream() {
    return Stream.periodic(const Duration(milliseconds: 2000), (_) async {
      final layerExists =
          await tracker.map!.style.styleLayerExists(puckLayerName);

      if (layerExists) {
        final layer = await tracker.map!.style.getLayer(puckLayerName);
        final location = (layer as LocationIndicatorLayer).location;

        if (location == null || location[0] == null || location[1] == null) {
          return null;
        }

        return Point(coordinates: Position(location[1]!, location[0]!));
      }

      return null;
    }).asyncMap((event) async => await event);
  }
}

final geolocator = GeoLocatorHelper();
