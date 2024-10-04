import 'package:Charta/services/geolocator.dart';
import 'package:Charta/services/mapTracker.dart';
import 'package:Charta/store/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/defaults.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:redux/redux.dart';

class MapWidgetWrapper extends StatefulWidget {
  const MapWidgetWrapper({super.key});

  @override
  State<MapWidgetWrapper> createState() => _MapWidgetWrapperState();
}

class _MapWidgetWrapperState extends State<MapWidgetWrapper> {
  MapboxMap? mapboxMap;
  LocationComponentSettings? locationSettings;

  CameraOptions defaultCameraOptions = CAMERA_DEFAULT_OPTIONS;

  void _onMapCreated(AppState state, MapboxMap map) async {
    mapboxMap = map;
    tracker.track(map);

    const expression = '["interpolate",["linear"],["zoom"],15,0.2,19,0.45]';
    final bearingBytes = await rootBundle.load('assets/images/navigation.png');
    final Uint8List list = bearingBytes.buffer.asUint8List();
    final settings = LocationComponentSettings(
        enabled: true,
        showAccuracyRing: true,
        accuracyRingColor: Colors.white54.withAlpha(70).value,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(
            locationPuck2D: LocationPuck2D(
                topImage: list, scaleExpression: expression, opacity: 0.8)));
    locationSettings ??= settings;
    await mapboxMap!.location.updateSettings(settings);
    await mapboxMap!.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    _setBearingMode(state);
    _subscribeToLocation();
  }

  void _onUserChangesCamera(dynamic event) {
    StoreProvider.of<AppState>(context)
        .dispatch(MapCameraChangesByUserAction());
  }

  void _onCameraChanges(CameraChangedEventData event) async {
    final camera = await tracker.map!.getCameraState();
    StoreProvider.of<AppState>(context).dispatch(MapBoundsUpdateAction(camera));
  }

  _setBearingMode(AppState state) {
    if (mapboxMap == null || locationSettings == null) {
      return;
    }

    if (state.gpxLoaded != null) {
      locationSettings!.puckBearing = PuckBearing.COURSE;
    } else {
      locationSettings!.puckBearing = PuckBearing.HEADING;
    }

    mapboxMap!.location.updateSettings(locationSettings!);
  }

  _subscribeToLocation() {
    geolocator.subscribe((location) {
      StoreProvider.of<AppState>(context)
          .dispatch(UserLocationUpdateAction(location));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: (Store<AppState> store) => store,
      builder: (context, store) {
        CameraOptions camera = cameraDefaultWith(store.state.userLocation);

        _setBearingMode(store.state);

        return MapWidget(
          key: const ValueKey("mapWidget"),
          styleUri: 'mapbox://styles/gbertoncelli/cm1t9t9na00wy01qrea9w5nlt',
          cameraOptions: camera,
          onScrollListener: _onUserChangesCamera,
          onTapListener: _onUserChangesCamera,
          onMapCreated: (map) => _onMapCreated(store.state, map),
          onCameraChangeListener: _onCameraChanges,
        );
      },
    );
  }
}
