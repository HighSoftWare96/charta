// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:ui';

import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/utils/gpx.dart';
import 'package:Charta/utils/variables.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const RECORDED_USER_SOURCE_NAME = 'user_location_source';
const RECORDED_USER_LAYER_NAME = 'user_location_layer';
const WAYPOINTS_SOURCE_NAME = 'gpx_wpts_source';
const WAYPOINTS_LAYER_NAME = 'gpx_wpts';
const TRACK_SOURCE_NAME = 'gpx_track_source';
const TRACK_LAYER_NAME = 'gpx_track';
const TRACK_HELPER_SOURCE_NAME = 'gpx_track_helper_source';
const TRACK_HELPER_LINE_LAYER_NAME = 'gpx_track_helper_line_layer';
const TRACK_HELPER_POINTS_SOURCE_NAME = 'gpx_track_helper_points_source';
const TRACK_HELPER_POINTS_LAYER_NAME = 'gpx_track_helper_points_layer';
const LAYERS = [
  RECORDED_USER_LAYER_NAME,
  WAYPOINTS_LAYER_NAME,
  TRACK_HELPER_LINE_LAYER_NAME,
  TRACK_HELPER_POINTS_LAYER_NAME,
  TRACK_LAYER_NAME
];
const SOURCES = [
  RECORDED_USER_SOURCE_NAME,
  WAYPOINTS_SOURCE_NAME,
  TRACK_SOURCE_NAME,
  TRACK_HELPER_SOURCE_NAME,
  TRACK_HELPER_POINTS_SOURCE_NAME
];

const HELPER_MAX_DISTANCE_METERS = 100;

class MapHandler {
  MapboxMap? map;
  GeoJsonSource? _userRecordedSource;
  GeoJsonSource? _wptSource;
  GeoJsonSource? _trackSource;
  GeoJsonSource? _helperPointsSource;
  GeoJsonSource? _helperLineSource;

  LineLayer? _userRecordedLayer;
  CircleLayer? _wptLayer;
  LineLayer? _trackLayer;
  CircleLayer? _helperPointsLayer;
  LineLayer? _helperLineLayer;

  track(MapboxMap map) {
    this.map = map;
  }

  setup() async {
    await _setupAllLayers();
    await _toggleAllLayers(Visibility.NONE);
  }

