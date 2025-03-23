import 'package:app/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/notifications');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFF0A0E21),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Styles.defaultPadding,
                            vertical: Styles.defaultPadding / 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Profile Page\n(To be implemented)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
          CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavItemTapped,
          ),
        ],
      ),
    );
  }
}