import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cvv = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? userId;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in', backgroundColor: Styles.defaultRedColor);
      Get.offNamed('/login');
    }
    if (mounted) setState(() {});
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
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void _addCardManually() async {
    if (formKey.currentState!.validate() && userId != null) {
      setState(() => isVerifying = true);
      try {
        await Future.delayed(Duration(seconds: 2)); // Simuler la connexion à l'émetteur
        Get.to(() => CardVerificationScreen(
              userId: userId!,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cvv: cvv,
            ));
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
      } finally {
        setState(() => isVerifying = false);
      }
    } else {
      Get.snackbar('Error', 'Please verify your information', backgroundColor: Styles.defaultRedColor);
    }
  }

  void _scanCard() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar('Error', 'Camera not available', backgroundColor: Styles.defaultRedColor);
      return;
    }
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in', backgroundColor: Styles.defaultRedColor);
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
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

        setState(() => isVerifying = true);
        try {
          await Future.delayed(Duration(seconds: 2)); // Simuler la connexion à l'émetteur
          Get.to(() => CardVerificationScreen(
                userId: userId!,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cvv: cvv,
              ));
        } catch (e) {
          Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
        } finally {
          setState(() => isVerifying = false);
        }
      } else {
        Get.snackbar('Error', 'Could not detect card information', backgroundColor: Styles.defaultRedColor);
      }

      await textRecognizer.close();
    } catch (e) {
      Get.snackbar('Error', 'Scan failed: $e', backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Card', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
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
              cardHolderName: '',
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
              cardHolderName: '',
              onCreditCardModelChange: _onCreditCardModelChange,
              inputConfiguration: InputConfiguration(
                cardNumberDecoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                ),
                expiryDateDecoration: InputDecoration(
                  labelText: 'Expiry Date',
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
                  labelText: 'Card Holder Name (filled next step)',
                  hintText: 'Filled next step',
                  border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                  enabled: false,
                ),
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: isVerifying ? null : _addCardManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: isVerifying
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Styles.defaultYellowColor,
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 10),
                        Text('Connecting to issuer...', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
                      ],
                    )
                  : Text('Add Manually', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: isVerifying ? null : _scanCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultGreyColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: isVerifying
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Styles.defaultYellowColor,
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 10),
                        Text('Connecting to issuer...', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
                      ],
                    )
                  : Text('Scan Card', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class CardVerificationScreen extends StatefulWidget {
  final String userId;
  final String cardNumber;
  final String expiryDate;
  final String cvv;

  CardVerificationScreen({
    required this.userId,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
  });

  @override
  _CardVerificationScreenState createState() => _CardVerificationScreenState();
}

class _CardVerificationScreenState extends State<CardVerificationScreen> {
  String cardHolderName = '';
  String cardSecurityCode = '';
  bool isVerifying = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _verifyAndAddCard() async {
    if (formKey.currentState!.validate() && cardSecurityCode.length == 4) {
      setState(() => isVerifying = true);
      try {
        await Future.delayed(Duration(seconds: 2)); 
        await ApiService.addCard(
          widget.userId,
          widget.cardNumber,
          widget.expiryDate,
          widget.cvv,
          cardHolderName,
          cardSecurityCode,
        );
        Get.snackbar('Success', 'Card added successfully', backgroundColor: Styles.defaultBlueColor);
        Get.offNamed('/home');
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
      } finally {
        setState(() => isVerifying = false);
      }
    } else {
      Get.snackbar('Error', 'Please enter valid information', backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Card Details', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
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
              cardNumber: widget.cardNumber,
              expiryDate: widget.expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: widget.cvv,
              showBackView: false,
              onCreditCardWidgetChange: (creditCardBrand) {},
              cardBgColor: Styles.defaultGreyColor,
              textStyle: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
            ),
            SizedBox(height: Styles.defaultPadding),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                      labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                      hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                      filled: true,
                      fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                    ),
                    style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik'),
                    onChanged: (value) {
                      setState(() {
                        cardHolderName = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Security Code (4 digits)',
                      hintText: 'XXXX',
                      border: OutlineInputBorder(borderRadius: Styles.defaultBorderRadius),
                      labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                      hintStyle: TextStyle(color: Styles.defaultLightGreyColor),
                      filled: true,
                      fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                    ),
                    style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik'),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (value) {
                      setState(() {
                        cardSecurityCode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
                        return 'Please enter a 4-digit security code';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: Styles.defaultPadding),
            ElevatedButton(
              onPressed: isVerifying ? null : _verifyAndAddCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.defaultBlueColor,
                foregroundColor: Styles.defaultYellowColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
              ),
              child: isVerifying
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Styles.defaultYellowColor,
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 10),
                        Text('Verifying...', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
                      ],
                    )
                  : Text('Verify and Add', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}