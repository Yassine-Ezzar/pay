import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cvv = '';
  String cardHolderName = ''; // Non utilisé mais requis par flutter_credit_card
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String userId = 'your-user-id-here'; // À remplacer dynamiquement
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber.replaceAll(' ', '');
      expiryDate = creditCardModel.expiryDate;
      cvv = creditCardModel.cvvCode;
      cardHolderName = creditCardModel.cardHolderName;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void _addCardManually() async {
    if (formKey.currentState!.validate()) {
      try {
        await ApiService.addCard(userId, cardNumber, expiryDate, cvv);
        Get.snackbar('Succès', 'Carte ajoutée avec succès', backgroundColor: Styles.defaultBlueColor);
        Get.offNamed('/card-list');
      } catch (e) {
        Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
      }
    }
  }

  void _scanCard() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar('Erreur', 'Caméra non disponible', backgroundColor: Styles.defaultRedColor);
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      String? extractedCardNumber;
      String? extractedExpiryDate;
      String? extractedCvv;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.replaceAll(' ', '');
          if (text.length == 16 && RegExp(r'^\d{16}$').hasMatch(text)) {
            extractedCardNumber = text;
          } else if (RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(text)) {
            extractedExpiryDate = text;
          } else if (RegExp(r'^\d{3,4}$').hasMatch(text)) {
            extractedCvv = text;
          }
        }
      }

      if (extractedCardNumber != null && extractedExpiryDate != null && extractedCvv != null) {
        setState(() {
          cardNumber = extractedCardNumber!;
          expiryDate = extractedExpiryDate!;
          cvv = extractedCvv!;
        });
        await ApiService.addCard(userId, cardNumber, expiryDate, cvv);
        Get.snackbar('Succès', 'Carte scannée et ajoutée avec succès', backgroundColor: Styles.defaultBlueColor);
        Get.offNamed('/card-list');
      } else {
        Get.snackbar('Erreur', 'Impossible de détecter les informations de la carte', backgroundColor: Styles.defaultRedColor);
      }

      await textRecognizer.close();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du scan: $e', backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une carte', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
        backgroundColor: Styles.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvv,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (creditCardBrand) {},
              cardBgColor: Styles.defaultGreyColor,
              textStyle: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
            ),
            CreditCardForm(
              formKey: formKey,
              obscureCvv: true,
              obscureNumber: false,
              cardNumber: cardNumber,
              cvvCode: cvv,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              onCreditCardModelChange: _onCreditCardModelChange,
              // Personnalisation via un thème global ou styles inline
              inputConfiguration: InputConfiguration(
                cardNumberDecoration: InputDecoration(
                  labelText: 'Numéro de carte',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                ),
                expiryDateDecoration: InputDecoration(
                  labelText: 'Date d’expiration',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                ),
                cvvCodeDecoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                ),
                cardHolderDecoration: InputDecoration(
                  labelText: 'Titulaire (non requis)',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                ),
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: _addCardManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: Text('Ajouter manuellement', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: _scanCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: Text('Scanner la carte', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}