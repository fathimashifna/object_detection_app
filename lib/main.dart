import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:object_detection_app/res/app_colors.dart';
import 'package:object_detection_app/utils/routes/route_names.dart';
import 'package:object_detection_app/utils/routes/routes.dart';
import 'package:object_detection_app/view/splash_screen.dart';

Future<void> main()  async {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  const MyApp({Key? key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
       initialRoute: RouteNames.splashScreen,
      onGenerateRoute: Routes.generateRoutes,
    );
  }
}
