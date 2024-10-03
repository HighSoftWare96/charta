import 'package:geolocator/geolocator.dart';

class RequestLocationAction {
  void Function(Object e)? onError;
  void Function()? onSuccess;

  RequestLocationAction({this.onError, this.onSuccess});
}

class ToggleMapModeAction {}

class MapCameraChangesByUserAction {}

class RequestLocationActionSuccess {
  Position location;

  RequestLocationActionSuccess({required this.location});
}

class _ErrorAction {
  String? message;

  _ErrorAction(this.message);
}

class RequestLocationActionError extends _ErrorAction {
  RequestLocationActionError(super.message);
}

class DisposeApp {}
