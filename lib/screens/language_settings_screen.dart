import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/styles/styles.dart';
import 'package:app/widgets/translated_text.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<void> _changeLanguage(String locale) async {
    print('Changing language to: $locale');
    Get.updateLocale(Locale(locale.split('_')[0], locale.split('_')[1]));
    print('Current locale after update: ${Get.locale}');
    await _storage.write(key: 'locale', value: locale);
    print('Locale saved to storage: $locale');
    Get.snackbar(
      'language'.tr,
      locale == 'en_US' ? 'english'.tr : 'french'.tr,
      backgroundColor: Styles.defaultBlueColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building LanguageSelectionScreen with locale: ${Get.locale}');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Styles.defaultBlueColor;
    final accentColor = Styles.defaultYellowColor;
    final backgroundColor = isDarkMode ? Styles.scaffoldBackgroundColor : Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [primaryColor.withOpacity(0.8), accentColor.withOpacity(0.6)]
                : [primaryColor.withOpacity(0.3), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Styles.defaultPadding),
            child: Column(
              children: [
                // Back button with cross icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close, // Cross icon
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Get.back(), // Navigate back
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
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : primaryColor,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: primaryColor.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 800.ms).slideY(duration: 800.ms, begin: 0.5),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Styles.defaultLightGreyColor.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                _buildLanguageOption(
                                  context,
                                  'en_US',
                                  'english'.tr,
                                  isDarkMode,
                                  primaryColor,
                                  accentColor,
                                ),
                                const SizedBox(height: 20),
                                _buildLanguageOption(
                                  context,
                                  'fr_FR',
                                  'french'.tr,
                                  isDarkMode,
                                  primaryColor,
                                  accentColor,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scaleXY(begin: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String locale,
    String title,
    bool isDarkMode,
    Color primaryColor,
    Color accentColor,
  ) {
    final isSelected = Get.locale?.languageCode == locale.split('_')[0];
    return GestureDetector(
      onTap: () => _changeLanguage(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : isDarkMode
                  ? Styles.defaultLightGreyColor.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TranslatedText(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: isDarkMode ? accentColor : primaryColor,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}