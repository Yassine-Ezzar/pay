import 'package:flutter/material.dart';

class Styles {
  // Thème dynamique : couleurs par défaut (light mode)
  static Color scaffoldBackgroundColor = const Color.fromARGB(255, 255, 255, 255);
  static Color defaultRedColor = const Color.fromRGBO(0, 102, 255, 1); // Bleu clair
  static Color defaultYellowColor = const Color(0xFF063b87); // Bleu foncé
  static Color defaultBlueColor = const Color(0xFF0066FF); // Bleu vif
  static Color defaultGreyColor = const Color(0xFF063b87); // Bleu foncé (réutilisé)
  static Color defaultLightGreyColor = const Color(0xFFa1d0ff); // Bleu clair
  static Color defaultLightWhiteColor = const Color(0xFFa1d0ff); // Bleu clair

  // Thème sombre : nouvelles couleurs
  static Color darkScaffoldBackgroundColor = const Color(0xFF1E1E1E); // Gris très foncé
  static Color darkDefaultRedColor = const Color.fromRGBO(0, 102, 255, 0.8); // Bleu clair atténué
  static Color darkDefaultYellowColor = const Color(0xFF87CEEB); // Bleu ciel (alternative lumineuse)
  static Color darkDefaultBlueColor = const Color(0xFF42A5F5); // Bleu plus doux et visible
  static Color darkDefaultGreyColor = const Color(0xFFB0BEC5); // Gris clair pour texte ou éléments secondaires
  static Color darkDefaultLightGreyColor = const Color(0xFF78909C); // Gris moyen
  static Color darkDefaultLightWhiteColor = const Color(0xFFE0E0E0); // Gris très clair pour texte principal

  static double defaultPadding = 18.0;

  static BorderRadius defaultBorderRadius = BorderRadius.circular(20);

  static ScrollbarThemeData scrollbarTheme = const ScrollbarThemeData().copyWith(
    thumbColor: WidgetStateProperty.all(defaultYellowColor),
    trackColor: WidgetStateProperty.all(const Color(0xFFBBBBBB)),
    trackVisibility: const WidgetStatePropertyAll(true),
    thumbVisibility: WidgetStateProperty.all(false),
    interactive: true,
    thickness: WidgetStateProperty.all(10.0),
    radius: const Radius.circular(20),
  );

  static var cardBackgroundColor;

  static var darkDefaultLightBlueColor; 
}