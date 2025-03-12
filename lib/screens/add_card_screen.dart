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
  String cardHolderName = '';
  bool isCvvFocused = false;
  bool isLoading = false; // Indicateur de chargement
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? userId;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté', backgroundColor: Styles.defaultRedColor);
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
      cardHolderName = creditCardModel.cardHolderName;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void _addCardManually() async {
    if (formKey.currentState!.validate() && userId != null) {
      setState(() => isLoading = true);
      try {
        await ApiService.addCard(userId!, cardNumber, expiryDate, cvv);
        Get.snackbar('Succès', 'Carte ajoutée avec succès',
            backgroundColor: Styles.defaultBlueColor, colorText: Styles.defaultYellowColor);
        Get.offNamed('/card-list');
      } catch (e) {
        Get.snackbar('Erreur', e.toString(),
            backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      Get.snackbar('Erreur', 'Veuillez vérifier vos informations',
          backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
    }
  }

  void _scanCard() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar('Erreur', 'Caméra non disponible',
          backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      return;
    }
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté',
          backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      return;
    }

    setState(() => isLoading = true);
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
        await ApiService.addCard(userId!, cardNumber, expiryDate, cvv);
        Get.snackbar('Succès', 'Carte scannée et ajoutée avec succès',
            backgroundColor: Styles.defaultBlueColor, colorText: Styles.defaultYellowColor);
        Get.offNamed('/card-list');
      } else {
        Get.snackbar('Erreur', 'Impossible de détecter les informations de la carte',
            backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      }

      await textRecognizer.close();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du scan: $e',
          backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Styles.scaffoldBackgroundColor,
        title: Text(
          'Ajouter une carte',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Styles.defaultYellowColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(Styles.defaultPadding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de section
                Text(
                  'Informations de la carte',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 18,
                    color: Styles.defaultLightWhiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Styles.defaultPadding),
                // Carte affichée
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvv,
                  showBackView: isCvvFocused,
                  onCreditCardWidgetChange: (creditCardBrand) {},
                  cardBgColor: Styles.defaultGreyColor,
                  glassmorphismConfig: Glassmorphism.defaultConfig(),
                  textStyle: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultYellowColor,
                    fontSize: 16,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                ),
                SizedBox(height: Styles.defaultPadding * 1.5),
                // Formulaire avec animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: CreditCardForm(
                    formKey: formKey,
                    obscureCvv: true,
                    obscureNumber: false,
                    cardNumber: cardNumber,
                    cvvCode: cvv,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    onCreditCardModelChange: _onCreditCardModelChange,
                    inputConfiguration: InputConfiguration(
                      cardNumberDecoration: InputDecoration(
                        prefixIcon: Icon(Icons.credit_card, color: Styles.defaultYellowColor),
                        labelText: 'Numéro de carte',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        border: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultLightGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                        ),
                        labelStyle: TextStyle(color: Styles.defaultLightWhiteColor, fontFamily: 'Rubik'),
                        hintStyle: TextStyle(color: Styles.defaultLightGreyColor, fontFamily: 'Rubik'),
                        filled: true,
                        fillColor: Styles.defaultLightGreyColor.withOpacity(0.1),
                      ),
                      expiryDateDecoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today, color: Styles.defaultYellowColor),
                        labelText: 'Date d’expiration',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultLightGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                        ),
                        labelStyle: TextStyle(color: Styles.defaultLightWhiteColor, fontFamily: 'Rubik'),
                        hintStyle: TextStyle(color: Styles.defaultLightGreyColor, fontFamily: 'Rubik'),
                        filled: true,
                        fillColor: Styles.defaultLightGreyColor.withOpacity(0.1),
                      ),
                      cvvCodeDecoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Styles.defaultYellowColor),
                        labelText: 'CVV',
                        hintText: 'XXX',
                        border: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultLightGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                        ),
                        labelStyle: TextStyle(color: Styles.defaultLightWhiteColor, fontFamily: 'Rubik'),
                        hintStyle: TextStyle(color: Styles.defaultLightGreyColor, fontFamily: 'Rubik'),
                        filled: true,
                        fillColor: Styles.defaultLightGreyColor.withOpacity(0.1),
                      ),
                      cardHolderDecoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Styles.defaultYellowColor),
                        labelText: 'Titulaire (optionnel)',
                        border: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultLightGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Styles.defaultBorderRadius,
                          borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                        ),
                        labelStyle: TextStyle(color: Styles.defaultLightWhiteColor, fontFamily: 'Rubik'),
                        hintStyle: TextStyle(color: Styles.defaultLightGreyColor, fontFamily: 'Rubik'),
                        filled: true,
                        fillColor: Styles.defaultLightGreyColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Styles.defaultPadding * 2),
                // Boutons avec gradient et icônes
                _buildActionButton(
                  text: 'Ajouter manuellement',
                  icon: Icons.add_card,
                  gradient: LinearGradient(
                    colors: [Styles.defaultBlueColor, Styles.defaultBlueColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: _addCardManually,
                ),
                SizedBox(height: Styles.defaultPadding),
                _buildActionButton(
                  text: 'Scanner la carte',
                  icon: Icons.camera_alt,
                  gradient: LinearGradient(
                    colors: [Styles.defaultGreyColor, Styles.defaultGreyColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: _scanCard,
                ),
              ],
            ),
          ),
          // Indicateur de chargement
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Styles.defaultYellowColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: Styles.defaultBorderRadius,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: Styles.defaultBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Styles.defaultBlueColor.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Styles.defaultYellowColor, size: 20),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16,
                color: Styles.defaultYellowColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}