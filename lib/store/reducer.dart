import 'package:Charta/store/actions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum MapMode { free, centered, fitGpx }

class AppState {
  final bool _hasLocationPermissions;
  final Point? _userLocation;
  final CameraState? _cameraState;

  final bool _gpxLoaded;
  final MapMode _mapMode;

  bool get hasLocationPermissions => _hasLocationPermissions;
  bool get gpxLoaded => _gpxLoaded;
  Point? get userLocation => _userLocation;
  MapMode get mapMode => _mapMode;
  CameraState? get cameraState => _cameraState;

  AppState.initialState()
      : _gpxLoaded = false,
        _hasLocationPermissions = false,
        _mapMode = MapMode.centered,
        _userLocation = null,
        _cameraState = null;

  AppState.copyWith(AppState state,
      {hasLocationPermissions, userLocation, gpxLoaded, mapMode, cameraState})
      : _hasLocationPermissions =
            hasLocationPermissions ?? state._hasLocationPermissions,
        _mapMode = mapMode ?? state._mapMode,
        _gpxLoaded = gpxLoaded ?? state._gpxLoaded,
        _userLocation = userLocation ?? state._userLocation,
        _cameraState = cameraState ?? state._cameraState;
}

AppState reducer(AppState state, dynamic action) {
  if (action is RequestLocationAction) {
    return AppState.copyWith(state, hasLocationPermissions: false);
  } else if (action is RequestLocationActionSuccess) {
    return AppState.copyWith(state, hasLocationPermissions: true);
  } else if (action is RequestLocationActionError) {
    return AppState.copyWith(state, hasLocationPermissions: false);
  } else if (action is ToggleMapModeAction) {
    return AppState.copyWith(state,
        mapMode: (state.mapMode == MapMode.centered
            ? (state.gpxLoaded ? MapMode.fitGpx : MapMode.centered)
            : MapMode.centered));
  } else if (action is MapCameraChangesByUserAction) {
    return AppState.copyWith(state, mapMode: MapMode.free);
  } else if (action is MapBoundsUpdateAction) {
    return AppState.copyWith(state, cameraState: action.camera);
  } else if (action is UserLocationUpdateAction) {
    return AppState.copyWith(state,
        hasLocationPermissions: true, userLocation: action.location);
  }

  return state;
}
