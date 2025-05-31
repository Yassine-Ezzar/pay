import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
        toolbarHeight: kToolbarHeight + Styles.defaultPadding * 3.5,
        titleSpacing: Styles.defaultPadding,
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'The security of your data is a priority. This privacy policy explains the information we collect, how we use it, and how we protect it.\n\n'
                '📍 Data Collected\n'
                'We collect the following data:\n'
                '- Personal information (name, email address)\n'
                '- GPS data (for bracelet location tracking)\n'
                '- Payment history (related to RFID bracelet usage)\n\n'
                '🔐 Use of Data\n'
                'The data is used solely for:\n'
                '- Managing your transactions\n'
                '- Tracking your bracelet’s location\n'
                '- Improving our services and customer support\n\n'
                '🔒 Security\n'
                'We use advanced encryption to store your data and prevent unauthorized access. Our servers are hosted in certified data centers compliant with GDPR.\n\n'
                '📤 Data Sharing\n'
                'No data is sold. Some information may be shared with service providers (payment processing, maintenance), but always under strict confidentiality agreements.\n\n'
                '🗑️ Data Deletion\n'
                'You can request the deletion of your personal data at any time through your account settings.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightWhiteColor
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}