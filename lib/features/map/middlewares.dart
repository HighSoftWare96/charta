import 'package:Charta/features/location/actions.dart';
import 'package:Charta/features/map/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/services/mapHandler.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:Charta/utils/gpx.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:redux/redux.dart';
import 'package:turf/turf.dart' as turf;

void mapMiddleware(Store<RootState> store, action, NextDispatcher next) async {
  if (action is ToggleMapModeAction && mapHandler.map != null) {
    if (store.state.mapFeature.mode == MapMode.free &&
        store.state.locationFeature.userLocation != null) {
      _centerMapToUserLocation(store.state.locationFeature.userLocation!,
          MapAnimationOptions(duration: 1500));
    } else if (store.state.gpxFeature.gpx != null) {
      await _fitGpx(store.state.gpxFeature.gpx!, null);
    }
  } else if (action is UserLocationUpdateAction &&
      store.state.mapFeature.mode == MapMode.centered &&
      store.state.locationFeature.userLocation != null) {
    _centerMapToUserLocation(store.state.locationFeature.userLocation!, null);
  } else if (action is ChangeMapStyleAction) {
    mapHandler.changeStyle(action.styleURL, store.state.gpxFeature.gpx);
  }

  next(action);
}

void _centerMapToUserLocation(Point location, MapAnimationOptions? animations) {
  CameraOptions camera = cameraDefaultWith(location);
  mapHandler.map!.flyTo(camera, animations ?? MapAnimationOptions());
}

_fitGpx(GeoJSONGPX gpx, MapAnimationOptions? animations) async {
  final bboxResult = turf.bbox(gpx.track).toJson();
  final options = await mapHandler.map!.cameraForCoordinateBounds(
      CoordinateBounds(
          southwest: Point(coordinates: Position(bboxResult[0], bboxResult[1])),
          northeast: Point(coordinates: Position(bboxResult[2], bboxResult[3])),
          infiniteBounds: false),
      MbxEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
      0,
      0,
      null,
      ScreenCoordinate(x: 0, y: -200));
  mapHandler.map!.flyTo(options, animations ?? MapAnimationOptions());
}
