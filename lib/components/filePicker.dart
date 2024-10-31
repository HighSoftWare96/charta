import 'package:Charta/features/gpx/actions.dart';
import 'package:Charta/features/gpx/reducer.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/variables.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class FilePickerWidget extends StatefulWidget {
  const FilePickerWidget({super.key});

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true, type: FileType.any);

    if (result != null && result.files.first.extension == 'gpx') {
      final file = result.files.first;
      StoreProvider.of<RootState>(context).dispatch(LoadGPXFileAction(file));
    }
  }

  _unsetFile() {
    StoreProvider.of<RootState>(context).dispatch(UnloadGPXFileAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: (Store<RootState> store) => store,
      builder: (context, store) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              if (store.state.gpxFeature.status != GPXStatus.pending)
                Icon(
                  Icons.map,
                  color:
                      store.state.gpxFeature.file != null ? accent : textMuted,
                )
              else
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(accent)),
              Container(
                width: 10,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.state.gpxFeature.gpx != null &&
                                store.state.gpxFeature.gpx!.gpx.metadata != null
                            ? store.state.gpxFeature.gpx!.gpx.metadata!.name!
                            : (store.state.gpxFeature.file != null
                                ? store.state.gpxFeature.file!.name
                                : 'Choose GPX file...'),
                        overflow: TextOverflow.ellipsis,
                        style: store.state.gpxFeature.file != null
                            ? TextStyle(
                                fontSize: 20,
                                color: accent,
                                fontWeight: FontWeight.bold)
                            : TextStyle(color: textMuted),
                      ),
                      if (store.state.gpxFeature.status == GPXStatus.pending)
                        Text('Loading file...',
                            style: TextStyle(
                              color: text,
                            )),
                      if (store.state.gpxFeature.status == GPXStatus.loaded)
                        Text('Following',
                            style: TextStyle(
                              color: text,
                            )),
                      if (store.state.gpxFeature.status == GPXStatus.error)
                        Text('Unable to load file, retry!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: danger,
                            ))
                    ]),
              )
            ]),
            store.state.gpxFeature.file != null
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: accent,
                    ),
                    onPressed: _unsetFile,
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: text,
                      backgroundColor: accent,
                      elevation: 0,
                    ),
                    onPressed: _pickFile,
                    child: const Text("Browse"),
                  ),
          ],
        );
      },
    );
  }
}
