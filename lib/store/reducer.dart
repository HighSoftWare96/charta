import 'package:Charta/features/gpx/reducer.dart';
import 'package:Charta/features/location/reducer.dart';
import 'package:Charta/features/map/reducer.dart';

class RootState {
  final GPXState gpxFeature;
  final LocationState locationFeature;
  final MapState mapFeature;

  RootState.initialState()
      : gpxFeature = GPXState.initialState(),
        locationFeature = LocationState.initialState(),
        mapFeature = MapState.initialState();

  RootState({required this.gpxFeature, required this.locationFeature, required this.mapFeature});
}

RootState rootReducer(RootState state, dynamic action) => RootState(
    gpxFeature: gpxReducer(state, action),
    locationFeature: locationReducer(state, action),
    mapFeature: mapReducer(state, action));
