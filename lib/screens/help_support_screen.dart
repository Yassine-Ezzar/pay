import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';
import 'package:get/get.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Styles.darkDefaultLightWhiteColor
                : Styles.defaultBlueColor,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Styles.darkDefaultLightWhiteColor
                : Styles.defaultBlueColor,
          ),
          onPressed: () => Get.back(),
        ),
        toolbarHeight: kToolbarHeight + Styles.defaultPadding * 4,
        titleSpacing: Styles.defaultPadding,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          Styles.defaultPadding / 2, // Left
          Styles.defaultPadding * 1, // Top (to push content below notch)
          Styles.defaultPadding / 2, // Right
          Styles.defaultPadding / 2, // Bottom
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We’re Here to Help',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Have a question or facing an issue with your bracelet or app? We’re here to assist you every step of the way.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.build,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor
                        : Styles.defaultBlueColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Technical Issues',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Experiencing a bug? Is your bracelet not connecting properly, or are you having trouble with a payment? Check our FAQ for quick solutions or contact our technical support.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.book,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor
                        : Styles.defaultBlueColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Usage Guide',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Access our detailed tutorials to learn how to activate your bracelet, add a payment method, or use geolocation to find your lost bracelet.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor
                        : Styles.defaultBlueColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Personalized Assistance',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'If your issue persists or you have a specific question, our team will respond as soon as possible via email or through the in-app chat. Our support is available 24/7 to provide fast and effective assistance.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Styles.darkDefaultBlueColor
              : Styles.defaultBlueColor,
        ),
      ),
      iconColor: Theme.of(context).brightness == Brightness.dark
          ? Styles.darkDefaultBlueColor
          : Styles.defaultBlueColor,
      collapsedIconColor: Theme.of(context).brightness == Brightness.dark
          ? Styles.darkDefaultBlueColor
          : Styles.defaultBlueColor,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}