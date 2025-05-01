import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class LanguageSettingsScreen extends StatefulWidget {
  @override
  _LanguageSettingsScreenState createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String selectedLanguage = 'English';
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadLanguageSetting();
  }

  Future<void> _loadLanguageSetting() async {
    String? value = await storage.read(key: 'language');
    setState(() {
      selectedLanguage = value ?? 'English';
    });
  }

  Future<void> _saveLanguageSetting(String language) async {
    await storage.write(key: 'language', value: language);
    setState(() {
      selectedLanguage = language;
    });
    // Update app locale (for demonstration; actual localization requires additional setup)
    if (language == 'English') {
      Get.updateLocale(const Locale('en', 'US'));
    } else if (language == 'French') {
      Get.updateLocale(const Locale('fr', 'FR'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Language Settings',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              trailing: Radio<String>(
                value: 'English',
                groupValue: selectedLanguage,
                onChanged: (value) => _saveLanguageSetting(value!),
                activeColor: Colors.white,
              ),
            ),
            ListTile(
              title: Text(
                'French',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              trailing: Radio<String>(
                value: 'French',
                groupValue: selectedLanguage,
                onChanged: (value) => _saveLanguageSetting(value!),
                activeColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}