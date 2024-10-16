import 'package:Charta/features/gpx/actions.dart';
import 'package:Charta/features/location/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/services/mapHandler.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/gpx.dart';
import 'package:redux/redux.dart';

void gpxMiddleware(Store<RootState> store, action, NextDispatcher next) async {
  if (action is LoadGPXFileAction) {
    next(action);
    try {
      final gpx = parseGPX(action.file);
      store.dispatch(LoadGPXFileSuccessAction(gpx));
    } catch (e) {
      store.dispatch(LoadGPXFileErrorAction('${e.runtimeType}'));
    }
    return;
  } else if (action is LoadGPXFileSuccessAction) {
    mapHandler.loadGPX(action.gpx);
  } else if (action is UnloadGPXFileAction) {
    mapHandler.unloadGPX();
  } else if (action is UserLocationUpdateAction &&
      store.state.gpxFeature.gpx != null &&
      store.state.locationFeature.userLocation != null) {
    await mapHandler.updateGPX(
        store.state.gpxFeature.gpx!,
        store.state.locationFeature.userLocation!,
        store.state.mapFeature.mode == MapMode.centered);
    await mapHandler.updateUserLocationTrack(store.state.locationFeature.userRecordedTrack);
  }

  next(action);
}
