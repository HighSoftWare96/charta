import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:turf/turf.dart';

GeoJSONGPX parseGPX(PlatformFile file) {
  final utf8Decoded = utf8.decode(file.bytes as List<int>);
  Gpx gpx = GpxReader().fromString(utf8Decoded);
  return GeoJSONGPX(gpx);
}

class GeoJSONGPX {
  Gpx gpx;
  FeatureCollection<Point> waypoints;
  Feature track;
  FeatureCollection<Point> trackPoints;

  factory GeoJSONGPX(Gpx gpx) {
    final wpts = _getGeoJSONWptsFeatureCollection(gpx);
    final trackLine = _getGeoJSONLineFeature(gpx);
    final trackFeature = _getGeoJSONPointFeatureCollection(gpx);

    return GeoJSONGPX._internal(gpx, wpts, trackLine, trackFeature);
  }

  GeoJSONGPX._internal(this.gpx, this.waypoints, this.track, this.trackPoints);

  nearestPointToTrack(Point point) {
    final result = nearestPoint(Feature(geometry: point), trackPoints);
    final distant = distance(point, result.geometry!, Unit.meters);
    final orientation = bearing(point, result.geometry!);
    return {
      'nearestPoint': result,
      'distance': distant,
      'bearing': orientation
    };
  }
}

FeatureCollection<Point> _getGeoJSONWptsFeatureCollection(Gpx gpx) {
  FeatureCollection<Point> geoJSON = FeatureCollection();
  List<Feature<Point>> features = [];

  for (var wpt in gpx.wpts) {
    features.add(_toFeaturePoint(wpt));
  }

  geoJSON.features = features;
  return geoJSON;
}

Feature _getGeoJSONLineFeature(Gpx gpx) {
  Feature geoJSON = Feature(id: '');

  if (gpx.trks.isEmpty) {
    return geoJSON;
  }

  List<Position> coordinates = [];
  final route = gpx.trks.first;

  for (var seg in route.trksegs) {
    for (var wpt in seg.trkpts) {
      if (wpt.lon == null || wpt.lat == null) {
        continue;
      }

      coordinates.add(Position(wpt.lon!, wpt.lat!));
    }
  }

  geoJSON.geometry = LineString(coordinates: coordinates);
  return geoJSON;
}

FeatureCollection<Point> _getGeoJSONPointFeatureCollection(Gpx gpx) {
  FeatureCollection<Point> geoJSON = FeatureCollection();
  List<Feature<Point>> features = [];

  var startingPoint = gpx.trks.first.trksegs.first.trkpts.first;

  for (var seg in gpx.trks.first.trksegs) {
    for (var wpt in seg.trkpts) {
      features.add(_toFeaturePoint(wpt));
    }
  }

  geoJSON.features = features;
  return geoJSON;
}

Feature<Point> _toFeaturePoint(Wpt wpt,
    {Map<String, dynamic> properties = const {}}) {
  return Feature(
      id: '',
      properties: properties,
      geometry: Point(coordinates: Position(wpt.lon!, wpt.lat!)));
}
