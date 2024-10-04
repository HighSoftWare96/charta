import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RequestLocationAction {
  void Function(Object e)? onError;
  void Function()? onSuccess;

  RequestLocationAction({this.onError, this.onSuccess});
}

class ToggleMapModeAction {}

class MapCameraChangesByUserAction {}

class MapBoundsUpdateAction {
  CameraState camera;

  MapBoundsUpdateAction(this.camera);
}

class RequestLocationActionSuccess {}

class UserLocationUpdateAction {
  Point location;

  UserLocationUpdateAction(this.location);
}

class _ErrorAction {
  String? message;

  _ErrorAction(this.message);
}

class RequestLocationActionError extends _ErrorAction {
  RequestLocationActionError(super.message);
}

class DisposeApp {}
