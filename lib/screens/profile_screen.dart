import 'package:app/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  String? userId;
  Map<String, dynamic>? profile;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final storage = const FlutterSecureStorage();
  String? selectedAvatar; // To store the selected avatar identifier

  // List of available avatars (using icons for simplicity; you can replace with asset images)
  final List<Map<String, dynamic>> avatars = [
    {'id': 'avatar1', 'icon': Icons.person},
    {'id': 'avatar2', 'icon': Icons.face},
    {'id': 'avatar3', 'icon': Icons.account_circle},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadUserId();
    _loadAvatar();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    } else {
      _fetchProfile();
    }
  }

  Future<void> _loadAvatar() async {
    String? savedAvatar = await storage.read(key: 'selectedAvatar');
    setState(() {
      selectedAvatar = savedAvatar ?? 'avatar1'; // Default to avatar1 if none is saved
    });
  }

  Future<void> _saveAvatar(String avatarId) async {
    await storage.write(key: 'selectedAvatar', value: avatarId);
    setState(() {
      selectedAvatar = avatarId;
    });
    Get.snackbar('Success', 'Avatar updated successfully', backgroundColor: Colors.green);
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
        profile = null; // Profile not found
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

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2A44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Your Avatar',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    final isSelected = selectedAvatar == avatar['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar['id'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            avatar['icon'],
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedAvatar != null) {
                          _saveAvatar(selectedAvatar!);
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF477bd0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Color(0xFF477bd0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Profile Header
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF98b5e4), Color(0xFF477bd0)],
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: Styles.defaultPadding * 2,
                                  horizontal: Styles.defaultPadding,
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          child: selectedAvatar == null
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  avatars.firstWhere((avatar) => avatar['id'] == selectedAvatar)['icon'],
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _showAvatarSelectionDialog,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                size: 20,
                                                color: Color(0xFF477bd0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      profile?['fullName'] ?? 'New User',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${profile?['email'] ?? 'N/A'} | ${profile?['phoneNumber'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    GestureDetector(
                                      onTap: () async {
                                        await Get.toNamed('/edit-profile', arguments: profile);
                                        _fetchProfile();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              profile == null
                                                  ? 'Create Profile Information'
                                                  : 'Edit Profile Information',
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                color: Colors.white,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Profile Options
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Styles.defaultPadding,
                                  vertical: Styles.defaultPadding,
                                ),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    children: [
                                      _buildProfileOption(
                                        icon: Icons.notifications,
                                        title: 'Notifications',
                                        subtitle: 'ON',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.language,
                                        title: 'Language',
                                        subtitle: 'English',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.security,
                                        title: 'Security',
                                        onTap: () => Get.toNamed('/reset-pin'),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.brightness_6,
                                        title: 'Theme',
                                        subtitle: 'Dark Mode',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.help,
                                        title: 'Help & Support',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.support_agent,
                                        title: 'Contact Us',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildProfileOption(
                                        icon: Icons.privacy_tip,
                                        title: 'Privacy Policy',
                                      ),
                                      const SizedBox(height: 20),
                                      _buildProfileOption(
                                        icon: Icons.logout,
                                        title: 'Logout',
                                        color: Colors.redAccent,
                                        onTap: () async {
                                          await ApiService.storage.deleteAll();
                                          Get.offAllNamed('/login');
                                        },
                                      ),
                                    ],
                                  ),
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
    String? subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A44),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.white70),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}