import 'package:Charta/services/geolocator.dart';
import 'package:Charta/store/reducer.dart';
import 'package:redux/redux.dart';

GeoLocatorHelper locator = GeoLocatorHelper();
void rootMiddleware(Store<RootState> store, action, NextDispatcher next) {
  next(action);
}
