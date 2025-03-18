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

  Future<String> _getInitialRoute() async {
    String? userId = await _storage.read(key: 'userId');
    return userId != null ? '/add-card' : '/splash'; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: snapshot.data!,
          getPages: AppPages.pages,
          theme: ThemeData(
            fontFamily: 'Rubik',
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
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.all(Styles.defaultPadding),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
            ),
            scrollbarTheme: Styles.scrollbarTheme,
          ),
        );
      },
    );
  }
}