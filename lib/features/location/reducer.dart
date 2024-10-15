import 'package:Charta/features/gpx/actions.dart';
import 'package:Charta/features/location/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:turf/turf.dart' as turf;

enum LocationPermissionState { refused, accepted, pending }

const RECORD_MIN_DISTANCE_METERS = 20;

class LocationState {
  final LocationPermissionState _permissionState;
  final Point? _userLocation;
  final Feature<LineString> _userRecordedTrack;

  LocationPermissionState get permissionsState => _permissionState;
  Point? get userLocation => _userLocation;
  Feature<LineString> get userRecordedTrack => _userRecordedTrack;

  LocationState.initialState()
      : _userRecordedTrack =
            Feature(id: '', geometry: LineString(coordinates: [])),
        _permissionState = LocationPermissionState.pending,
        _userLocation = null;

  LocationState.copyWith(LocationState state,
      {StoreValue<LocationPermissionState>? permissionsState,
      StoreValue<Feature<LineString>>? recorded,
      StoreValue<Point>? userLocation})
      : _permissionState = permissionsState != null
            ? permissionsState.value
            : state._permissionState,
        _userRecordedTrack =
            recorded != null ? recorded.value : state._userRecordedTrack,
        _userLocation =
            userLocation != null ? userLocation.value : state._userLocation;
}

LocationState locationReducer(RootState state, dynamic action) {
  if (action is RequestLocationAction) {
    return LocationState.copyWith(state.locationFeature,
        permissionsState: const StoreValue.of(LocationPermissionState.pending));
  } else if (action is RequestLocationActionSuccess) {
    return LocationState.copyWith(state.locationFeature,
        permissionsState:
            const StoreValue.of(LocationPermissionState.accepted));
  } else if (action is RequestLocationActionError) {
    return LocationState.copyWith(state.locationFeature,
        permissionsState: const StoreValue.of(LocationPermissionState.refused));
  } else if (action is UserLocationUpdateAction) {
    final recorded = state.locationFeature.userRecordedTrack;

    if (state.gpxFeature.gpx != null &&
        (recorded.geometry!.coordinates.isEmpty ||
            turf.distance(
                    Point(coordinates: recorded.geometry!.coordinates.last),
                    action.location,
                    Unit.meters) >
                RECORD_MIN_DISTANCE_METERS)) {
      recorded.geometry!.coordinates.add(action.location.coordinates);
    }

    return LocationState.copyWith(state.locationFeature,
        recorded: StoreValue.of(recorded),
        permissionsState: const StoreValue.of(LocationPermissionState.accepted),
        userLocation: StoreValue.of(action.location));
  } else if (action is UnloadGPXFileAction ||
      action is LoadGPXFileSuccessAction) {
    return LocationState.copyWith(state.locationFeature,
        recorded: StoreValue.of(
            Feature(id: '', geometry: LineString(coordinates: []))));
  }

  return state.locationFeature;
}
