import 'package:flutter/material.dart';
import 'package:object_detection_app/utils/routes/route_names.dart';
import 'package:object_detection_app/view/item_list_screen.dart';
import 'package:object_detection_app/view/object_detection_screen.dart';
import '../../view/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {


      case (RouteNames.splashScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case (RouteNames.itemScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ItemListScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("No route is configured"),
            ),
          ),
        );
    }
  }
}
