import 'package:Charta/store/actions.dart';
import 'package:geolocator/geolocator.dart';

enum MapMode { free, centered, fitGpx }

class AppState {
  final bool _hasLocationPermissions;
  final Position? _userLocation;
  final bool _gpxLoaded;
  final MapMode _mapMode;

  bool get hasLocationPermissions => _hasLocationPermissions;
  bool get gpxLoaded => _gpxLoaded;
  Position? get userLocation => _userLocation;
  MapMode get mapMode => _mapMode;

  AppState.initialState()
      : _gpxLoaded = false,
        _hasLocationPermissions = false,
        _mapMode = MapMode.centered,
        _userLocation = null;

  AppState.copyWith(AppState state,
      {hasLocationPermissions, userLocation, gpxLoaded, mapMode})
      : _hasLocationPermissions =
            hasLocationPermissions ?? state._hasLocationPermissions,
        _mapMode = mapMode ?? state._mapMode,
        _gpxLoaded = gpxLoaded ?? state._gpxLoaded,
        _userLocation = userLocation ?? state._userLocation;
}

AppState reducer(AppState state, dynamic action) {
  if (action is RequestLocationAction) {
    return AppState.copyWith(state, hasLocationPermissions: false);
  } else if (action is RequestLocationActionSuccess) {
    return AppState.copyWith(state,
        hasLocationPermissions: true, userLocation: action.location);
  } else if (action is RequestLocationActionError) {
    return AppState.copyWith(state, hasLocationPermissions: false);
  } else if (action is ToggleMapModeAction) {
    return AppState.copyWith(state,
        mapMode: (state.mapMode == MapMode.centered
            ? (state.gpxLoaded ? MapMode.fitGpx : MapMode.centered)
            : MapMode.centered));
  } else if (action is MapCameraChangesByUserAction) {
    return AppState.copyWith(state, mapMode: MapMode.free);
  }

  return state;
}
