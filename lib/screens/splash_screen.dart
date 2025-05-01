import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/styles.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Get.offNamed('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          '',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Styles.defaultYellowColor,
          ),
        ),
      ),
    );
  }
}