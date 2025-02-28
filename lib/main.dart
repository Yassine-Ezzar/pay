import 'package:app/styles/styles.dart';
import 'package:app/widgets/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: AppPages.pages,
      theme: ThemeData(
        fontFamily: 'Rubik', // Police globale
        scaffoldBackgroundColor: Styles.scaffoldBackgroundColor,
        primaryColor: Styles.defaultBlueColor,
        colorScheme: ColorScheme.light(
          primary: Styles.defaultBlueColor,
          secondary: Styles.defaultYellowColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Styles.defaultYellowColor),
          bodyMedium: TextStyle(color: Styles.defaultLightWhiteColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Styles.defaultGreyColor, // Boutons
            foregroundColor: Styles.defaultYellowColor,
            padding: EdgeInsets.all(Styles.defaultPadding),
            shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
          ),
        ),
        scrollbarTheme: Styles.scrollbarTheme,
      ),
    );
  }
}