import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ToggleMapModeAction {}

class MapCameraChangesByUserAction {}

class MapBoundsUpdateAction {
  CameraState camera;

  MapBoundsUpdateAction(this.camera);
}
