import 'package:Charta/features/gpx/reducer.dart';
import 'package:Charta/features/location/reducer.dart';
import 'package:Charta/features/map/reducer.dart';

class RootState {
  final GPXState gpx;
  final LocationState location;
  final MapState map;

  RootState.initialState()
      : gpx = GPXState.initialState(),
        location = LocationState.initialState(),
        map = MapState.initialState();

  RootState({required this.gpx, required this.location, required this.map});
}

RootState rootReducer(RootState state, dynamic action) => RootState(
    gpx: gpxReducer(state, action),
    location: locationReducer(state, action),
    map: mapReducer(state, action));
