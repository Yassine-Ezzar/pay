import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? userId;
  late TextEditingController _fullNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  String? _selectedGender;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadUserId();
    final profile = Get.arguments as Map<String, dynamic>?;
    _fullNameController = TextEditingController(text: profile?['fullName'] ?? '');
    _nicknameController = TextEditingController(text: profile?['nickname'] ?? '');
    _emailController = TextEditingController(text: profile?['email'] ?? '');
    _phoneNumberController = TextEditingController(text: profile?['phoneNumber'] ?? '');
    _countryController = TextEditingController(text: profile?['country'] ?? '');
    _addressController = TextEditingController(text: profile?['address'] ?? '');
    _selectedGender = profile?['gender'];
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final profileData = {
          'userId': userId!,
          'fullName': _fullNameController.text,
          'nickname': _nicknameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
          'country': _countryController.text,
          'gender': _selectedGender,
          'address': _addressController.text,
        };

        if (Get.arguments == null) {
          await ApiService.createProfile(
            userId: userId!,
            fullName: _fullNameController.text,
            email: _emailController.text,
            nickname: _nicknameController.text,
            phoneNumber: _phoneNumberController.text,
            country: _countryController.text,
            gender: _selectedGender,
            address: _addressController.text,
          );
        } else {
          await ApiService.updateProfile(
            userId: userId!,
            fullName: _fullNameController.text,
            email: _emailController.text,
            nickname: _nicknameController.text,
            phoneNumber: _phoneNumberController.text,
            country: _countryController.text,
            gender: _selectedGender,
            address: _addressController.text,
          );
        }

        Get.back();
        Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green);
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF98b5e4), Color(0xFF477bd0)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Styles.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _nicknameController,
                              label: 'Nickname',
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _phoneNumberController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _countryController,
                                    label: 'Country',
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    items: ['Male', 'Female', 'Other'].map((String gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(
                                          gender,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                    dropdownColor: const Color(0xFF1E2A44),
                                    iconEnabledColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF477bd0),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Color(0xFF477bd0))
                                    : const Text(
                                        'SUBMIT',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF477bd0),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}