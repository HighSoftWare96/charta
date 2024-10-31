import 'package:Charta/screens/home.dart';
import 'package:Charta/store/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:redux/redux.dart';
import "package:Charta/store/middlewares.dart";
import "package:Charta/features/gpx/middlewares.dart";
import "package:Charta/features/map/middlewares.dart";
import "package:Charta/features/location/middlewares.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String mapboxAccessToken = const String.fromEnvironment("ACCESS_TOKEN");
  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final store = Store(rootReducer,
      initialState: RootState.initialState(),
      middleware: [
        rootMiddleware,
        locationMiddleware,
        gpxMiddleware,
        mapMiddleware
      ]);

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
          title: 'Charta',
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            /* dark theme settings */
          ),
          themeMode: ThemeMode.dark,
          home: const Home(),
        ));
  }
}

// palette: https://coolors.co/52489c-4062bb-59c3c3-ebebeb-f45b69