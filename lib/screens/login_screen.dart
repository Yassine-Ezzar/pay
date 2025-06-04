import 'dart:io';
import 'package:app/services/api_service.dart';
import 'package:app/services/biometric_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _biometricService = BiometricService();
  final _storage = const FlutterSecureStorage();
  String _enteredPin = '';
  bool isLoading = false;
  bool _isFaceIdSelected = true; // Default to Face ID method
  bool _isTouchIdSelected = false;
  bool _isPinSelected = false;

  void _addNumber(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _pinController.text = _enteredPin;
      });
    }
  }

  void _deleteNumber() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _pinController.text = _enteredPin;
      });
    }
  }

  void _loginWithPin() async {
    if (_enteredPin.length != 4 || _nameController.text.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please enter your name and a 4-digit PIN',
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await ApiService.login(_nameController.text, _enteredPin);
      if (data['role'] == 'admin') {
        Get.offAllNamed('/admin-dashboard');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _loginWithFaceId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info'.tr,
        'face_id_not_available'.tr,
        backgroundColor: Styles.defaultGreyColor,
        colorText: Colors.black,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Login with Face ID'.tr,
        message: 'Your face is being recognized...'.tr,
        icon: Icons.face,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              final data = await ApiService.login(name, '', faceId: true);
              Get.back();
              if (data['role'] == 'admin') {
                Get.offAllNamed('/admin-dashboard');
              } else {
                Get.offAllNamed('/home');
              }
            } catch (e) {
              Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
            }
          } else {
            Get.snackbar(
              'Error'.tr,
              'Name not found. Please log in with PIN first.'.tr,
              backgroundColor: Styles.defaultRedColor,
              colorText: Colors.white,
            );
          }
        },
      );
    } else {
      Get.snackbar(
        'Error'.tr,
        'face_recognition_failed'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
    }
  }

  void _loginWithTouchId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info'.tr,
       'touch_id_not_available'.tr,
        backgroundColor: Styles.defaultGreyColor,
        colorText: Colors.black,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Login with Touch ID'.tr,
        message: 'Place your finger on the sensor...'.tr,
        icon: Icons.fingerprint,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              final data = await ApiService.login(name, '', touchId: true);
              Get.back();
              if (data['role'] == 'admin') {
                Get.offAllNamed('/admin-dashboard');
              } else {
                Get.offAllNamed('/home');
              }
            } catch (e) {
              Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
            }
          } else {
            Get.snackbar(
              'Error'.tr,
              'Name not found. Please log in with PIN first.'.tr,
              backgroundColor: Styles.defaultRedColor,
              colorText: Colors.white,
            );
          }
        },
      );
    } else {
      Get.snackbar(
        'Error'.tr,
        'Fingerprint recognition failed.'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
    }
  }

  void _showBiometricDialog({
    required String title,
    required String message,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: title,
      titleStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF063B87),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: const Color(0xFF063B87)),
          SizedBox(height: Styles.defaultPadding),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
          ),
          SizedBox(height: Styles.defaultPadding),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirm: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child:  Text(
           'continue'.tr  ,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child:  Text(
          'cancel'.tr,
          style: TextStyle(
            color: Color(0xFF063B87),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _switchToFaceId() {
    setState(() {
      _isFaceIdSelected = true;
      _isTouchIdSelected = false;
      _isPinSelected = false;
      _enteredPin = ''; 
      _pinController.text = '';
    });
  }

  void _switchToTouchId() {
    setState(() {
      _isFaceIdSelected = false;
      _isTouchIdSelected = true;
      _isPinSelected = false;
      _enteredPin = ''; 
      _pinController.text = '';
    });
  }

  void _switchToPin() {
    setState(() {
      _isFaceIdSelected = false;
      _isTouchIdSelected = false;
      _isPinSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF063B87)),
          onPressed: () => Get.offNamed('/register'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'welcome_back'.tr,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063B87), 
              ),
            ),
            SizedBox(height: Styles.defaultPadding * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMethodButton('Face ID', _isFaceIdSelected, _switchToFaceId),
                SizedBox(width: Styles.defaultPadding / 2),
                _buildMethodButton('Touch ID', _isTouchIdSelected, _switchToTouchId),
                SizedBox(width: Styles.defaultPadding / 2),
                _buildMethodButton('PIN', _isPinSelected, _switchToPin),
              ],
            ),
            SizedBox(height: Styles.defaultPadding * 2),
            // Face ID login UI
            if (_isFaceIdSelected) ...[
               Text(
                'face_id'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87), 
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
               Text(
              'position_face'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black, 
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.face,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 1 ? const Color(0xFF0066FF) : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _loginWithFaceId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                          'login_with_face_id'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            // Touch ID login UI
            if (_isTouchIdSelected) ...[
               Text(
                'touch_id'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87), 
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
               Text(
                'place_finger'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black, 
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 1 ? const Color(0xFF0066FF) : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _loginWithTouchId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                          'login_with_touch_id'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            // PIN login UI
            if (_isPinSelected) ...[
               Text(
               'login_with_pin'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87), 
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr,
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF063B87)),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length
                            ? const Color(0xFF063B87)
                            : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: List.generate(9, (index) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : () => _addNumber('${index + 1}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                      ),
                    ),
                  );
                })
                  ..addAll([
                    ElevatedButton(
                      onPressed: isLoading ? null : _deleteNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.backspace),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _addNumber('0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox.shrink(),
                  ]),
              ),
              SizedBox(height: Styles.defaultPadding),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: isLoading ||
                          _enteredPin.length != 4 ||
                          _nameController.text.isEmpty
                      ? null
                      : _loginWithPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                          'login_with_pin'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            SizedBox(height: Styles.defaultPadding),
            TextButton(
              onPressed: isLoading ? null : () => Get.toNamed('/reset-pin'),
              child: Text(
                'forgot_pin_reset'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Styles.defaultPadding,
          vertical: Styles.defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}