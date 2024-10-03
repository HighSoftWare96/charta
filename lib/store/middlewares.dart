import 'package:Charta/services/mapTracker.dart';
import 'package:Charta/store/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:Charta/utils/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

GeoLocatorHelper locator = GeoLocatorHelper();

void middleware(Store<AppState> store, action, NextDispatcher next) {
  if (action is RequestLocationAction) {
    Permission.locationWhenInUse.request().then((status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        throw 'denied';
      }

      if (action.onSuccess != null) {
        action.onSuccess!();
      }

      // polling for location
      locator.subscribe((position) {
        store.dispatch(RequestLocationActionSuccess(location: position));
      });
    }).catchError((Object e) {
      if (action.onError != null) {
        action.onError!(e);
      }

      store.dispatch(RequestLocationActionError(e.toString()));
    });
  } else if (action is DisposeApp) {
    locator.unsubscribe();
  } else if (action is ToggleMapModeAction && tracker.map != null) {
    if (store.state.mapMode == MapMode.free) {
      CameraOptions camera = cameraDefaultWith(
          store.state.userLocation!.longitude,
          store.state.userLocation!.latitude);
      tracker.map!.flyTo(camera, MapAnimationOptions(duration: 1500));
    } else {
      // TODO: fit all gpx if there is one
    }
  }

  next(action);
}
