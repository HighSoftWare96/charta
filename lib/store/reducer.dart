import 'package:Charta/store/actions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum MapMode { free, centered, fitGpx }

class GpxFile {
  PlatformFile file;

  GpxFile({required this.file});
}

class StoreValue<T> {
  final T value;
  const StoreValue.of(this.value);
}

class AppState {
  final bool _hasLocationPermissions;
  final Point? _userLocation;
  final CameraState? _cameraState;

  final GpxFile? _gpxFile;
  final MapMode _mapMode;

  bool get hasLocationPermissions => _hasLocationPermissions;
  GpxFile? get gpxLoaded => _gpxFile;
  Point? get userLocation => _userLocation;
  MapMode get mapMode => _mapMode;
  CameraState? get cameraState => _cameraState;

  AppState.initialState()
      : _gpxFile = null,
        _hasLocationPermissions = false,
        _mapMode = MapMode.centered,
        _userLocation = null,
        _cameraState = null;

  AppState.copyWith(AppState state,
      {StoreValue<dynamic>? hasLocationPermissions,
      StoreValue<dynamic>? userLocation,
      StoreValue<dynamic>? gpxLoaded,
      StoreValue<dynamic>? mapMode,
      StoreValue<dynamic>? cameraState})
      : _hasLocationPermissions = hasLocationPermissions != null
            ? hasLocationPermissions.value
            : state._hasLocationPermissions,
        _mapMode = mapMode != null ? mapMode.value : state._mapMode,
        _gpxFile = gpxLoaded != null ? gpxLoaded.value : state._gpxFile,
        _userLocation =
            userLocation != null ? userLocation.value : state._userLocation,
        _cameraState =
            cameraState != null ? cameraState.value : state._cameraState;
}

AppState reducer(AppState state, dynamic action) {
  if (action is RequestLocationAction) {
    return AppState.copyWith(state,
        hasLocationPermissions: const StoreValue.of(false));
  } else if (action is RequestLocationActionSuccess) {
    return AppState.copyWith(state,
        hasLocationPermissions: const StoreValue.of(true));
  } else if (action is RequestLocationActionError) {
    return AppState.copyWith(state,
        hasLocationPermissions: const StoreValue.of(false));
  } else if (action is ToggleMapModeAction) {
    return AppState.copyWith(state,
        mapMode: (state.mapMode == MapMode.centered
            ? (state.gpxLoaded != null
                ? const StoreValue.of(MapMode.fitGpx)
                : const StoreValue.of(MapMode.centered))
            : const StoreValue.of(MapMode.centered)));
  } else if (action is MapCameraChangesByUserAction) {
    return AppState.copyWith(state,
        mapMode: const StoreValue.of(MapMode.free));
  } else if (action is MapBoundsUpdateAction) {
    return AppState.copyWith(state,
        cameraState: StoreValue.of(action.camera));
  } else if (action is UserLocationUpdateAction) {
    return AppState.copyWith(state,
        hasLocationPermissions: const StoreValue.of(true),
        userLocation: StoreValue.of(action.location));
  } else if (action is LoadGPXFileAction) {
    return AppState.copyWith(state,
        gpxLoaded: StoreValue.of(GpxFile(file: action.file)));
  } else if (action is UnloadGPXFileAction) {
    return AppState.copyWith(state, gpxLoaded: const StoreValue.of(null));
  }

  return state;
}
