import 'package:Charta/components/leftSidebar.dart';
import 'package:Charta/components/map.dart';
import 'package:Charta/store/actions.dart';
import 'package:Charta/store/reducer.dart';
import 'package:Charta/utils/hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    onFirstBuild((_) {
      StoreProvider.of<AppState>(context).dispatch(RequestLocationAction());
    });
  }

  @override
  void dispose() {
    StoreProvider.of<AppState>(context).dispatch(DisposeApp());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        converter: (Store<AppState> store) => store,
        builder: (context, store) {
          return Scaffold(
            body: LayoutBuilder(builder: (context, constraints) {
              if (store.state.userLocation == null) {
                return const Center(
                  child: Text(
                    'Fetching your location...',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Stack(
                children: [
                  const MapWidgetWrapper(),
                  const LeftSidebarWidget(),
                  Positioned.fill(
                      top: constraints.maxHeight * 0.9,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                      ))
                ],
              );
            }),
          );
        });
  }
}
