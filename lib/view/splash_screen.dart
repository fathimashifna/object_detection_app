import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:object_detection_app/res/app_colors.dart';
import 'package:object_detection_app/utils/routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    
    gotoNext();

  }
  void gotoNext()async{
    //Open next page after few seconds
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushNamed(context, RouteNames.itemScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  height: 150,
                  child: Image.asset('assets/images/app_icon_new.png')),
              Text('Object Detection'.toUpperCase(),
                maxLines: 2,
                style: GoogleFonts.inter(fontSize: 20,fontWeight: FontWeight.bold,color: AppColors.color_primary),)
            ],
          ),
        ),
      ),
    );
  }
}