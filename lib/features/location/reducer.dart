import 'package:Charta/features/location/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum LocationPermissionState { refused, accepted, pending }

class LocationState {
  final LocationPermissionState _permissionState;
  final Point? _userLocation;

  LocationPermissionState get permissionsState => _permissionState;
  Point? get userLocation => _userLocation;

  LocationState.initialState()
      : _permissionState = LocationPermissionState.pending,
        _userLocation = null;

  LocationState.copyWith(LocationState state,
      {StoreValue<LocationPermissionState>? permissionsState,
      StoreValue<Point>? userLocation})
      : _permissionState = permissionsState != null
            ? permissionsState.value
            : state._permissionState,
        _userLocation =
            userLocation != null ? userLocation.value : state._userLocation;
}

LocationState locationReducer(RootState state, dynamic action) {
  if (action is RequestLocationAction) {
    return LocationState.copyWith(state.location,
        permissionsState: const StoreValue.of(LocationPermissionState.pending));
  } else if (action is RequestLocationActionSuccess) {
    return LocationState.copyWith(state.location,
        permissionsState:
            const StoreValue.of(LocationPermissionState.accepted));
  } else if (action is RequestLocationActionError) {
    return LocationState.copyWith(state.location,
        permissionsState: const StoreValue.of(LocationPermissionState.refused));
  } else if (action is UserLocationUpdateAction) {
    return LocationState.copyWith(state.location,
        permissionsState: const StoreValue.of(LocationPermissionState.accepted),
        userLocation: StoreValue.of(action.location));
  }

  return state.location;
}
