import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class AddCardGuideScreen extends StatelessWidget {
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
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black12
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightGreyColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                          Theme.of(context).brightness == Brightness.dark
                              ? Styles.darkDefaultLightGreyColor.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip
                        Container(
                          width: 50,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightGreyColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Styles.darkDefaultGreyColor
                                  : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Styles.darkDefaultYellowColor
                                    : Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '**** **** **** 8712',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightWhiteColor
                                : Colors.black54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CARDHOLDER NAME',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Styles.darkDefaultLightWhiteColor
                                    : Colors.black54,
                              ),
                            ),
                            Text(
                              '12/25',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Styles.darkDefaultLightWhiteColor
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // NFC icon
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Icon(
                      Icons.nfc,
                      size: 30,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Styles.darkDefaultLightWhiteColor.withOpacity(0.7)
                          : Colors.black54.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Title
            Text(
              'Add Card to Your Bracelet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Add credit, debit, or store cards to your bracelet to make secure payments.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultGreyColor
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Card-related information, location, and device settings may be sent to the card issuer to provide assessments to your card issuer or payment network to set up Apple Pay and prevent fraud.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Styles.darkDefaultGreyColor
                          : Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 363,
              height: 68,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/add-card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultBlueColor
                      : Styles.defaultBlueColor,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightWhiteColor
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}