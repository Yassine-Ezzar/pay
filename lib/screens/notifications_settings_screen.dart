import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  @override
  _NotificationsSettingsScreenState createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool notificationsEnabled = true;
  final storage = const FlutterSecureStorage();
  bool _hasShownInfo = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationsSetting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownInfo) {
        _showInfoDialog();
      }
    });
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

  void _showInfoDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'notification_settings'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9) ?? Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                        offset: const Offset(0, 0),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'notification_info'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        setState(() {
                          _hasShownInfo = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        elevation: 5,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      child: Text(
                       'proceed'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Styles.defaultPadding,
              vertical: Styles.defaultPadding * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                        size: 28,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Icon(
                  Icons.notifications,
                  size: 80,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(height: 20),
                Text(
                  'notification_settings'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(Styles.defaultPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black12
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                         'notification_preferences'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: Text(
                            'enable_notifications'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          subtitle: Text(
                           'receive_alerts'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          value: notificationsEnabled,
                          onChanged: (value) => _saveNotificationsSetting(value),
                          activeColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Theme.of(context).brightness == Brightness.dark
                              ? Styles.darkDefaultGreyColor
                              : Colors.grey,
                          inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                              ? Styles.darkDefaultLightGreyColor
                              : Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                      ],
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
}