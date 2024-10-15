import 'package:Charta/features/location/actions.dart';
import 'package:Charta/services/geolocator.dart';
import 'package:Charta/store/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

GeoLocatorHelper locator = GeoLocatorHelper();
void locationMiddleware(Store<RootState> store, action, NextDispatcher next) {
  if (action is RequestLocationAction) {
    Permission.locationWhenInUse.request().then((status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        throw 'denied';
      }

      if (action.onSuccess != null) action.onSuccess!();
      store.dispatch(RequestLocationActionSuccess());
    }).catchError((Object e) {
      if (action.onError != null) {
        action.onError!(e);
      }

      store.dispatch(RequestLocationActionError(e.toString()));
    });
  } else if (action is DisposeApp) {
    locator.unsubscribe();
  }

  next(action);
}
