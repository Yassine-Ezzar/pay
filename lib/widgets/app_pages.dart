import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/success_screen.dart';
import 'package:get/get.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reset_pin_screen.dart';


class AppPages {
  static final pages = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/register', page: () => RegisterScreen()),
    GetPage(name: '/login', page: () => LoginScreen()),
    GetPage(name: '/reset-pin', page: () => ResetPinScreen()),
    //GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(name: '/success', page: () => SuccessScreen()),
  ];
}