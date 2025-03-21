import 'package:app/screens/add_card_screen.dart';
import 'package:app/screens/bracelet_connect_screen.dart';
import 'package:app/screens/bracelet_management_screen.dart';
import 'package:app/screens/card_list_screen.dart';
import 'package:app/screens/home_screen.dart';
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
    GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(name: '/success', page: () => SuccessScreen()),
    GetPage(name: '/add-card', page: () => AddCardScreen()),
    GetPage(name: '/card-list', page: () => CardListScreen()),
    GetPage(name: '/bracelet-connect', page: () => BraceletConnectScreen()), 
    GetPage(name: '/bracelet-management', page: () => BraceletManagementScreen()),
    GetPage(name: '/card-verification', page: () => CardVerificationScreen(userId: '', cardNumber: '', expiryDate: '', cvv: '',)), // Ajout
  ];
}