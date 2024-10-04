import 'package:Charta/store/actions.dart';
import 'package:Charta/store/reducer.dart';
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
        .pickFiles(allowMultiple: false, type: FileType.any);

    if (result != null && result.files[0].extension == 'gpx') {
      final file = result.files[0];
      StoreProvider.of<AppState>(context).dispatch(LoadGPXFileAction(file));
    }
  }

  _unsetFile() {
    StoreProvider.of<AppState>(context).dispatch(UnloadGPXFileAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: (Store<AppState> store) => store,
      builder: (context, store) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(
                Icons.map,
                color: store.state.gpxLoaded != null
                    ? const Color(0xff4281A4)
                    : Colors.black26,
              ),
              Container(
                width: 10,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: Text(
                  store.state.gpxLoaded != null
                      ? store.state.gpxLoaded!.file.name
                      : 'Choose GPX file...',
                  overflow: TextOverflow.ellipsis,
                  style: store.state.gpxLoaded != null
                      ? const TextStyle(
                          color: Color(0xff4281A4), fontWeight: FontWeight.bold)
                      : const TextStyle(color: Colors.black26),
                ),
              )
            ]),
            store.state.gpxLoaded != null
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff4281A4),
                    ),
                    onPressed: _unsetFile,
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff4281A4),
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
