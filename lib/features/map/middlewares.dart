import 'package:Charta/features/location/actions.dart';
import 'package:Charta/features/map/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/services/mapTracker.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:redux/redux.dart';

void mapMiddleware(Store<RootState> store, action, NextDispatcher next) {
  if (action is ToggleMapModeAction && tracker.map != null) {
    if (store.state.mapFeature.mode == MapMode.free) {
      _centerMapToUserLocation(store.state.locationFeature.userLocation!,
          MapAnimationOptions(duration: 1500));
    } else {
      // TODO: fit all gpx if there is one
    }
  } else if (action is UserLocationUpdateAction &&
      store.state.mapFeature.mode == MapMode.centered &&
      store.state.locationFeature.userLocation != null) {
    _centerMapToUserLocation(store.state.locationFeature.userLocation!, null);
  }

  next(action);
}

void _centerMapToUserLocation(Point location, MapAnimationOptions? animations) {
  CameraOptions camera = cameraDefaultWith(location);
  tracker.map!.flyTo(camera, animations ?? MapAnimationOptions());
}
