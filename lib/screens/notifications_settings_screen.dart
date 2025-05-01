import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/styles/styles.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  @override
  _NotificationsSettingsScreenState createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool notificationsEnabled = true;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadNotificationsSetting();
  }

  Future<void> _loadNotificationsSetting() async {
    String? value = await storage.read(key: 'notificationsEnabled');
    setState(() {
      notificationsEnabled = value == 'true';
    });
  }

  Future<void> _saveNotificationsSetting(bool value) async {
    await storage.write(key: 'notificationsEnabled', value: value.toString());
    setState(() {
      notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Notifications Settings',
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
            SwitchListTile(
              title: const Text(
                'Enable Notifications',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              value: notificationsEnabled,
              onChanged: (value) => _saveNotificationsSetting(value),
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}