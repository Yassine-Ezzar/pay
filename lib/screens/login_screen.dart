import 'dart:io'; // Pour Platform
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
      Get.snackbar('Error', 'Please enter your name and a 4-digit PIN',
          backgroundColor: Styles.defaultRedColor);
      return;
    }
    try {
      await ApiService.login(_nameController.text, _enteredPin);
      Get.offNamed('/card-list');
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  void _loginWithFaceId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info',
        'Face ID is not available on this device.',
        backgroundColor: Styles.defaultGreyColor,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Login with Face ID',
        message: 'Your face is being recognized...',
        icon: Icons.face,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              await ApiService.login(name, ''); 
              Get.back();
              Get.offNamed('/card-list');
            } catch (e) {
              Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
            }
          } else {
            Get.snackbar('Error', 'Name not found. Please log in with PIN first.',
                backgroundColor: Styles.defaultRedColor);
          }
        },
      );
    } else {
      Get.snackbar('Error', 'Face recognition failed.', backgroundColor: Styles.defaultRedColor);
    }
  }

  void _loginWithTouchId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Info',
        'Touch ID is not available on this device.',
        backgroundColor: Styles.defaultGreyColor,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Login with Touch ID',
        message: 'Place your finger on the sensor...',
        icon: Icons.fingerprint,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              await ApiService.login(name, ''); 
              Get.back();
              Get.offNamed('/card-list');
            } catch (e) {
              Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
            }
          } else {
            Get.snackbar('Error', 'Name not found. Please log in with PIN first.',
                backgroundColor: Styles.defaultRedColor);
          }
        },
      );
    } else {
      Get.snackbar('Error', 'Fingerprint recognition failed.',
          backgroundColor: Styles.defaultRedColor);
    }
  }

  void _showBiometricDialog({
    required String title,
    required String message,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      backgroundColor: Styles.scaffoldBackgroundColor,
      title: title,
      titleStyle: TextStyle(
        fontFamily: 'Rubik',
        color: Styles.defaultYellowColor,
        fontSize: 24,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Styles.defaultYellowColor),
          SizedBox(height: Styles.defaultPadding),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Styles.defaultYellowColor),
          ),
          SizedBox(height: Styles.defaultPadding),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Styles.defaultLightWhiteColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: onConfirm,
        child: Text('Continue', style: TextStyle(fontFamily: 'Rubik')),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text('Cancel',
            style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS; // Détection de la plateforme

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.offNamed('/register'),
        ),
        backgroundColor: Styles.scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.all(Styles.defaultPadding),
        children: [
          Center(
            child: Text(
              'Welcome Back!',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Styles.defaultYellowColor,
              ),
            ),
          ),
          SizedBox(height: Styles.defaultPadding * 2),
      

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: isIOS ? _loginWithFaceId : _loginWithTouchId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.defaultRedColor, Styles.defaultBlueColor],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIOS ? Icons.face : Icons.fingerprint,
                          color: Styles.defaultYellowColor,
                        ),
                        SizedBox(width: 5),
                        Text(
                          isIOS ? 'Face ID' : 'Touch ID',
                          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ),
              
              SizedBox(width: Styles.defaultPadding),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: isIOS ? _loginWithTouchId : _loginWithFaceId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.defaultRedColor, Styles.defaultBlueColor],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIOS ? Icons.fingerprint : Icons.face,
                          color: Styles.defaultYellowColor,
                        ),
                        SizedBox(width: 5),
                        Text(
                          isIOS ? 'Touch ID' : 'Face ID',
                          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            
          ),
          
          SizedBox(height: Styles.defaultPadding / 2),
          Text(
            'Or',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              color: Styles.defaultYellowColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Styles.defaultPadding),
      TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Styles.defaultGreyColor),
                borderRadius: Styles.defaultBorderRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Styles.defaultYellowColor),
                borderRadius: Styles.defaultBorderRadius,
              ),
            ),
            style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik'),
          ),
          SizedBox(height: Styles.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? Styles.defaultYellowColor
                        : Styles.defaultGreyColor,
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
                  backgroundColor: Styles.defaultLightGreyColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontSize: 20, fontFamily: 'Rubik'),
                ),
              );
            })..addAll([
                ElevatedButton(
                  onPressed: _deleteNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.defaultLightGreyColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Icon(Icons.backspace, size: 20),
                ),
                ElevatedButton(
                  onPressed: () => _addNumber('0'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.defaultLightGreyColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 20, fontFamily: 'Rubik'),
                  ),
                ),
                SizedBox.shrink(),
              ]),
          ),
          SizedBox(height: Styles.defaultPadding),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _enteredPin.length == 4 && _nameController.text.isNotEmpty
                  ? _loginWithPin
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: Text(
                'Login with PIN',
                style: TextStyle(fontSize: 18, fontFamily: 'Rubik'),
              ),
            ),
          ),
          SizedBox(height: Styles.defaultPadding),
          TextButton(
            onPressed: () => Get.toNamed('/reset-pin'),
            child: Text(
              'Forgot PIN? Reset it',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: Styles.defaultYellowColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}