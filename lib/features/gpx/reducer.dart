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
  final Feature<Point>? _nearestPointOnTrack;
  final double? _nearestPointDistance;
  final double? _nearestPointBearing;

  PlatformFile? get file => _file;
  GPXStatus? get status => _status;
  GeoJSONGPX? get gpx => _gpx;
  Feature<Point>? get nearestPointOnTrack => _nearestPointOnTrack;
  double? get nearestPointBearing => _nearestPointBearing;
  double? get nearestPointDistance => _nearestPointDistance;

  GPXState.initialState()
      : _file = null,
        _gpx = null,
        _nearestPointBearing = null,
        _nearestPointDistance = null,
        _nearestPointOnTrack = null,
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
        _nearestPointBearing = nearestPointBearing != null
            ? nearestPointBearing.value
            : state.nearestPointBearing,
        _nearestPointOnTrack = nearestPointOnTrack != null
            ? nearestPointOnTrack.value
            : state.nearestPointOnTrack,
        _nearestPointDistance = nearestPointDistance != null
            ? nearestPointDistance.value
            : state.nearestPointDistance,
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
