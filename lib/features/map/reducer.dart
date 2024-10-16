import 'package:Charta/features/map/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum MapMode { free, centered, fitGpx }

class MapState {
  final CameraState? _cameraState;
  final MapMode _mode;
  final String _mapStyleURL;

  MapMode get mode => _mode;
  CameraState? get cameraState => _cameraState;
  String get mapStyleURL => _mapStyleURL;

  MapState.initialState()
      : _mode = MapMode.centered,
        _mapStyleURL = "mapbox://styles/mapbox/navigation-day-v1",
        _cameraState = null;

  MapState.copyWith(MapState state,
      {StoreValue<MapMode>? mode,
      StoreValue<CameraState>? cameraState,
      StoreValue<String>? styleURL})
      : _mode = mode != null ? mode.value : state._mode,
        _mapStyleURL = styleURL != null ? styleURL.value : state._mapStyleURL,
        _cameraState =
            cameraState != null ? cameraState.value : state._cameraState;
}

MapState mapReducer(RootState state, dynamic action) {
  if (action is ToggleMapModeAction) {
    return MapState.copyWith(state.mapFeature,
        mode: (state.mapFeature.mode == MapMode.centered
            ? (state.gpxFeature.file != null
                ? const StoreValue.of(MapMode.fitGpx)
                : const StoreValue.of(MapMode.centered))
            : const StoreValue.of(MapMode.centered)));
  } else if (action is MapCameraChangesByUserAction) {
    return MapState.copyWith(state.mapFeature,
        mode: const StoreValue.of(MapMode.free));
  } else if (action is MapBoundsUpdateAction) {
    return MapState.copyWith(state.mapFeature,
        cameraState: StoreValue.of(action.camera));
  } else if (action is ChangeMapStyleAction) {
    return MapState.copyWith(state.mapFeature,
        styleURL: StoreValue.of(action.styleURL));
  }

  return state.mapFeature;
}
