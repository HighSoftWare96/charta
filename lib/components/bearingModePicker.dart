import 'package:Charta/features/map/actions.dart';
import 'package:Charta/features/map/reducer.dart';
import 'package:Charta/store/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class BearingModePickerWidget extends StatefulWidget {
  const BearingModePickerWidget({super.key});

  @override
  State<BearingModePickerWidget> createState() =>
      _BearingModePickerWidgetState();
}

class _BearingModePickerWidgetState extends State<BearingModePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        converter: (Store<RootState> store) => store,
        builder: (context, store) {
          return LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bearing mode',
                  style: TextStyle(
                      color: Color(0xff4281A4),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () =>
                                changeBearingMode(BearingMode.followDevice),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: store.state.mapFeature.bearingMode !=
                                          BearingMode.followDevice
                                      ? const Color(0xffE4DFDA)
                                      : Colors.white60,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                              child: Text('Follow device',
                                  style: TextStyle(
                                      color:
                                          store.state.mapFeature.bearingMode ==
                                                  BearingMode.followDevice
                                              ? const Color(0xff4281A4)
                                              : Colors.black26)),
                            ))),
                    Expanded(
                        child: GestureDetector(
                            onTap: () =>
                                changeBearingMode(BearingMode.followTrack),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: store.state.mapFeature.bearingMode !=
                                          BearingMode.followTrack
                                      ? const Color(0xffE4DFDA)
                                      : Colors.white60,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: Text('Follow track',
                                  style: TextStyle(
                                      color:
                                          store.state.mapFeature.bearingMode ==
                                                  BearingMode.followTrack
                                              ? const Color(0xff4281A4)
                                              : Colors.black26)),
                            ))),
                  ],
                )
              ],
            );
          });
        });
  }

  changeBearingMode(BearingMode mode) {
    StoreProvider.of<RootState>(context)
        .dispatch(ChangeBearingModeAction(mode));
  }
}
