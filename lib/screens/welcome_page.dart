import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/styles.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB085EB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Styles.defaultPadding * 2),
              const Text(
                'The best way\nTo store\nMoney',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87),
                  height: 1.2,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              const Text(
                'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF063B87),
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
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
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
                child: const Text(
                  'If you forget your Password !',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF063B87),
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