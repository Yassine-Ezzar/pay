import 'package:app/styles/styles.dart';
import 'package:app/widgets/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> _getInitialData() async {
    String? userId = await _storage.read(key: 'userId');
    String? role = await _storage.read(key: 'role');
    String? isDarkMode = await _storage.read(key: 'isDarkMode');
    String initialRoute;

    if (userId != null && role == 'admin') {
      initialRoute = '/admin-dashboard';
    } else if (userId != null && role == 'user') {
      initialRoute = '/splash';
    } else {
      initialRoute = '/splash';
    }

    bool darkMode = isDarkMode == null || isDarkMode == 'true';

    return [initialRoute, darkMode];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInitialData(),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final String initialRoute = snapshot.data![0] as String;
        final bool isDarkMode = snapshot.data![1] as bool;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          getPages: AppPages.pages,
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Styles.defaultBlueColor,
            colorScheme: ColorScheme.light(
              primary: Styles.defaultBlueColor,
              secondary: Colors.white,
              background: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(Styles.defaultPadding),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Styles.scaffoldBackgroundColor,
            primaryColor: Styles.defaultBlueColor,
            colorScheme: ColorScheme.dark(
              primary: Styles.defaultBlueColor,
              secondary: Colors.white,
              background: Styles.scaffoldBackgroundColor,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Styles.defaultYellowColor),
              bodyMedium: TextStyle(color: Styles.defaultLightWhiteColor),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Styles.defaultBlueColor,
                padding: EdgeInsets.all(Styles.defaultPadding),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Styles.scaffoldBackgroundColor,
              foregroundColor: Styles.defaultYellowColor,
              elevation: 0,
            ),
            cardColor: Styles.defaultLightGreyColor.withOpacity(0.2),
            iconTheme: IconThemeData(color: Styles.defaultYellowColor),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'title': 'Profile',
          'notifications': 'Notifications',
          'language': 'Language',
          'theme': 'Theme',
          'help_support': 'Help & Support',
          'contact_us': 'Contact Us',
          'privacy_policy': 'Privacy Policy',
          'logout': 'Logout',
          'enable_notifications': 'Enable Notifications',
          'english': 'English',
          'french': 'French',
          'dark_mode': 'Dark Mode',
          'faq': 'Frequently Asked Questions',
          'how_connect_bracelet': 'How do I connect my bracelet?',
          'how_connect_bracelet_answer': 'Go to the Bracelet section in the menu and follow the instructions to connect via Bluetooth.',
          'how_add_card': 'How do I add a card?',
          'how_add_card_answer': 'From the Home screen, tap the + button to add a new card.',
          'what_if_lose_bracelet': 'What if I lose my bracelet?',
          'what_if_lose_bracelet_answer': 'Use the Location feature to find your bracelet on a map.',
          'need_more_help': 'Need More Help?',
          'visit_website': 'Visit our website at www.example.com or contact us at support@example.com.',
          'get_in_touch': 'Get in Touch',
          'email': 'Email',
          'email_value': 'support@example.com',
          'phone': 'Phone',
          'phone_value': '+1 234 567 8900',
          'address': 'Address',
          'address_value': '123 Main Street, City, Country',
          'follow_us': 'Follow Us',
          'privacy_policy_title': 'Privacy Policy',
          'privacy_policy_content': 'Last updated: April 03, 2025\n\n'
              'We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and share your data when you use our app.\n\n'
              '1. Information We Collect\n'
              'We may collect the following types of information:\n'
              '- Personal Information: Name, email, phone number, etc.\n'
              '- Payment Information: Card details (encrypted).\n'
              '- Location Data: To locate your bracelet if lost.\n\n'
              '2. How We Use Your Information\n'
              'We use your information to:\n'
              '- Provide and improve our services.\n'
              '- Process payments securely.\n'
              '- Locate your bracelet on a map.\n\n'
              '3. Sharing Your Information\n'
              'We do not share your personal information with third parties except as required by law or to provide our services (e.g., payment processing).\n\n'
              '4. Security\n'
              'We implement industry-standard security measures to protect your data.\n\n'
              '5. Contact Us\n'
              'If you have any questions about this Privacy Policy, please contact us at support@example.com.',
        },
        'fr_FR': {
          'title': 'Profil',
          'notifications': 'Notifications',
          'language': 'Langue',
          'theme': 'Thème',
          'help_support': 'Aide et Support',
          'contact_us': 'Nous Contacter',
          'privacy_policy': 'Politique de Confidentialité',
          'logout': 'Déconnexion',
          'enable_notifications': 'Activer les Notifications',
          'english': 'Anglais',
          'french': 'Français',
          'dark_mode': 'Mode Sombre',
          'faq': 'Questions Fréquemment Posées',
          'how_connect_bracelet': 'Comment connecter mon bracelet ?',
          'how_connect_bracelet_answer': 'Allez dans la section Bracelet du menu et suivez les instructions pour vous connecter via Bluetooth.',
          'how_add_card': 'Comment ajouter une carte ?',
          'how_add_card_answer': 'Depuis l’écran d’accueil, appuyez sur le bouton + pour ajouter une nouvelle carte.',
          'what_if_lose_bracelet': 'Que faire si je perds mon bracelet ?',
          'what_if_lose_bracelet_answer': 'Utilisez la fonction de localisation pour trouver votre bracelet sur une carte.',
          'need_more_help': 'Besoin de plus d’aide ?',
          'visit_website': 'Visitez notre site web à www.example.com ou contactez-nous à support@example.com.',
          'get_in_touch': 'Nous Contacter',
          'email': 'Email',
          'email_value': 'support@example.com',
          'phone': 'Téléphone',
          'phone_value': '+1 234 567 8900',
          'address': 'Adresse',
          'address_value': '123 Rue Principale, Ville, Pays',
          'follow_us': 'Suivez-nous',
          'privacy_policy_title': 'Politique de Confidentialité',
          'privacy_policy_content': 'Dernière mise à jour : 3 avril 2025\n\n'
              'Nous valorisons votre vie privée et nous engageons à protéger vos informations personnelles. Cette politique de confidentialité explique comment nous collectons, utilisons et partageons vos données lorsque vous utilisez notre application.\n\n'
              '1. Informations que nous collectons\n'
              'Nous pouvons collecter les types d’informations suivants :\n'
              '- Informations personnelles : Nom, email, numéro de téléphone, etc.\n'
              '- Informations de paiement : Détails de la carte (cryptés).\n'
              '- Données de localisation : Pour localiser votre bracelet en cas de perte.\n\n'
              '2. Comment nous utilisons vos informations\n'
              'Nous utilisons vos informations pour :\n'
              '- Fournir et améliorer nos services.\n'
              '- Traiter les paiements de manière sécurisée.\n'
              '- Localiser votre bracelet sur une carte.\n\n'
              '3. Partage de vos informations\n'
              'Nous ne partageons pas vos informations personnelles avec des tiers, sauf si la loi l’exige ou pour fournir nos services (par exemple, traitement des paiements).\n\n'
              '4. Sécurité\n'
              'Nous mettons en œuvre des mesures de sécurité conformes aux normes de l’industrie pour protéger vos données.\n\n'
              '5. Contactez-nous\n'
              'Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter à support@example.com.',
        },
      };
}