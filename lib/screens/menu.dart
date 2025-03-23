import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        color: Styles.defaultYellowColor,
        size: 28,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Styles.scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: EdgeInsets.all(Styles.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.credit_card, color: Styles.defaultYellowColor), // Icône pour "Cards"
                  title: Text(
                    'Cards',
                    style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                  ),
                  onTap: () {
                    Get.back(); // Ferme le menu
                    Get.toNamed('/card-list'); // Redirige vers CardListScreen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.watch, color: Styles.defaultYellowColor),
                  title: Text(
                    'Bracelet',
                    style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                  ),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/bracelet-management');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Styles.defaultRedColor),
                  title: Text(
                    'Logout',
                    style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultRedColor),
                  ),
                  onTap: () async {
                    await ApiService.storage.deleteAll();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}