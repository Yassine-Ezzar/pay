import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Montserrat',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Last updated: April 03, 2025\n\n'
                'We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and share your data when you use our app.\n\n'
                '1. Information We Collect\n'
                'We may collect the following types of information:\n'
                '- Personal Information: Name, email, phone number, etc.\n'
                '- Payment Information: Card details (encrypted).\n'
                '- Location Data: To locate your bracelet if lost.\n\n'
                '2. How We Use Your Information\n'
                'We use your information to:\n'
                '- Provide and improve our services.\n'
                '- Process payments securely.\n'
                '- Locate your bracelet on a map.\n\n'
                '3. Sharing Your Information\n'
                'We do not share your personal information with third parties except as required by law or to provide our services (e.g., payment processing).\n\n'
                '4. Security\n'
                'We implement industry-standard security measures to protect your data.\n\n'
                '5. Contact Us\n'
                'If you have any questions about this Privacy Policy, please contact us at support@example.com.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}