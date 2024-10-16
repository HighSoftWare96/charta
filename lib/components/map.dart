import 'package:Charta/features/location/actions.dart';
import 'package:Charta/features/map/actions.dart';
import 'package:Charta/services/geolocator.dart';
import 'package:Charta/services/mapHandler.dart';
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

  void _onMapCreated(RootState state, MapboxMap map) async {
    mapboxMap = map;
    mapHandler.track(map);

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

    await mapHandler.setup();
  }

  void _onUserChangesCamera(dynamic event) {
    StoreProvider.of<RootState>(context)
        .dispatch(MapCameraChangesByUserAction());
  }

  void _onCameraChanges(CameraChangedEventData event) async {
    final camera = await mapHandler.map!.getCameraState();
    StoreProvider.of<RootState>(context)
        .dispatch(MapBoundsUpdateAction(camera));
  }

  _setBearingMode(RootState state) {
    if (mapboxMap == null || locationSettings == null) {
      return;
    }

    if (state.gpxFeature.file != null) {
      locationSettings!.puckBearing = PuckBearing.COURSE;
    } else {
      locationSettings!.puckBearing = PuckBearing.HEADING;
    }

    mapboxMap!.location.updateSettings(locationSettings!);
  }

  _subscribeToLocation() {
    geolocator.subscribe((update) {
      StoreProvider.of<RootState>(context)
          .dispatch(UserLocationUpdateAction(update.location, update.bearing));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: (Store<RootState> store) => store,
      builder: (context, store) {
        CameraOptions camera =
            cameraDefaultWith(store.state.locationFeature.userLocation);

        _setBearingMode(store.state);

        return MapWidget(
          key: const ValueKey("mapWidget"),
          styleUri: store.state.mapFeature.mapStyleURL,
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
