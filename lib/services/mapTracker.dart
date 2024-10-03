import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapTracker {
  MapboxMap? map;

  void track(MapboxMap map) {
    this.map = map;
  }
}

MapTracker tracker = MapTracker();
