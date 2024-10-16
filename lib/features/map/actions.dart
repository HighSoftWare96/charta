import 'package:Charta/features/map/reducer.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ToggleMapModeAction {}

class MapCameraChangesByUserAction {}

class MapBoundsUpdateAction {
  CameraState camera;

  MapBoundsUpdateAction(this.camera);
}

class ChangeMapStyleAction {
  String styleURL;

  ChangeMapStyleAction(this.styleURL);
}


class ChangeBearingModeAction {
  BearingMode bearingMode;

  ChangeBearingModeAction(this.bearingMode);
}