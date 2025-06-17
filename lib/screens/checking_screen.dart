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
  late Animation<double> _scaleAnimation;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageController = PageController(viewportFraction: 0.9);

    // Auto-slide through pages every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 2 && !_isButtonEnabled) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      } else if (_currentPage >= 2 && !_isButtonEnabled) {
        timer.cancel();
      }
    });

    // Enable button after 9 seconds
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Styles.darkDefaultBlueColor : const Color(0xFF0066FF);
    final secondaryColor = isDark ? Styles.darkDefaultYellowColor : const Color(0xFF063B87);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                        }
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: _buildCardContent(index, primaryColor, secondaryColor),
                    );
                  },
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index 
                          ? primaryColor 
                          : primaryColor.withOpacity(0.4),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isButtonEnabled ? 1.0 : _scaleAnimation.value,
                    child: Opacity(
                      opacity: _isButtonEnabled ? 1.0 : 0.7,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () => Get.offNamed('/success')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    child: Text(
                      'go_to_home'.tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  Widget _buildCardContent(int index, Color primaryColor, Color secondaryColor) {
    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Welcome ',
        'description': 'Contactless payments made elegant and effortless with your smart wearable.',
        'icon': Icons.credit_card,
      },
      {
        'title': 'Simple & Secure',
        'description': '1. Tap your bracelet\n2. Authenticate with a gesture\n3. Payment complete',
        'icon': Icons.touch_app,
      },
      {
        'title': 'Seamless Experience',
        'description': 'Enjoy instant transactions with bank-level security and no extra fees.',
        'icon': Icons.bolt,
      },
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                pages[index]['icon'],
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pages[index]['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pages[index]['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}