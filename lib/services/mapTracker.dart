// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:ui';

import 'package:Charta/utils/gpx.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const USER_SOURCE_NAME = 'user_location_source';
const USER_LAYER_NAME = 'user_location_layer';
const WAYPOINTS_SOURCE_NAME = 'gpx_wpts_source';
const WAYPOINTS_LAYER_NAME = 'gpx_wpts';
const TRACK_SOURCE_NAME = 'gpx_track_source';
const TRACK_HELPER_SOURCE_NAME = 'gpx_track_helper_source';
const TRACK_HELPER_LINE_LAYER_NAME = 'gpx_track_helper_line_layer';
const TRACK_HELPER_POINTS_SOURCE_NAME = 'gpx_track_helper_points_source';
const TRACK_HELPER_POINTS_LAYER_NAME = 'gpx_track_helper_points_layer';
const TRACK_LAYER_NAME = 'gpx_track';

const HELPER_MAX_DISTANCE_METERS = 100;

class MapTracker {
  MapboxMap? map;
  GeoJsonSource? userRecordedSource;
  GeoJsonSource? wptSource;
  GeoJsonSource? trackSource;
  GeoJsonSource? helperPointsSource;
  GeoJsonSource? helperLineSource;

  LineLayer? userRecordedLayer;
  CircleLayer? wptLayer;
  LineLayer? trackLayer;
  CircleLayer? helperPointsLayer;
  LineLayer? helperLineLayer;

  void track(MapboxMap map) {
    this.map = map;
  }

  loadGPX(GeoJSONGPX gpx) async {
    if (map == null) {
      throw 'Invalid map state!';
    }

    final waypointJson = jsonEncode(gpx.waypoints.toJson());
    wptSource ??= await _upsertSource(
        GeoJsonSource(id: WAYPOINTS_SOURCE_NAME, data: waypointJson));
    final trackJson = jsonEncode(gpx.track.toJson());
    trackSource ??= await _upsertSource(
        GeoJsonSource(id: TRACK_SOURCE_NAME, data: trackJson));

    wptLayer ??= await _upsertLayer(CircleLayer(
        id: WAYPOINTS_LAYER_NAME,
        sourceId: WAYPOINTS_SOURCE_NAME,
        circleColor: const Color(0xff48A9A6).value,
        circleRadius: 10));

    trackLayer ??= await _upsertLayer(LineLayer(
        id: TRACK_LAYER_NAME,
        sourceId: TRACK_SOURCE_NAME,
        lineColor: const Color(0xff4281A4).value,
        lineBorderColor: const Color(0xffE4DFDA).value,
        lineBorderWidth: 3,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineWidth: 20));

    helperLineSource ??=
        await _upsertSource(GeoJsonSource(id: TRACK_HELPER_SOURCE_NAME));
    helperPointsSource ??=
        await _upsertSource(GeoJsonSource(id: TRACK_HELPER_POINTS_SOURCE_NAME));

    helperLineLayer ??= await _upsertLayer(LineLayer(
        id: TRACK_HELPER_LINE_LAYER_NAME,
        sourceId: TRACK_HELPER_SOURCE_NAME,
        lineColor: const Color(0xffD4B483).value,
        lineDasharray: [2, 2],
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineWidth: 5));
    helperPointsLayer ??= await _upsertLayer(CircleLayer(
        id: TRACK_HELPER_POINTS_LAYER_NAME,
        sourceId: TRACK_HELPER_POINTS_SOURCE_NAME,
        circleColor: const Color(0xffD4B483).value,
        circleStrokeColor: const Color(0xffE4DFDA).value,
        circleStrokeWidth: 2,
        circleRadius: 6));

    userRecordedSource ??=
        await _upsertSource(GeoJsonSource(id: USER_SOURCE_NAME));
    userRecordedLayer ??= await _upsertLayer(LineLayer(
        id: USER_LAYER_NAME,
        sourceId: USER_SOURCE_NAME,
        lineColor: const Color(0xffC1666B).value,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineWidth: 20));
  }

  updateGPX(GeoJSONGPX gpx, Point userLocation, bool forceBearing) async {
    if (map == null) {
      throw 'Invalid map state!';
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

    await helperLineSource!.updateGeoJSON(helperLineFeatureJson);
    await helperPointsSource!.updateGeoJSON(helperPointFeatureJson);

    if (results['distance'] <= HELPER_MAX_DISTANCE_METERS) {
      helperLineLayer!.visibility = Visibility.NONE;
      helperPointsLayer!.visibility = Visibility.NONE;
    } else {
      helperLineLayer!.visibility = Visibility.VISIBLE;
      helperPointsLayer!.visibility = Visibility.VISIBLE;
    }

    if (forceBearing) {
      map!.setCamera(CameraOptions(bearing: results['bearing']));
    }
  }

  unloadGPX() async {
    if (map == null) {
      return;
    }

    await map!.style.removeStyleLayer(USER_LAYER_NAME);
    await map!.style.removeStyleSource(USER_SOURCE_NAME);
    await map!.style.removeStyleLayer(WAYPOINTS_LAYER_NAME);
    await map!.style.removeStyleSource(WAYPOINTS_SOURCE_NAME);
    await map!.style.removeStyleLayer(TRACK_LAYER_NAME);
    await map!.style.removeStyleSource(TRACK_SOURCE_NAME);
    await map!.style.removeStyleLayer(TRACK_HELPER_LINE_LAYER_NAME);
    await map!.style.removeStyleSource(TRACK_HELPER_SOURCE_NAME);
    await map!.style.removeStyleLayer(TRACK_HELPER_POINTS_LAYER_NAME);
    await map!.style.removeStyleSource(TRACK_HELPER_POINTS_SOURCE_NAME);
  }

  updateUserLocationTrack(Feature<LineString> points) async {
    final json = jsonEncode(points.toJson());

    await userRecordedSource!.updateGeoJSON(json);
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

MapTracker tracker = MapTracker();
