import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';
import 'package:app/controllers/language_controller.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final LanguageController languageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'language'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      languageController.isFrench.value ? 'french'.tr : 'english'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    )),
                Obx(() => Switch(
                      value: languageController.isFrench.value,
                      onChanged: (value) {
                        languageController.toggleLanguage();
                      },
                      activeColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                      activeTrackColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({})?.withOpacity(0.5),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}