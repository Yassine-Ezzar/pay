import 'dart:io'; // Pour Platform
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/biometric_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _answerController = TextEditingController();
  final _biometricService = BiometricService();
  String _enteredPin = '';
  bool _biometricEnabled = false;
  bool _faceIdCompleted = false; // Track if Face ID registration is complete
  bool _isFaceIdSelected = true; // Default to Face ID method
  bool _isTouchIdSelected = false;
  bool _isPinSelected = false;

  void _addNumber(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });
    }
  }

  void _deleteNumber() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  // Register with Face ID
  void _registerWithFaceId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info',
        'Face ID is not available on this device.',
        backgroundColor: Styles.defaultGreyColor,
        colorText: Colors.black,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      setState(() {
        _faceIdCompleted = true; 
      });
    } else {
      Get.snackbar(
        'Error',
        'Face recognition failed.',
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
    }
  }

  // Register with Touch ID
  void _registerWithTouchId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info',
        'Touch ID is not available on this device.',
        backgroundColor: Styles.defaultGreyColor,
        colorText: Colors.black,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      try {
        await ApiService.register(
          _nameController.text.isNotEmpty
              ? _nameController.text
              : 'TouchIDUser_${DateTime.now().millisecondsSinceEpoch}',
          '0000',
          _answerController.text.isNotEmpty ? _answerController.text : 'default',
          true,
        );
        await ApiService.clearProfileFromLocal();
        Get.offNamed('/checking'); // Navigate to CheckingScreen
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Styles.defaultRedColor,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Fingerprint recognition failed.',
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
    }
  }

  // Register with PIN
  void _registerWithPin() async {
    if (_enteredPin.length != 4 ||
        _nameController.text.isEmpty ||
        _answerController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields correctly',
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
      return;
    }
    try {
      await ApiService.register(
        _nameController.text,
        _enteredPin,
        _answerController.text,
        _biometricEnabled,
      );
      await ApiService.clearProfileFromLocal();
      Get.offNamed('/checking');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
    }
  }

  void _switchToFaceId() {
    setState(() {
      _isFaceIdSelected = true;
      _isTouchIdSelected = false;
      _isPinSelected = false;
      _enteredPin = '';
    });
  }

  void _switchToTouchId() {
    setState(() {
      _isFaceIdSelected = false;
      _isTouchIdSelected = true;
      _isPinSelected = false;
      _enteredPin = '';
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
          icon: const Icon(Icons.close, color: Color(0xFF063B87)),
          onPressed: () => SystemNavigator.pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            if (_isFaceIdSelected) ...[
              const Text(
                'Face ID',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87),
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              const Text(
                'Position the face in the correct angle to show the face places.',
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
  child: ClipOval(
    child: Image.asset(
      'assets/images/face-id.png',
      width: 160 ,
      height: 160,
      fit: BoxFit.cover, 
    ),
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
                  onPressed: _faceIdCompleted
                      ? () async {
                          try {
                            await ApiService.register(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text
                                  : 'FaceIDUser_${DateTime.now().millisecondsSinceEpoch}',
                              '0000',
                              _answerController.text.isNotEmpty
                                  ? _answerController.text
                                  : 'default',
                              true,
                            );
                            await ApiService.clearProfileFromLocal();
                            Get.offNamed('/checking');
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              backgroundColor: Styles.defaultRedColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Next Step',
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
            // Touch ID registration UI
            if (_isTouchIdSelected) ...[
              const Text(
                'Touch ID',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF063B87),
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              const Text(
                'Place your finger on the sensor to register.',
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
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: _registerWithTouchId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Register with Touch ID',
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
            // PIN registration UI (similar to the original)
            if (_isPinSelected) ...[
              const Text(
                'Register with PIN',
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
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Pet’s Name',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
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
                    onPressed: () => _addNumber('${index + 1}'),
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
                      onPressed: _deleteNumber,
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
                      onPressed: () => _addNumber('0'),
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
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: _enteredPin.length == 4 &&
                          _nameController.text.isNotEmpty &&
                          _answerController.text.isNotEmpty
                      ? _registerWithPin
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Register with PIN',
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
            SizedBox(height: Styles.defaultPadding * 2),
            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: const Text(
                'Already have an account? Log in',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 14,
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