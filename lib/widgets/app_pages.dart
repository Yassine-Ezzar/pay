import 'package:app/screens/AdminDashboardScreen.dart';
import 'package:app/screens/add_card_guide_screen.dart';
import 'package:app/screens/add_card_manual_screen.dart';
import 'package:app/screens/add_card_screen.dart';
import 'package:app/screens/bracelet_connect_screen.dart';
import 'package:app/screens/bracelet_management_screen.dart';
import 'package:app/screens/card_list_screen.dart';
import 'package:app/screens/card_verification_screen.dart';
import 'package:app/screens/checking_screen.dart';
import 'package:app/screens/contact_us_screen.dart';
import 'package:app/screens/edit_profile_screen.dart';
import 'package:app/screens/help_support_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/language_settings_screen.dart';
import 'package:app/screens/location_screen.dart';
import 'package:app/screens/notifications_screen.dart';
import 'package:app/screens/notifications_settings_screen.dart';
import 'package:app/screens/passwordsuccessfully.dart';
import 'package:app/screens/privacy_policy_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/success_screen.dart';
import 'package:app/screens/theme_settings_screen.dart';
import 'package:app/screens/welcome_page.dart';
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
    GetPage(name: '/add-card-guide', page: () => AddCardGuideScreen()),
    GetPage(name: '/add-card', page: () => AddCardScreen()),
    GetPage(name: '/card-list', page: () => CardListScreen()),
    GetPage(name: '/bracelet-connect', page: () => BraceletConnectScreen()), 
    GetPage(name: '/bracelet-management', page: () => BraceletManagementScreen()),
GetPage(name: '/add-card-manual', page: () => AddCardManualScreen()),
    GetPage(name: '/card-verification', page: () => CardVerificationScreen()),   
     GetPage(name: '/location', page: () => LocationScreen()), 
    GetPage(name: '/notifications', page: () => NotificationsScreen()), 
    GetPage(name: '/profile', page: () => ProfileScreen()), 
    GetPage(name: '/edit-profile', page: () => EditProfileScreen()),
    GetPage(name: '/language-settings', page: () => LanguageSettingsScreen()), 
    GetPage(name: '/theme-settings', page: () => ThemeSettingsScreen()), 
    GetPage(name: '/help-support', page: () => HelpSupportScreen()), 
    GetPage(name: '/contact-us', page: () => ContactUsScreen()), 
    GetPage(name: '/privacy-policy', page: () => PrivacyPolicyScreen()),
    GetPage(name: '/notifications-settings', page: () => NotificationsSettingsScreen()),
    GetPage(name: '/admin-dashboard', page: () => AdminDashboardScreen()), 
    GetPage(name: '/welcome', page: () => WelcomePage()),
    GetPage(name: '/checking', page: () => CheckingScreen()),
    GetPage(name: '/password-changed', page: () => PasswordChangedSuccessfullyScreen()),
    

  ];
}