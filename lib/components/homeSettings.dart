import 'package:Charta/components/bearingModePicker.dart';
import 'package:Charta/components/filePicker.dart';
import 'package:Charta/components/stylePicker.dart';
import 'package:Charta/utils/variables.dart';
import 'package:flutter/material.dart';

class HomeSettings extends StatefulWidget {
  const HomeSettings({super.key});

  @override
  State<HomeSettings> createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          height: MediaQuery.sizeOf(context).height,
          width: double.infinity,
          decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 8,
                  decoration: BoxDecoration(
                      color: surface,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 30,
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    children: [
                      FilePickerWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      StylePickerWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      BearingModePickerWidget()
                    ],
                  ),
                )
              ],
            ),
          ));
    });
  }
}
