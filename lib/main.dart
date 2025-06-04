import 'package:app/styles/styles.dart';
import 'package:app/widgets/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/controllers/language_controller.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ThemeController themeController = Get.put(ThemeController());
  final LanguageController languageController = Get.put(LanguageController());

  themeController.onInit();
  await languageController.loadLanguagePreference();

  runApp(MyApp());
}

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemePreference(isDarkMode.value);
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final _storage = const FlutterSecureStorage();
    await _storage.write(key: 'isDarkMode', value: isDark.toString());
  }

  Future<bool> _loadThemePreference() async {
    final _storage = const FlutterSecureStorage();
    final String? isDark = await _storage.read(key: 'isDarkMode');
    return isDark == 'true';
  }

  @override
  void onInit() async {
    super.onInit();
    isDarkMode.value = await _loadThemePreference();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class MyApp extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<String> _getInitialRoute() async {
    String? userId = await _storage.read(key: 'userId');
    String? role = await _storage.read(key: 'role');
    String initialRoute;

    if (userId != null && role == 'admin') {
      initialRoute = '/admin-dashboard';
    } else if (userId != null && role == 'user') {
      initialRoute = '/splash';
    } else {
      initialRoute = '/splash';
    }

    return initialRoute;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInitialRoute(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final String initialRoute = snapshot.data!;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          getPages: AppPages.pages,
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Styles.scaffoldBackgroundColor,
            primaryColor: Styles.defaultBlueColor,
            colorScheme: ColorScheme.light(
              primary: Styles.defaultBlueColor,
              secondary: Styles.defaultYellowColor,
              background: Styles.scaffoldBackgroundColor,
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
            appBarTheme: AppBarTheme(
              backgroundColor: Styles.scaffoldBackgroundColor,
              foregroundColor: Styles.defaultYellowColor,
              elevation: 0,
            ),
            cardColor: Styles.scaffoldBackgroundColor,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Styles.darkScaffoldBackgroundColor,
            primaryColor: Styles.darkDefaultBlueColor,
            colorScheme: ColorScheme.dark(
              primary: Styles.darkDefaultBlueColor,
              secondary: Styles.darkDefaultYellowColor,
              background: Styles.darkScaffoldBackgroundColor,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Styles.darkDefaultLightWhiteColor),
              bodyMedium: TextStyle(color: Styles.darkDefaultGreyColor),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.darkDefaultBlueColor,
                foregroundColor: Styles.darkDefaultLightWhiteColor,
                padding: EdgeInsets.all(Styles.defaultPadding),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Styles.darkScaffoldBackgroundColor,
              foregroundColor: Styles.darkDefaultYellowColor,
              elevation: 0,
            ),
            cardColor: Styles.darkDefaultLightGreyColor.withOpacity(0.2),
            iconTheme: IconThemeData(color: Styles.darkDefaultYellowColor),
          ),
          themeMode: Get.find<ThemeController>().isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          translations: AppTranslations(),
          locale: Get.locale, 
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
          'add_card_guide_title': 'Add Card to Your Bracelet',
          'add_card_guide_description': 'Add credit, debit, or store cards to your bracelet to make secure payments.',
          'add_card_guide_info': 'Card-related information, location, and device settings may be sent to the card issuer to provide assessments to your card issuer or payment network to set up Apple Pay and prevent fraud.',
          'continue': 'Continue',
          'add_card_manual_title': 'Add Card Manually',
  'card_details': 'Card Details',
  'card_number': 'Card Number',
  'cardholder_name': 'Cardholder Name',
  'expiry_date': 'Expiry Date (MM/YY)',
  'cvv': 'CVV',
  'card_security_code': 'Card Security Code',
  'welcome_title': 'The best way\nTo store\nMoney',
  'welcome_description': 'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
  'get_started': 'Get started',
  'forgot_password': 'If you forget your Password !',
  'congratulations': 'Congratulations !',
  'account_ready': 'Your account is ready to use!',
  'get_started': 'GET STARTED',
  'checking_title': 'Checking!\nPlease wait ...',
  'checking_description': 'Your account is being checked before ready to use.',
  'go_to_home': 'Go to Home',
  'Face ID': 'Face ID',
  'Touch ID': 'Touch ID',
  'PIN': 'PIN',
  'Next Step': 'Next Step',
  'Register with Touch ID': 'Register with Touch ID',
  'Register with PIN': 'Register with PIN',
  'Already have an account? Log in': 'Already have an account? Log in',
  'Name': 'Name',
  'Pet’s Name': 'Pet’s Name',
  'Position the face in the correct angle to show the face places.' :'Position the face in the correct angle to show the face places.',
  'Place your finger on the sensor to register.': 'Place your finger on the sensor to register.',
    'Touch ID is not available on this device.': 'Touch ID is not available on this device.',
    'welcome_back': 'Welcome Back!',
  'face_id': 'Face ID',
  'touch_id': 'Touch ID',
  'pin': 'PIN',
  'position_face': 'Position the face in the correct angle to show the face places.',
  'place_finger': 'Place your finger on the sensor to login.',
  'login_with_face_id': 'Login with Face ID',
  'login_with_touch_id': 'Login with Touch ID',
  'login_with_pin': 'Login with PIN',
  'name': 'Name',
  'forgot_pin_reset': 'Forgot PIN? Reset it',
  'error': 'Error',
  'please_enter_name_pin': 'Please enter your name and a 4-digit PIN',
  'info': 'Info',
  'face_id_not_available': 'Face ID is not available on this device.',
  'touch_id_not_available': 'Touch ID is not available on this device.',
  'face_recognition_failed': 'Face recognition failed.',
  'fingerprint_recognition_failed': 'Fingerprint recognition failed.',
  'name_not_found': 'Name not found. Please log in with PIN first.',
  'your_face_recognized': 'Your face is being recognized...',
  'place_finger_sensor': 'Place your finger on the sensor...',
  'cancel': 'Cancel',
  'reset_pin': 'Reset PIN',
  'name': 'Name',
  'pet_name': 'Pet’s Name',
  'submit': 'SUBMIT',
  'error': 'Error',
  'please_fill_all_fields': 'Please fill all fields correctly',
  'your_cards': 'Your Cards',
  'no_cards_added': 'No cards added yet.\nTap the + button to add a card.',
  'transactions': 'Transactions',
  'refresh': 'REFRESH',
  'no_transactions_yet': 'No transactions yet.\nMake a payment with your bracelet to see it here.',
  'date': 'Date',
  'error': 'Error',
  'locate_bracelet': 'Locate Your Bracelet',
  'select_bracelet': 'Select a Bracelet',
  'bracelet_location': 'Bracelet Location:',
  'distance': 'Distance:',
  'no_bracelets_found': 'No bracelets found.\nPlease connect a bracelet first.',
  'unable_fetch_location': 'Unable to fetch your location.',
  'your_cards': 'Your Cards',
  'no_cards_added': 'No Cards Added',
  'add_card_to_start': 'Add a card to get started',
  'success': 'Success',
  'card_deleted': 'Card deleted',
  'error': 'Error',
  'user_not_logged_in': 'User not logged in',
  'choose_your_avatar': 'Choose Your Avatar',
  'pick_from_gallery': 'Pick from Gallery',
  'cancel': 'Cancel',
  'select': 'Select',
  'new_user': 'New User',
  'create_profile_info': 'Create Profile Information',
  'edit_profile_info': 'Edit Profile Information',
  'notifications': 'Notifications',
  'language': 'Language',
  'security': 'Security',
  'theme': 'Theme',
  'help_support': 'Help & Support',
  'contact_us': 'Contact Us',
  'privacy_policy': 'Privacy Policy',
  'logout': 'Logout',
  'success': 'Success',
  'avatar_updated': 'Avatar updated successfully',
  'image_updated': 'Image updated successfully',
  'connect_bracelet': 'Connect Your Bracelet',
  'how_to_connect': 'How to Connect',
  'step_1': 'Step 1: Ensure Bluetooth is enabled',
  'step_2': 'Step 2: Scan for your bracelet',
  'step_3': 'Step 3: Select and connect',
  'search_bracelets': 'Search for Bracelets',
  'scanning': 'Scanning...',
  'select_bracelet': 'Select a Bracelet',
  'unknown_device': 'Unknown Device',
  'connect': 'Connect',
  'connecting': 'Connecting...',
  'skip_for_now': 'Skip for now',
  'error': 'Error',
  'bluetooth_permissions_required': 'Bluetooth permissions are required to connect to your bracelet.',
  'failed_scan_devices': 'Failed to scan for devices: ',
  'please_select_bracelet': 'Please select a bracelet',
  'success': 'Success',
  'bracelet_connected': 'Bracelet connected successfully',
        },
        'fr_FR': {
          'language': 'Langue',
          'title': 'Profil',
          'notifications': 'Notifications',
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
          'add_card_guide_title': 'Ajouter une carte à votre bracelet',
          'add_card_guide_description': 'Ajoutez des cartes de crédit, de débit ou de magasin à votre bracelet pour effectuer des paiements sécurisés.',
          'add_card_guide_info': 'Les informations liées à la carte, la localisation et les paramètres de l’appareil peuvent être envoyées à l’émetteur de la carte pour fournir des évaluations à votre émetteur de carte ou réseau de paiement afin de configurer Apple Pay et prévenir la fraude.',
          'continue': 'Continuer',
          'add_card_manual_title': 'Ajouter une carte manuellement',
  'card_details': 'Détails de la carte',
  'card_number': 'Numéro de carte',
  'cardholder_name': 'Nom du titulaire de la carte',
  'expiry_date': 'Date d’expiration (MM/AA)',
  'cvv': 'CVV',
  'card_security_code': 'Code de sécurité de la carte',
  'welcome_title': 'La meilleure façon\nde stocker\nvotre argent',
  'welcome_description': 'Le texte de Lorem ipsum est simplement un texte fictif utilisé dans l\'imprimerie et la composition. Il est devenu la norme dans l\'industrie depuis les années 1500, lorsqu\'un imprimeur inconnu a pris une galée de caractères et l\'a brouillée pour créer un livre d\'épreuves.',
  'get_started': 'Commencer',
  'forgot_password': 'Si vous oubliez votre mot de passe !',
  'Congratulations': 'Félicitations !',
  'Account Ready': 'Votre compte est prêt à être utilisé !',
  'Get Started': 'COMMENCER',
  'checking_title': 'Vérification !\nVeuillez patienter ...',
  'checking_description': 'Votre compte est en cours de vérification avant d’être prêt à l’utilisation.',
  'go_to_home': 'Aller à l’accueil',
  'Face ID': 'Face ID',
  'Touch ID': 'Touch ID',
  'PIN': 'PIN',
  'Next Step': 'Étape suivante',
  'Register with Touch ID': 'S’inscrire avec Touch ID',
  'Register with PIN': 'S’inscrire avec un PIN',
  'Already have an account? Log in': 'Vous avez déjà un compte ? Connectez-vous',
  'Name': 'Nom',
  'Pet’s Name': 'Nom de l’animal',
  'Position the face in the correct angle to show the face places.': 'Positionnez le visage dans l\'angle correct pour montrer les emplacements du visage.',
   'Place your finger on the sensor to register.': 'Placez votre doigt sur le capteur pour vous enregistrer.',
     'Touch ID is not available on this device.': 'Touch ID n\'est pas disponible sur cet appareil.',
 'welcome_back': 'Bon retour !',
  'face_id': 'Face ID',
  'touch_id': 'Touch ID',
  'pin': 'PIN',
  'position_face': 'Positionnez votre visage à l’angle correct pour montrer les zones du visage.',
  'place_finger': 'Placez votre doigt sur le capteur pour vous connecter.',
  'login_with_face_id': 'Se connecter avec Face ID',
  'login_with_touch_id': 'Se connecter avec Touch ID',
  'login_with_pin': 'Se connecter avec PIN',
  'name': 'Nom',
  'forgot_pin_reset': 'PIN oublié ? Réinitialisez-le',
  'error': 'Erreur',
  'please_enter_name_pin': 'Veuillez entrer votre nom et un PIN à 4 chiffres',
  'info': 'Info',
  'face_id_not_available': 'Face ID n’est pas disponible sur cet appareil.',
  'touch_id_not_available': 'Touch ID n’est pas disponible sur cet appareil.',
  'face_recognition_failed': 'La reconnaissance faciale a échoué.',
  'fingerprint_recognition_failed': 'La reconnaissance d’empreintes digitales a échoué.',
  'name_not_found': 'Nom non trouvé. Veuillez d’abord vous connecter avec un PIN.',
  'your_face_recognized': 'Votre visage est en cours de reconnaissance...',
  'place_finger_sensor': 'Placez votre doigt sur le capteur...',
  'cancel': 'Annuler',
  'reset_pin': 'Réinitialiser le PIN',
  'name': 'Nom',
  'pet_name': 'Nom de l’animal de compagnie',
  'submit': 'SOUMETTRE',
  'error': 'Erreur',
  'please_fill_all_fields': 'Veuillez remplir tous les champs correctement',
  'your_cards': 'Vos cartes',
  'no_cards_added': 'Aucune carte ajoutée pour l’instant.\nAppuyez sur le bouton + pour ajouter une carte.',
  'transactions': 'Transactions',
  'refresh': 'RAFRAÎCHIR',
  'no_transactions_yet': 'Aucune transaction pour l’instant.\nEffectuez un paiement avec votre bracelet pour le voir ici.',
  'date': 'Date',
  'error': 'Erreur',
  'locate_bracelet': 'Localiser votre bracelet',
  'select_bracelet': 'Sélectionner un bracelet',
  'bracelet_location': 'Emplacement du bracelet :',
  'distance': 'Distance :',
  'no_bracelets_found': 'Aucun bracelet trouvé.\nVeuillez connecter un bracelet d’abord.',
  'unable_fetch_location': 'Impossible de récupérer votre emplacement.',
  'your_cards': 'Vos Cartes',
  'no_cards_added': 'Aucune Carte Ajoutée',
  'add_card_to_start': 'Ajoutez une carte pour commencer',
  'success': 'Succès',
  'card_deleted': 'Carte supprimée',
  'error': 'Erreur',
  'user_not_logged_in': 'Utilisateur non connecté',
  'choose_your_avatar': 'Choisissez votre avatar',
  'pick_from_gallery': 'Choisir dans la galerie',
  'cancel': 'Annuler',
  'select': 'Sélectionner',
  'new_user': 'Nouvel utilisateur',
  'create_profile_info': 'Créer les informations du profil',
  'edit_profile_info': 'Modifier les informations du profil',
  'notifications': 'Notifications',
  'language': 'Langue',
  'security': 'Sécurité',
  'theme': 'Thème',
  'help_support': 'Aide et Support',
  'contact_us': 'Nous Contacter',
  'privacy_policy': 'Politique de Confidentialité',
  'logout': 'Déconnexion',
  'success': 'Succès',
  'avatar_updated': 'Avatar mis à jour avec succès',
  'image_updated': 'Image mise à jour avec succès',
  'connect_bracelet': 'Connectez votre bracelet',
  'how_to_connect': 'Comment se connecter',
  'step_1': 'Étape 1 : Assurez-vous que Bluetooth est activé',
  'step_2': 'Étape 2 : Recherchez votre bracelet',
  'step_3': 'Étape 3 : Sélectionnez et connectez',
  'search_bracelets': 'Rechercher des bracelets',
  'scanning': 'Recherche en cours...',
  'select_bracelet': 'Sélectionnez un bracelet',
  'unknown_device': 'Appareil inconnu',
  'connect': 'Connecter',
  'connecting': 'Connexion en cours...',
  'skip_for_now': 'Passer pour l’instant',
  'error': 'Erreur',
  'bluetooth_permissions_required': 'Les autorisations Bluetooth sont nécessaires pour connecter votre bracelet.',
  'failed_scan_devices': 'Échec de la recherche des appareils : ',
  'please_select_bracelet': 'Veuillez sélectionner un bracelet',
  'success': 'Succès',
  'bracelet_connected': 'Bracelet connecté avec succès',
        },
      };
}