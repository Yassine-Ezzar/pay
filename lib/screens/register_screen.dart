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
  bool _faceIdCompleted = false; 
  bool _isFaceIdSelected = true; 
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
        'Info'.tr,
        'Face ID is not available on this device.'.tr,
        backgroundColor: Styles.defaultGreyColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
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
        'Error'.tr,
        'Face recognition failed.'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
      );
    }
  }

  // Register with Touch ID
  void _registerWithTouchId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info'.tr,
        'Touch ID is not available on this device.'.tr,
        backgroundColor: Styles.defaultGreyColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
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
          colorText: Theme.of(context).textTheme.bodyLarge?.color,
        );
      }
    } else {
      Get.snackbar(
        'Error'.tr,
        'Fingerprint recognition failed.'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
      );
    }
  }

  // Register with PIN
  void _registerWithPin() async {
    if (_enteredPin.length != 4 ||
        _nameController.text.isEmpty ||
        _answerController.text.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please fill all fields correctly'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
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
        'Error'.tr,
        e.toString(),
        backgroundColor: Styles.defaultRedColor,
        colorText: Theme.of(context).textTheme.bodyLarge?.color,
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
          icon: Icon(
            Icons.close,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
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
                _buildMethodButton('Face ID'.tr, _isFaceIdSelected, _switchToFaceId),
                SizedBox(width: Styles.defaultPadding / 2),
                _buildMethodButton('Touch ID'.tr, _isTouchIdSelected, _switchToTouchId),
                SizedBox(width: Styles.defaultPadding / 2),
                _buildMethodButton('PIN'.tr, _isPinSelected, _switchToPin),
              ],
            ),
            SizedBox(height: Styles.defaultPadding * 2),
            if (_isFaceIdSelected) ...[
              Text(
                'Face ID'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              Text(
                'Position the face in the correct angle to show the face places.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightGreyColor
                      : Colors.grey[200],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/face-id.png',
                    width: 160,
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
                        color: index == 1
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightGreyColor
                                : Colors.grey[300],
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
                              colorText: Theme.of(context).textTheme.bodyLarge?.color,
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Next Step'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                    ),
                  ),
                ),
              ),
            ],
            // Touch ID registration UI
            if (_isTouchIdSelected) ...[
              Text(
                'Touch ID'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              Text(
                'Place your finger on the sensor to register.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightGreyColor
                      : Colors.grey[200],
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultYellowColor
                      : Colors.grey[400],
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: _registerWithTouchId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Register with Touch ID'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                    ),
                  ),
                ),
              ),
            ],
            // PIN registration UI
            if (_isPinSelected) ...[
              Text(
                'Register with PIN'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name'.tr,
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightGreyColor
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultGreyColor
                        : Colors.grey),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Pet’s Name'.tr,
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultLightGreyColor
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultGreyColor
                        : Colors.grey),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightGreyColor
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
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Styles.darkDefaultLightGreyColor
                          : Colors.grey[200],
                      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
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
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkDefaultLightGreyColor
                            : Colors.grey[200],
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.backspace),
                    ),
                    ElevatedButton(
                      onPressed: () => _addNumber('0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkDefaultLightGreyColor
                            : Colors.grey[200],
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Register with PIN'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: Styles.defaultPadding * 2),
            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: Text(
                'Already have an account? Log in'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).brightness == Brightness.dark
              ? Styles.darkDefaultLightGreyColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isSelected ? Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}) : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}