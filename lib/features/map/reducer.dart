import 'package:Charta/features/map/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

enum MapMode { free, centered, fitGpx }

class MapState {
  final CameraState? _cameraState;
  final MapMode _mode;

  MapMode get mode => _mode;
  CameraState? get cameraState => _cameraState;

  MapState.initialState()
      : _mode = MapMode.centered,
        _cameraState = null;

  MapState.copyWith(MapState state,
      {StoreValue<MapMode>? mode, StoreValue<CameraState>? cameraState})
      : _mode = mode != null ? mode.value : state._mode,
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
  }

  return state.mapFeature;
}
