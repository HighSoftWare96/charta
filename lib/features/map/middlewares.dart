import 'package:Charta/features/location/actions.dart';
import 'package:Charta/features/map/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/services/geolocator.dart';
import 'package:Charta/services/mapTracker.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:redux/redux.dart';

GeoLocatorHelper locator = GeoLocatorHelper();
void mapMiddleware(Store<RootState> store, action, NextDispatcher next) {
  if (action is ToggleMapModeAction && tracker.map != null) {
    if (store.state.map.mode == MapMode.free) {
      _centerMapToUserLocation(store.state.location.userLocation!,
          MapAnimationOptions(duration: 1500));
    } else {
      // TODO: fit all gpx if there is one
    }
  } else if (action is UserLocationUpdateAction &&
      store.state.map.mode == MapMode.centered &&
      store.state.location.userLocation != null) {
    _centerMapToUserLocation(store.state.location.userLocation!, null);
  }

  next(action);
}

void _centerMapToUserLocation(Point location, MapAnimationOptions? animations) {
  CameraOptions camera = cameraDefaultWith(location);
  tracker.map!.flyTo(camera, animations ?? MapAnimationOptions());
}
