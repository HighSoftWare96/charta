import 'package:Charta/components/filePicker.dart';
import 'package:flutter/material.dart';

class HomeSettings extends StatefulWidget {
  const HomeSettings({super.key});

  @override
  State<HomeSettings> createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 500,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                    color: Colors.grey.withAlpha(50),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                  top: 30,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  children: [FilePickerWidget()],
                ),
              )
            ],
          ),
        ));
  }
}
