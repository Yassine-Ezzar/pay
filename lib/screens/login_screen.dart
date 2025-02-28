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
  final _storage = FlutterSecureStorage();
  String _enteredPin = ''; // Pour suivre les chiffres entrés dans le PIN

  void _addNumber(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _pinController.text = _enteredPin; // Mettre à jour le contrôleur pour le backend
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
    Get.offNamed('/success'); // Redirection vers SuccessScreen
  } catch (e) {
    Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
  }
}

void _loginWithBiometric() async {
  if (await _biometricService.authenticate()) {
    final name = await _storage.read(key: 'name');
    if (name != null) {
      try {
        await ApiService.login(name, '');
        Get.offNamed('/success'); // Redirection vers SuccessScreen
      } catch (e) {
        Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.offNamed('/register'), // Redirige vers /register au lieu de Get.back()
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
            // Champ pour le nom
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
            // Grille de boutons pour le PIN
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
                    style: TextStyle(fontSize: 20, fontFamily: 'Rubik'),
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
                  child: Icon(Icons.backspace, size: 20),
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
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 20, fontFamily: 'Rubik'),
                  ),
                ),
                SizedBox.shrink(),
              ]),
            ),
            SizedBox(height: Styles.defaultPadding),
            // Bouton SUBMIT
            ElevatedButton(
              onPressed: _enteredPin.length == 4 ? _loginWithPin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: Styles.defaultBorderRadius,
                ),
              ),
              child: Text(
                'SUBMIT',
                style: TextStyle(fontSize: 18, fontFamily: 'Rubik'),
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            // Lien Resend code (optionnel)
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
            SizedBox(height: Styles.defaultPadding),
          
            SizedBox(height: Styles.defaultPadding),
            // Bouton biométrique
            ElevatedButton(
              onPressed: _loginWithBiometric,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: Styles.defaultBorderRadius,
                ),
              ),
              child: Text(
                'Login with Biometrics',
                style: TextStyle(fontSize: 16, fontFamily: 'Rubik'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}