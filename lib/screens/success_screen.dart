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
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeInOut)),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.bounceOut)),
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
      backgroundColor: Colors.white, 
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
                    padding: const EdgeInsets.all(24), 
                    decoration: BoxDecoration(
                      color: const Color(0xFF063B87), 
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: const Size.square(50),
                      painter: CheckMarkPainter(_checkMarkProgress.value),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32), 

              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Congratulations !',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF063B87), 
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16), 

              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Your account is ready to use!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.black, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48), 
              SlideTransition(
                position: _buttonSlideAnimation,
                child: SizedBox(
                  width: 363, 
                  height: 68, 
                  child: ElevatedButton(
                    onPressed: () => Get.offNamed('/bracelet-connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), 
                      ),
                    ),
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
}

class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white 
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
        ..color = const Color(0xFF063B87).withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}