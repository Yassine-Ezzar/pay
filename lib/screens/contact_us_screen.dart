import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: 'Poppins',
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
        toolbarHeight: kToolbarHeight + Styles.defaultPadding * 3.5, 
        titleSpacing: Styles.defaultPadding, 
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Our Team Is Here for You',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'to address your inquiries, suggestions, or bug reports.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              _buildContactItem(
                icon: Icons.email,
                title: 'Email',
                subtitle: '',
              ),
              _buildContactItem(
                icon: Icons.phone,
                title: 'Phone',
                subtitle: '',
              ),
              _buildContactItem(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available in the app Monday to Friday, 9 AM to 6 PM.',
              ),
              _buildContactItem(
                icon: Icons.location_on,
                title: 'Mailing Address',
                subtitle: 'SmartBracelet Technologies\n12 Innovation Street\n75008 Paris, France',
              ),
              _buildContactItem(
                icon: Icons.timer,
                title: 'Estimated Response Time',
                subtitle: 'Within 24 to 48 hours maximum.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF000080), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}