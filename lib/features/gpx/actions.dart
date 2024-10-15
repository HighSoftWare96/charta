import 'package:Charta/utils/gpx.dart';
import 'package:Charta/utils/redux.dart';
import 'package:file_picker/file_picker.dart';

class LoadGPXFileAction {
  PlatformFile file;

  LoadGPXFileAction(this.file);
}

class LoadGPXFileSuccessAction {
  GeoJSONGPX gpx;

  LoadGPXFileSuccessAction(this.gpx);
}

class LoadGPXFileErrorAction extends ErrorAction {
  LoadGPXFileErrorAction(super.message);
}

class UnloadGPXFileAction {}
