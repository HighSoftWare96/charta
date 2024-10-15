import 'package:Charta/utils/redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RequestLocationAction {
  void Function(Object e)? onError;
  void Function()? onSuccess;

  RequestLocationAction({this.onError, this.onSuccess});
}

class RequestLocationActionSuccess {}

class UserLocationUpdateAction {
  Point location;

  UserLocationUpdateAction(this.location);
}

class RequestLocationActionError extends ErrorAction {
  RequestLocationActionError(super.message);
}
