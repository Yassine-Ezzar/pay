import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isFrontScanned = false;
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _scanCard() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    setState(() => _isScanning = true);
    try {
      final picture = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      _extractCardDetails(recognizedText);

      setState(() {
        _isScanning = false;
      });

      await textRecognizer.close();

      if (_cardNumber.isNotEmpty && _cardHolderName.isNotEmpty && _expiryDate.isNotEmpty && _cvv.isNotEmpty) {
        final arguments = {
          'cardNumber': _cardNumber,
          'cardHolderName': _cardHolderName,
          'expiryDate': _expiryDate,
          'cvv': _cvv,
          'userId': userId,
        };
        Get.toNamed('/enter-contact', arguments: arguments);
      } else if (_isFrontScanned && _cvv.isEmpty) {
        Get.snackbar('Error', 'CVV not detected. Please scan the back side again.', backgroundColor: Colors.redAccent);
      } else if (!_isFrontScanned && (_cardNumber.isEmpty || _cardHolderName.isEmpty || _expiryDate.isEmpty)) {
        _isFrontScanned = true;
        Get.snackbar('Info', 'Front side scanned. Please scan the back side for CVV.', backgroundColor: Colors.blueAccent);
      }
    } catch (e) {
      setState(() => _isScanning = false);
      Get.snackbar('Error', 'Failed to scan card: $e', backgroundColor: Colors.redAccent);
    }
  }

  void _extractCardDetails(RecognizedText recognizedText) {
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text.trim();

        if (!_isFrontScanned && RegExp(r'^\d{4}\s?\d{4}\s?\d{4}\s?\d{4}$').hasMatch(text)) {
          _cardNumber = text.replaceAll(' ', '');
        }

        if (!_isFrontScanned && RegExp(r'^[A-Z\s]+$').hasMatch(text) && text.length > 5) {
          _cardHolderName = text;
        }
        if (!_isFrontScanned && RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(text)) {
          _expiryDate = text;
        }

        if (_isFrontScanned && RegExp(r'^\d{3,4}$').hasMatch(text)) {
          _cvv = text;
        }
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _isFrontScanned ? 'Scan Back Side' : 'Scan Front Side',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isFrontScanned
                            ? 'Hold the phone near the back of the card to scan the CVV.'
                            : 'Hold the phone near the front of the card to scan the details.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!_isScanning)
                        ElevatedButton(
                          onPressed: _scanCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: const Icon(Icons.camera_alt, size: 30),
                        ),
                      if (_isScanning)
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Get.toNamed('/add-card-manual');
                  },
                  child: const Text(
                    'Enter Card Details Manually',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}