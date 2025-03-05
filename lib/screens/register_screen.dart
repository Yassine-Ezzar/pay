import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/biometric_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter/services.dart'; // Ajout pour quitter l'application

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

  // Inscription avec PIN
  void _registerWithPin() async {
    if (_enteredPin.length != 4 || _nameController.text.isEmpty || _answerController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs correctement',
          backgroundColor: Styles.defaultRedColor);
      return;
    }
    try {
      await ApiService.register(
        _nameController.text,
        _enteredPin,
        _answerController.text,
        _biometricEnabled,
      );
      Get.offNamed('/success'); 
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  // Inscription avec Face ID
  void _registerWithFaceId() async {
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
        title: 'Face ID Registration',
        message: 'Votre visage est en cours de reconnaissance...',
        icon: Icons.face,
        onConfirm: () async {
          try {
            await ApiService.register(
              'FaceIDUser_${DateTime.now().millisecondsSinceEpoch}',
              '0000', 
              'default',
              true,
            );
            Get.back(); 
            Get.offNamed('/success');
          } catch (e) {
            Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
          }
        },
      );
    } else {
      Get.snackbar('Erreur', 'Échec de la reconnaissance faciale.',
          backgroundColor: Styles.defaultRedColor);
    }
  }

  // Inscription avec Touch ID
  void _registerWithTouchId() async {
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
        title: 'Touch ID Registration',
        message: 'Placez votre doigt sur le lecteur d’empreintes...',
        icon: Icons.fingerprint,
        onConfirm: () async {
          try {
            await ApiService.register(
              'TouchIDUser_${DateTime.now().millisecondsSinceEpoch}',
              '0000', 
              'default',
              true,
            );
            Get.back(); 
            Get.offNamed('/success');
          } catch (e) {
            Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
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
        child: Text('Confirmer', style: TextStyle(fontFamily: 'Rubik')),
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
        backgroundColor: Styles.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Styles.defaultYellowColor),
          onPressed: () => SystemNavigator.pop(), // Quitte l'application
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenue ! Choisissez votre méthode',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20,
                color: Styles.defaultYellowColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Styles.defaultPadding * 2),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                filled: true,
                fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: Styles.defaultBorderRadius,
                  borderSide: BorderSide(color: Styles.defaultGreyColor),
                ),
              ),
              style: TextStyle(
                  color: Styles.defaultYellowColor, fontFamily: 'Rubik'),
            ),
            SizedBox(height: Styles.defaultPadding),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Nom de votre animal',
                labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                filled: true,
                fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: Styles.defaultBorderRadius,
                  borderSide: BorderSide(color: Styles.defaultGreyColor),
                ),
              ),
              style: TextStyle(
                  color: Styles.defaultYellowColor, fontFamily: 'Rubik'),
            ),
            SizedBox(height: Styles.defaultPadding * 2),
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
                    foregroundColor: Styles.defaultYellowColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(fontFamily: 'Rubik', fontSize: 20),
                  ),
                );
              })..addAll([
                  ElevatedButton(
                    onPressed: _deleteNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.defaultLightGreyColor,
                      foregroundColor: Styles.defaultYellowColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Icon(Icons.backspace),
                  ),
                  ElevatedButton(
                    onPressed: () => _addNumber('0'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.defaultLightGreyColor,
                      foregroundColor: Styles.defaultYellowColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('0',
                        style: TextStyle(fontFamily: 'Rubik', fontSize: 20)),
                  ),
                  SizedBox.shrink(),
                ]),
            ),
            SizedBox(height: Styles.defaultPadding * 2),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _enteredPin.length == 4 &&
                        _nameController.text.isNotEmpty &&
                        _answerController.text.isNotEmpty
                    ? _registerWithPin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.defaultBlueColor,
                  foregroundColor: Styles.defaultYellowColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius),
                ),
                child: Text(
                  'S’inscrire avec PIN',
                  style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
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
            ),
            SizedBox(height: Styles.defaultPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _registerWithFaceId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Styles.defaultRedColor,
                            Styles.defaultBlueColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.face, color: Styles.defaultYellowColor),
                          SizedBox(width: 5),
                          Text(
                            'Face ID',
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                color: Styles.defaultYellowColor),
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
                    onPressed: _registerWithTouchId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Styles.defaultRedColor,
                            Styles.defaultBlueColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint,
                              color: Styles.defaultYellowColor),
                          SizedBox(width: 5),
                          Text(
                            'Touch ID',
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                color: Styles.defaultYellowColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Styles.defaultPadding * 2),

            // Lien vers la connexion
            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: Text(
                'Déjà un compte ? Connectez-vous',
                style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultYellowColor,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}