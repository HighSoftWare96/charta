import 'package:Charta/features/gpx/actions.dart';
import 'package:Charta/features/gpx/utils.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/redux.dart';

class GPXState {
  final GpxFile? _file;
  GpxFile? get file => _file;

  GPXState.initialState() : _file = null;

  GPXState.copyWith(
    GPXState state, {
    StoreValue<GpxFile?>? file,
  }) : _file = file != null ? file.value : state._file;
}

GPXState gpxReducer(RootState state, dynamic action) {
  if (action is LoadGPXFileAction) {
    return GPXState.copyWith(state.gpx,
        file: StoreValue.of(GpxFile(file: action.file)));
  } else if (action is UnloadGPXFileAction) {
    return GPXState.copyWith(state.gpx, file: const StoreValue.of(null));
  }

  return state.gpx;
}
