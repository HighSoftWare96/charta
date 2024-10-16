import 'package:Charta/features/gpx/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/gpx.dart';
import 'package:Charta/utils/redux.dart';
import 'package:file_picker/file_picker.dart';
import 'package:turf/turf.dart';

enum GPXStatus { loaded, error, pending, none }

class GPXState {
  final PlatformFile? _file;
  final GPXStatus _status;
  final GeoJSONGPX? _gpx;

  PlatformFile? get file => _file;
  GPXStatus? get status => _status;
  GeoJSONGPX? get gpx => _gpx;

  GPXState.initialState()
      : _file = null,
        _gpx = null,
        _status = GPXStatus.none;

  GPXState.copyWith(GPXState state,
      {StoreValue<PlatformFile?>? file,
      StoreValue<GPXStatus>? status,
      StoreValue<Feature<Point>?>? nearestPointOnTrack,
      StoreValue<double>? nearestPointBearing,
      StoreValue<double>? nearestPointDistance,
      StoreValue<GeoJSONGPX?>? gpx})
      : _file = file != null ? file.value : state._file,
        _gpx = gpx != null ? gpx.value : state.gpx,
        _status = status != null ? status.value : state._status;
}

GPXState gpxReducer(RootState state, dynamic action) {
  if (action is LoadGPXFileAction) {
    return GPXState.copyWith(state.gpxFeature,
        status: const StoreValue.of(GPXStatus.pending),
        file: StoreValue.of(action.file));
  } else if (action is UnloadGPXFileAction) {
    return GPXState.copyWith(state.gpxFeature,
        status: const StoreValue.of(GPXStatus.none),
        gpx: const StoreValue.of(null),
        file: const StoreValue.of(null));
  } else if (action is LoadGPXFileErrorAction) {
    return GPXState.copyWith(state.gpxFeature,
        status: const StoreValue.of(GPXStatus.error),
        gpx: const StoreValue.of(null),
        file: const StoreValue.of(null));
  } else if (action is LoadGPXFileSuccessAction) {
    return GPXState.copyWith(state.gpxFeature,
        status: const StoreValue.of(GPXStatus.loaded),
        gpx: StoreValue.of(action.gpx));
  }

  return state.gpxFeature;
}
