import 'package:app/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0; // Default to "Home" tab as shown in the image
  String? userId;
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    } else {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final fetchedProfile = await ApiService.getProfile(userId!);
      setState(() {
        profile = fetchedProfile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        profile = null; // Clear profile if not found
        isLoading = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/notifications');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          padding: EdgeInsets.all(Styles.defaultPadding),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                profile?['fullName'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                profile?['email'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                profile?['phoneNumber'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () async {
                                  await Get.toNamed('/edit-profile', arguments: profile);
                                  _fetchProfile(); // Refresh profile after returning
                                },
                                child: const Text(
                                  'Edit profile information',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile Options
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                          child: Column(
                            children: [
                              _buildProfileOption(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: 'ON',
                              ),
                              _buildProfileOption(
                                icon: Icons.language,
                                title: 'Language',
                                subtitle: 'English',
                              ),
                              _buildProfileOption(
                                icon: Icons.security,
                                title: 'Security',
                                subtitle: '',
                                onTap: () => Get.toNamed('/reset-pin'),
                              ),
                              _buildProfileOption(
                                icon: Icons.brightness_6,
                                title: 'Theme',
                                subtitle: 'Light mode',
                              ),
                              _buildProfileOption(
                                icon: Icons.help,
                                title: 'Help & support',
                                subtitle: '',
                              ),
                              _buildProfileOption(
                                icon: Icons.contact_support,
                                title: 'Contact us',
                                subtitle: '',
                              ),
                              _buildProfileOption(
                                icon: Icons.privacy_tip,
                                title: 'Privacy Police',
                                subtitle: '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
          CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavItemTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.black54,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}