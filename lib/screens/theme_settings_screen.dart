import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class ThemeSettingsScreen extends StatefulWidget {
  @override
  _ThemeSettingsScreenState createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool isDarkMode = true;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    String? value = await storage.read(key: 'isDarkMode');
    setState(() {
      isDarkMode = value == null || value == 'true';
    });
  }

  Future<void> _saveThemeSetting(bool value) async {
    await storage.write(key: 'isDarkMode', value: value.toString());
    setState(() {
      isDarkMode = value;
    });
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'theme'.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'dark_mode'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
              value: isDarkMode,
              onChanged: (value) => _saveThemeSetting(value),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}