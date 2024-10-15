import 'package:Charta/features/map/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/store/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class LeftSidebarWidget extends StatefulWidget {
  const LeftSidebarWidget({super.key});

  @override
  State<LeftSidebarWidget> createState() => _LeftSidebarWidgetState();
}

class _LeftSidebarWidgetState extends State<LeftSidebarWidget> {
  _toggleMapMode() {
    StoreProvider.of<RootState>(context).dispatch(ToggleMapModeAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (context, store) {
          return Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _toggleMapMode,
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: const Color(0xfff4f2f0)),
                        child: Icon(
                            store.state.mapFeature.mode == MapMode.centered
                                ? Icons.route
                                : Icons.navigation,
                            color: store.state.mapFeature.mode == MapMode.centered
                                ? (store.state.gpxFeature.file != null
                                    ? Colors.black38
                                    : Colors.black26)
                                : const Color(0xff4281A4)),
                      ),
                    ],
                  ),
                )),
          );
        },
        converter: (Store<RootState> store) => store);
  }
}
