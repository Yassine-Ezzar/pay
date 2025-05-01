import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class CheckingScreen extends StatefulWidget {
  @override
  _CheckingScreenState createState() => _CheckingScreenState();
}

class _CheckingScreenState extends State<CheckingScreen>
    with SingleTickerProviderStateMixin {
  bool _isButtonEnabled = false; 
  late AnimationController _animationController;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); 

    _dot1Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _dot2Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
      ),
    );

    _dot3Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    Timer(const Duration(seconds: 9), () {
      setState(() {
        _isButtonEnabled = true; 
        _animationController.stop(); 
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Checking!\nPlease wait ...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87),
                  height: 1.2,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              const Text(
                'Your account is being checked before ready to use.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _dot1Animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _dot1Animation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _dot2Animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _dot2Animation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _dot3Animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _dot3Animation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          Get.offNamed('/success');
                        }
                      : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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