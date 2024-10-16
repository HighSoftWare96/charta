import 'package:Charta/features/map/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class StylePickerData {
  String styleURL;
  String assetPath;
  String name;

  StylePickerData(
      {required this.styleURL, required this.assetPath, required this.name});
}

// ignore: non_constant_identifier_names
List<StylePickerData> STYLES = [
  StylePickerData(
      assetPath: 'assets/images/navigation-light.png',
      styleURL: 'mapbox://styles/mapbox/navigation-day-v1',
      name: 'Light'),
  StylePickerData(
      assetPath: 'assets/images/navigation-dark.png',
      styleURL: 'mapbox://styles/mapbox/navigation-night-v1',
      name: 'Dark'),
  StylePickerData(
      assetPath: 'assets/images/satellite.png',
      styleURL: 'mapbox://styles/mapbox/satellite-streets-v12',
      name: 'Satellite'),
];

class StylePickerWidget extends StatefulWidget {
  const StylePickerWidget({super.key});

  @override
  State<StylePickerWidget> createState() => _StylePickerWidgetState();
}

class _StylePickerWidgetState extends State<StylePickerWidget> {
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
                  'Map style',
                  style: TextStyle(color: Color(0xff4281A4), fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var style in STYLES)
                      GestureDetector(
                          onTap: () => changeStyle(style),
                          child: Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Column(children: [
                                Container(
                                    padding:
                                        const EdgeInsets.all(5), // Border width
                                    decoration: BoxDecoration(
                                      color:
                                          store.state.mapFeature.mapStyleURL ==
                                                  style.styleURL
                                              ? const Color(0xff4281A4)
                                              : Colors.transparent,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6)),
                                      child: Image(
                                        image: AssetImage(style.assetPath),
                                        width: (constraints.maxWidth /
                                                STYLES.length) -
                                            (5 * STYLES.length),
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      style.name,
                                      style: TextStyle(
                                          color: store.state.mapFeature
                                                      .mapStyleURL ==
                                                  style.styleURL
                                              ? Colors.black45
                                              : Colors.black26),
                                    ))
                              ])))
                  ],
                )
              ],
            );
          });
        });
  }

  changeStyle(StylePickerData style) {
    StoreProvider.of<RootState>(context)
        .dispatch(ChangeMapStyleAction(style.styleURL));
  }
}
