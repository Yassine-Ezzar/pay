import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
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
              Text(
                'Our Team Is Here for You',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'to address your inquiries, suggestions, or bug reports.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),
              _buildContactItem(
                context: context,
                icon: Icons.email,
                title: 'Email',
                subtitle: '',
              ),
              _buildContactItem(
                context: context,
                icon: Icons.phone,
                title: 'Phone',
                subtitle: '',
              ),
              _buildContactItem(
                context: context,
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available in the app Monday to Friday, 9 AM to 6 PM.',
              ),
              _buildContactItem(
                context: context,
                icon: Icons.location_on,
                title: 'Mailing Address',
                subtitle: 'SmartBracelet Technologies\n12 Innovation Street\n75008 Paris, France',
              ),
              _buildContactItem(
                context: context,
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

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? Styles.darkDefaultBlueColor
                : const Color(0xFF000080),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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