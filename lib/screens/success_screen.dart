import 'package:app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor, 
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(Styles.defaultPadding * 1.5), 
                decoration: BoxDecoration(
                  color: Styles.defaultYellowColor, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Styles.defaultGreyColor.withOpacity(0.3), 
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  size: 50, 
                  color: Styles.defaultBlueColor, 
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2), 
              Text(
                'WELL DONE!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Styles.defaultYellowColor, 
                  letterSpacing: 1.2, 
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Styles.defaultPadding),
            
              Text(
                'Welcome to SmartPay!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  color: Styles.defaultLightWhiteColor, 
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Styles.defaultPadding * 3),
              GestureDetector(
                onTap: () => Get.offNamed('/home'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Styles.defaultPadding,
                    horizontal: Styles.defaultPadding * 2.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Styles.defaultGreyColor, 
                        Styles.defaultBlueColor, 
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: Styles.defaultBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Styles.defaultGreyColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Styles.defaultYellowColor, 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}