  loadGPX(GeoJSONGPX gpx) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    final waypointJson = jsonEncode(gpx.waypoints.toJson());
    await _wptSource!.updateGeoJSON(waypointJson);
    final trackJson = jsonEncode(gpx.track.toJson());
    await _trackSource!.updateGeoJSON(trackJson);
    await _toggleAllLayers(Visibility.VISIBLE);
  }

  updateGPX(
      {required GeoJSONGPX gpx,
      required Point userLocation,
      required double userBearing,
      required BearingMode? bearingMode}) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    if (!await map!.style.styleLayerExists(TRACK_LAYER_NAME)) {
      return;
    }

    final results = gpx.nearestPointToTrack(userLocation);
    final helperLineFeatureJson = jsonEncode(Feature(
        id: '',
        geometry: LineString(coordinates: [
          userLocation.coordinates,
          results['nearestPoint'].geometry.coordinates
        ])).toJson());
    final helperPointFeatureJson = jsonEncode(FeatureCollection(features: [
      Feature<Point>(
          id: '',
          geometry:
              Point(coordinates: results['nearestPoint'].geometry.coordinates))
    ]).toJson());

    await _helperLineSource!.updateGeoJSON(helperLineFeatureJson);
    await _helperPointsSource!.updateGeoJSON(helperPointFeatureJson);

    if (results['distance'] <= HELPER_MAX_DISTANCE_METERS) {
      _helperLineLayer!.visibility = Visibility.NONE;
      _helperPointsLayer!.visibility = Visibility.NONE;
    } else {
      _helperLineLayer!.visibility = Visibility.VISIBLE;
      _helperPointsLayer!.visibility = Visibility.VISIBLE;
    }

    if (bearingMode == BearingMode.followTrack) {
      map!.setCamera(CameraOptions(bearing: results['bearing']));
    } else if (bearingMode == BearingMode.followDevice) {
      map!.setCamera(CameraOptions(bearing: userBearing));
    }
  }

  unloadGPX() async {
    await _toggleAllLayers(Visibility.NONE);
  }

  updateUserLocationTrack(Feature<LineString> points) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    if (!await map!.style.styleLayerExists(RECORDED_USER_LAYER_NAME) ||
        !await map!.style.styleSourceExists(RECORDED_USER_SOURCE_NAME)) {
      return;
    }

    final json = jsonEncode(points.toJson());

    await _userRecordedSource!.updateGeoJSON(json);
  }

  changeStyle(String styleURL, GeoJSONGPX? gpx) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    await map!.style.setStyleURI(styleURL);
    await setup();

    if (gpx != null) {
      await loadGPX(gpx);
    }
  }

  _setupAllLayers() async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    // SOURCES
    _wptSource = await _upsertSource(GeoJsonSource(
        id: WAYPOINTS_SOURCE_NAME,
        data: jsonEncode(FeatureCollection().toJson())));
    _trackSource = await _upsertSource(GeoJsonSource(
        id: TRACK_SOURCE_NAME, data: jsonEncode(FeatureCollection().toJson())));
    _helperLineSource = await _upsertSource(GeoJsonSource(
        id: TRACK_HELPER_SOURCE_NAME,
        data: jsonEncode(FeatureCollection().toJson())));
    _helperPointsSource = await _upsertSource(GeoJsonSource(
        id: TRACK_HELPER_POINTS_SOURCE_NAME,
        data: jsonEncode(FeatureCollection().toJson())));

    // LAYERS
    _wptLayer = await _upsertLayer(CircleLayer(
        id: WAYPOINTS_LAYER_NAME,
        sourceId: WAYPOINTS_SOURCE_NAME,
        circleColor: success.value,
        circleRadius: 10));
    _trackLayer = await _upsertLayer(LineLayer(
      id: TRACK_LAYER_NAME,
      sourceId: TRACK_SOURCE_NAME,
      lineColor: accent.value,
      lineBorderColor: const Color(0xffE4DFDA).value,
      lineBorderWidth: 3,
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineWidthExpression: [
        'interpolate',
        ['linear'],
        ['zoom'],
        15,
        8,
        19,
        20
      ],
    ));
    _helperLineLayer = await _upsertLayer(LineLayer(
        id: TRACK_HELPER_LINE_LAYER_NAME,
        sourceId: TRACK_HELPER_SOURCE_NAME,
        lineColor: warning.value,
        lineDasharray: [2, 2],
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineWidthExpression: [
          'interpolate',
          ['linear'],
          ['zoom'],
          15,
          3,
          19,
          5
        ]));
    _helperPointsLayer = await _upsertLayer(CircleLayer(
        id: TRACK_HELPER_POINTS_LAYER_NAME,
        sourceId: TRACK_HELPER_POINTS_SOURCE_NAME,
        circleColor: warning.value,
        circleStrokeColor: const Color(0xffE4DFDA).value,
        circleStrokeWidth: 2,
        circleRadius: 6));
    _userRecordedSource =
        await _upsertSource(GeoJsonSource(id: RECORDED_USER_SOURCE_NAME));
    _userRecordedLayer = await _upsertLayer(LineLayer(
        id: RECORDED_USER_LAYER_NAME,
        sourceId: RECORDED_USER_SOURCE_NAME,
        lineColor: danger.value,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineWidth: 20));
  }

  _toggleAllLayers(Visibility visibility) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    for (var layerName in LAYERS) {
      if (await map!.style.styleLayerExists(layerName)) {
        final layer = await map!.style.getLayer(layerName);
        layer!.visibility = visibility;
        await map!.style.updateLayer(layer);
      }
    }
  }

  Future<T> _upsertLayer<T extends Layer>(T definition) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    if (await map!.style.styleLayerExists(definition.id)) {
      return await map!.style.getLayer(definition.id) as T;
    } else {
      await map!.style.addLayer(definition);
      return definition;
    }
  }

  Future<T> _upsertSource<T extends GeoJsonSource>(T definition) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    if (await map!.style.styleSourceExists(definition.id)) {
      final source = await map!.style.getSource(definition.id) as T;
      return source;
    } else {
      await map!.style.addSource(definition);
      return definition;
    }
  }
}

MapHandler mapHandler = MapHandler();
