import 'package:app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkMarkProgress;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _checkMarkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.4, 0.8, curve: Curves.easeInOut)),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: Offset(0, 1), 
      end: Offset.zero, 
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.bounceOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
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
                    child: CustomPaint(
                      size: Size.square(50), 
                      painter: CheckMarkPainter(_checkMarkProgress.value),
                    ),
                  );
                },
              ),
              SizedBox(height: Styles.defaultPadding * 2),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
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
              ),
              SizedBox(height: Styles.defaultPadding),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Welcome to SmartPay!',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 18,
                    color: Styles.defaultLightWhiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 3),

              SlideTransition(
                position: _buttonSlideAnimation,
                child: GestureDetector(
                  onTap: () => Get.offNamed('/bracelet-connect'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Styles.defaultPadding,
                      horizontal: Styles.defaultPadding * 2.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.defaultGreyColor, Styles.defaultBlueColor],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Styles.defaultBlueColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.lineTo(size.width * 0.75, size.height * 0.3);

    final metrics = path.computeMetrics().first;
    final subPath = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(subPath, paint);

    
    if (progress >= 1.0) {
      final glowPaint = Paint()
        ..color = Styles.defaultYellowColor.withOpacity(0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}