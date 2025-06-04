import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/styles.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Styles.darkScaffoldBackgroundColor
          : const Color(0xFFB085EB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Styles.defaultPadding * 2),
              Text(
                'welcome_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultYellowColor
                      : const Color(0xFF063B87),
                  height: 1.2,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              Text(
                'welcome_description'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightWhiteColor
                      : const Color(0xFF063B87),
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offNamed('/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor
                        : const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius,
                    ),
                  ),
                  child: Text(
                    'get_started'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/reset-pin');
                },
                child: Text(
                  'forgot_password'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultLightWhiteColor
                        : const Color(0xFF063B87),
                    decoration: TextDecoration.underline,
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