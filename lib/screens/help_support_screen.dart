import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000080),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
          onPressed: () => Navigator.pop(context),
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
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We’re Here to Help',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Have a question or facing an issue with your bracelet or app? We’re here to assist you every step of the way.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.build, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Technical Issues',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Experiencing a bug? Is your bracelet not connecting properly, or are you having trouble with a payment? Check our FAQ for quick solutions or contact our technical support.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.book, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Usage Guide',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Access our detailed tutorials to learn how to activate your bracelet, add a payment method, or use geolocation to find your lost bracelet.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              // Personalized Assistance Section
              Row(
                children: [
                  Icon(Icons.support_agent, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Personalized Assistance',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'If your issue persists or you have a specific question, our team will respond as soon as possible via email or through the in-app chat. Our support is available 24/7 to provide fast and effective assistance.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Color(0xFF000080),
        ),
      ),
      iconColor: const Color(0xFF000080),
      collapsedIconColor: const Color(0xFF000080),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}