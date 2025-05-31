import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/styles/styles.dart';
import 'package:app/widgets/translated_text.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<void> _changeLanguage(BuildContext context, String locale) async {
    print('Changing language to: $locale');
    Get.updateLocale(Locale(locale.split('_')[0], locale.split('_')[1]));
    print('Current locale after update: ${Get.locale}');
    await _storage.write(key: 'locale', value: locale);
    print('Locale saved to storage: $locale');
    Get.snackbar(
      'language'.tr,
      locale == 'en_US' ? 'english'.tr : 'french'.tr,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Styles.darkDefaultBlueColor
          : Styles.defaultBlueColor,
      colorText: Theme.of(context).brightness == Brightness.dark
          ? Styles.darkDefaultLightWhiteColor
          : Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building LanguageSelectionScreen with locale: ${Get.locale}');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Styles.darkDefaultBlueColor : Styles.defaultBlueColor;
    final accentColor = isDarkMode ? Styles.darkDefaultYellowColor : Styles.defaultYellowColor;
    final textColor = isDarkMode ? Styles.darkDefaultLightWhiteColor : Colors.black87;
    final secondaryTextColor = isDarkMode ? Styles.darkDefaultGreyColor : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            children: [
              // Back button with modern cross icon
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const Spacer(),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              // Centered content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'language'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 1.5,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(duration: 600.ms, begin: 0.3),
                        const SizedBox(height: 40),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: Styles.defaultBorderRadius,
                          ),
                          color: isDarkMode
                              ? Styles.darkDefaultLightGreyColor.withOpacity(0.2)
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLanguageOption(
                                  context,
                                  'en_US',
                                  'english'.tr,
                                  '🇬🇧', // Icône drapeau pour l'anglais
                                  isDarkMode,
                                  primaryColor,
                                  accentColor,
                                  textColor,
                                ),
                                const SizedBox(height: 16),
                                _buildLanguageOption(
                                  context,
                                  'fr_FR',
                                  'french'.tr,
                                  '🇫🇷', // Icône drapeau pour le français
                                  isDarkMode,
                                  primaryColor,
                                  accentColor,
                                  textColor,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scaleXY(begin: 0.95),
                      ],
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

  Widget _buildLanguageOption(
    BuildContext context,
    String locale,
    String title,
    String flag,
    bool isDarkMode,
    Color primaryColor,
    Color accentColor,
    Color textColor,
  ) {
    final isSelected = Get.locale?.languageCode == locale.split('_')[0];
    return GestureDetector(
      onTap: () => _changeLanguage(context, locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : isDarkMode
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                TranslatedText(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: accentColor,
                size: 24,
              ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}