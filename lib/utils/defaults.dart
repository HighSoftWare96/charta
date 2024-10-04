import 'dart:io';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final CAMERA_DEFAULT_OPTIONS = CameraOptions(
    center: Point(coordinates: Position(12.501984, 41.886943)),
    zoom: 19,
    padding: MbxEdgeInsets(bottom: 1, top: 400, left: 1, right: 1),
    pitch: 50);

CameraOptions cameraDefaultWith(Point? center) {
  CameraOptions camera = CAMERA_DEFAULT_OPTIONS;
  if (center != null) camera.center = center;
  return camera;
}

String getPuckLayerName() {
  if (Platform.isAndroid) {
    return "mapbox-location-indicator-layer";
  }

  return 'puck';
}
