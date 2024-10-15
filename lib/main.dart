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
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff4281A4)),
            typography: Typography.material2021(),
            useMaterial3: true,
          ),
          home: const Home(),
        ));
  }
}

// palette: https://coolors.co/4281a4-48a9a6-e4dfda-d4b483-c1666b