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
    try {
      await ApiService.login(_nameController.text, _pinController.text);
      Get.offNamed('/success');
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  void _loginWithFaceId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Information',
        'Face ID n’est pas disponible sur cet appareil.',
        backgroundColor: Styles.defaultGreyColor,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Connexion avec Face ID',
        message: 'Votre visage est en cours de reconnaissance...',
        icon: Icons.face,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              await ApiService.login(name, ''); 
              Get.back(); 
              Get.offNamed('/success');
            } catch (e) {
              Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
            }
          } else {
            Get.snackbar('Erreur', 'Nom non trouvé. Veuillez vous connecter avec PIN d’abord.',
                backgroundColor: Styles.defaultRedColor);
          }
        },
      );
    } else {
      Get.snackbar('Erreur', 'Échec de la reconnaissance faciale.',
          backgroundColor: Styles.defaultRedColor);
    }
  }

  void _loginWithTouchId() async {
    bool canUseBiometrics = await _biometricService.canUseBiometrics();
    if (!canUseBiometrics) {
      Get.snackbar(
        'Information',
        'Touch ID n’est pas disponible sur cet appareil.',
        backgroundColor: Styles.defaultGreyColor,
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      _showBiometricDialog(
        title: 'Connexion avec Touch ID',
        message: 'Placez votre doigt sur le lecteur d’empreintes...',
        icon: Icons.fingerprint,
        onConfirm: () async {
          final name = await _storage.read(key: 'name');
          if (name != null) {
            try {
              await ApiService.login(name, ''); 
              Get.back(); 
              Get.offNamed('/success');
            } catch (e) {
              Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
            }
          } else {
            Get.snackbar('Erreur', 'Nom non trouvé. Veuillez vous connecter avec PIN d’abord.',
                backgroundColor: Styles.defaultRedColor);
          }
        },
      );
    } else {
      Get.snackbar('Erreur', 'Échec de la reconnaissance d’empreinte.',
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
        child: Text('Continuer', style: TextStyle(fontFamily: 'Rubik')),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text('Annuler',
            style: TextStyle(
                color: Styles.defaultYellowColor, fontFamily: 'Rubik')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: ClipRect(
        child: ListView(
          padding: EdgeInsets.all(Styles.defaultPadding),
          children: [
            Center(
              child: Text(
                'WELCOME BACK!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Styles.defaultYellowColor,
                ),
              ),
            ),
            SizedBox(height: Styles.defaultPadding * 2),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Rubik'),
                  ),
                );
              })..addAll([
                ElevatedButton(
                  onPressed: _deleteNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.defaultLightGreyColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.backspace, size: 20),
                ),
                ElevatedButton(
                  onPressed: () => _addNumber('0'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.defaultLightGreyColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(fontSize: 20, fontFamily: 'Rubik'),
                  ),
                ),
                const SizedBox.shrink(),
              ]),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: _enteredPin.length == 4 ? _loginWithPin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: Styles.defaultBorderRadius,
                ),
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(fontSize: 18, fontFamily: 'Rubik'),
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            TextButton(
              onPressed: () => Get.toNamed('/reset-pin'),
              child: Text(
                'Resend code',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: Styles.defaultYellowColor,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: Styles.defaultPadding / 2),
            Text(
              'Ou bien',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 14,
                color: Styles.defaultYellowColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Styles.defaultPadding),
            // Bouton Touch ID
            ElevatedButton(
              onPressed: _loginWithTouchId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: Styles.defaultBorderRadius,
                ),
              ),
              child: const Text(
                'Login with Touch ID',
                style: TextStyle(fontSize: 16, fontFamily: 'Rubik'),
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: _loginWithFaceId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: Styles.defaultBorderRadius,
                ),
              ),
              child: const Text(
                'Login with Face ID',
                style: TextStyle(fontSize: 16, fontFamily: 'Rubik'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}