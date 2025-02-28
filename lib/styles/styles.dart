import 'package:flutter/material.dart';

class Styles {
  static Color scaffoldBackgroundColor = const Color(0xFF7098da);
  static Color defaultRedColor = const Color(0xFF6eb6ff);
  static Color defaultYellowColor = const Color(0xFFFFFFFF);
  static Color defaultBlueColor = const Color(0xFF98b5e4);
  static Color defaultGreyColor = const Color(0xFF477bd0);
  static Color defaultLightGreyColor = const Color(0xFFa1d0ff);
  static Color defaultLightWhiteColor = const Color(0xFFa1d0ff);

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
}