import 'package:Charta/features/gpx/actions.dart';
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
              Icon(
                Icons.map,
                color: store.state.gpx.file != null
                    ? const Color(0xff4281A4)
                    : Colors.black26,
              ),
              Container(
                width: 10,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: Text(
                  store.state.gpx.file != null
                      ? store.state.gpx.file!.file.name
                      : 'Choose GPX file...',
                  overflow: TextOverflow.ellipsis,
                  style: store.state.gpx.file != null
                      ? const TextStyle(
                          color: Color(0xff4281A4), fontWeight: FontWeight.bold)
                      : const TextStyle(color: Colors.black26),
                ),
              )
            ]),
            store.state.gpx.file != null
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
