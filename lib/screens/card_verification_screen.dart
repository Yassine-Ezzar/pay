import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class CardVerificationScreen extends StatefulWidget {
  @override
  _CardVerificationScreenState createState() => _CardVerificationScreenState();
}

class _CardVerificationScreenState extends State<CardVerificationScreen> {
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyCard();
  }

  Future<void> _verifyCard() async {
    final arguments = Get.arguments;
    final String cardNumber = arguments['cardNumber'];
    final String cardHolderName = arguments['cardHolderName'];
    final String expiryDate = arguments['expiryDate'];
    final String cvv = arguments['cvv'];
    final String cardSecurityCode = arguments['cardSecurityCode'] ?? '';
    final String userId = arguments['userId'];

    setState(() => _isVerifying = true);
    try {
      await Future.delayed(const Duration(seconds: 2)); 

      await ApiService.addCard(
        userId,
        cardNumber,
        expiryDate,
        cvv,
        cardHolderName,
        cardSecurityCode,
      );

      Get.snackbar('Success', 'Card added successfully', backgroundColor: Colors.green);
      Get.offAllNamed('/home');
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Verifying Your Card',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (_isVerifying)
                const CircularProgressIndicator(color: Colors.white)
              else if (_errorMessage != null)
                Column(
                  children: [
                    const Text(
                      'Verification Failed',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}