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
          'fullName': _fullNameController.text.trim(),
          'nickname': _nicknameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'country': _countryController.text.trim(),
          'gender': _selectedGender,
          'address': _addressController.text.trim(),
        };

        if (Get.arguments == null) {
          await ApiService.createProfile(
            userId: userId!,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            nickname: _nicknameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            country: _countryController.text.trim(),
            gender: _selectedGender,
            address: _addressController.text.trim(),
          );
        } else {
          await ApiService.updateProfile(
            userId: userId!,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            nickname: _nicknameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            country: _countryController.text.trim(),
            gender: _selectedGender,
            address: _addressController.text.trim(),
          );
        }

        Get.back();
        Get.snackbar('Success', 'Profile updated successfully', backgroundColor: const Color.fromARGB(68, 76, 175, 79));
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF98b5e4), Color.fromARGB(255, 255, 255, 255)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Styles.defaultPadding * 1.5), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        color: Color(0xFF000080),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(66, 0, 0, 0),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Styles.defaultPadding * 2), // Increased spacing after header
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
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.trim().length < 2) {
                                  return 'Full name must be at least 2 characters long';
                                }
                                if (value.trim().length > 50) {
                                  return 'Full name cannot exceed 50 characters';
                                }
                                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                  return 'Full name can only contain letters and spaces';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Styles.defaultPadding * 2), // Increased spacing between fields
                            _buildTextField(
                              controller: _nicknameController,
                              label: 'Nickname',
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (value.trim().length < 2) {
                                    return 'Nickname must be at least 2 characters long';
                                  }
                                  if (value.trim().length > 30) {
                                    return 'Nickname cannot exceed 30 characters';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                    return 'Nickname can only contain letters, numbers, and underscores';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Styles.defaultPadding * 2),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email (e.g., example@domain.com)';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Styles.defaultPadding * 2),
                            _buildTextField(
                              controller: _phoneNumberController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                                  return 'Please enter a valid phone number (e.g., +1234567890)';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Styles.defaultPadding * 2),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _countryController,
                                    label: 'Country',
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your country';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Country name must be at least 2 characters long';
                                      }
                                      if (value.trim().length > 50) {
                                        return 'Country name cannot exceed 50 characters';
                                      }
                                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                        return 'Country name can only contain letters and spaces';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: Styles.defaultPadding * 1.5),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                      filled: true,
                                      fillColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
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
                                    items: ['Male', 'Female'].map((String gender) {
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
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select your gender';
                                      }
                                      return null;
                                    },
                                    dropdownColor: const Color(0xFF1E2A44),
                                    iconEnabledColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Styles.defaultPadding * 2),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your address';
                                }
                                if (value.trim().length < 5) {
                                  return 'Address must be at least 5 characters long';
                                }
                                if (value.trim().length > 100) {
                                  return 'Address cannot exceed 100 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Styles.defaultPadding * 8), 
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0066FF),
                                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: Styles.defaultPadding * 2), 
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
        labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        filled: true,
        fillColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF000080).withOpacity(0.3)),
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
      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}