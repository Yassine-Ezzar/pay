import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageController extends GetxController {
  var isFrench = false.obs; 
  final _storage = const FlutterSecureStorage();

  void toggleLanguage() {
    isFrench.value = !isFrench.value;
    final locale = isFrench.value ? const Locale('fr', 'FR') : const Locale('en', 'US');
    Get.updateLocale(locale);
    _saveLanguagePreference(locale);
  }

  Future<void> _saveLanguagePreference(Locale locale) async {
    await _storage.write(key: 'locale', value: locale.toString());
  }

  Future<void> loadLanguagePreference() async {
    final String? locale = await _storage.read(key: 'locale');
    if (locale != null) {
      isFrench.value = locale == 'fr_FR';
      Get.updateLocale(Locale(locale == 'fr_FR' ? 'fr' : 'en', locale == 'fr_FR' ? 'FR' : 'US'));
    } else {
      isFrench.value = false;
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}