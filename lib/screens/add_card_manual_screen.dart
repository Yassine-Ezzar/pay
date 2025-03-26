import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCardManualScreen extends StatefulWidget {
  @override
  _AddCardManualScreenState createState() => _AddCardManualScreenState();
}

class _AddCardManualScreenState extends State<AddCardManualScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';
  String _cardSecurityCode = '';
  String? userId;
  bool _isLoading = false;
  bool _showBackView = false; // To toggle between front and back of the card

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    }
  }

  Future<void> _submitCard() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        // Proceed to verification
        Get.toNamed('/card-verification', arguments: {
          'cardNumber': _cardNumber.replaceAll(' ', ''), // Remove spaces for backend
          'cardHolderName': _cardHolderName,
          'expiryDate': _expiryDate,
          'cvv': _cvv,
          'cardSecurityCode': _cardSecurityCode,
          'userId': userId,
        });
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Card Manually',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dynamic Credit Card Illustration
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Styles.defaultPadding,
                horizontal: Styles.defaultPadding,
              ),
              child: CreditCardWidget(
                cardNumber: _cardNumber,
                expiryDate: _expiryDate,
                cardHolderName: _cardHolderName,
                cvvCode: _cvv,
                showBackView: _showBackView,
                onCreditCardWidgetChange: (creditCardBrand) {},
                cardBgColor: Colors.blueAccent,
                glassmorphismConfig: Glassmorphism.defaultConfig(),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                animationDuration: const Duration(milliseconds: 300),
              ),
            ),
            // Form
            Padding(
              padding: EdgeInsets.all(Styles.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Details',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Card Number
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.credit_card, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter(), // Custom formatter for spacing
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card number';
                        }
                        if (value.replaceAll(' ', '').length != 16) {
                          return 'Enter a valid 16-digit card number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _cardNumber = value;
                        });
                      },
                      onSaved: (value) => _cardNumber = value!,
                    ),
                    const SizedBox(height: 20),
                    // Cardholder Name
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Cardholder Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cardholder name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _cardHolderName = value;
                        });
                      },
                      onSaved: (value) => _cardHolderName = value!,
                    ),
                    const SizedBox(height: 20),
                    // Expiry Date and CVV
                    Row(
                      children: [
                        // Expiry Date
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Expiry Date (MM/YY)',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              ExpiryDateInputFormatter(), // Custom formatter for MM/YY
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter expiry date';
                              }
                              if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                                return 'Enter a valid expiry date (MM/YY)';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _expiryDate = value;
                              });
                            },
                            onSaved: (value) => _expiryDate = value!,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // CVV
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter CVV';
                              }
                              if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                                return 'Enter a valid 3-digit CVV';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _cvv = value;
                                _showBackView = true; // Show back view when CVV is focused
                              });
                            },
                            onFieldSubmitted: (value) {
                              setState(() {
                                _showBackView = false; // Hide back view when done
                              });
                            },
                            onSaved: (value) => _cvv = value!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Card Security Code
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Card Security Code',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.security, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card security code';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _cardSecurityCode = value;
                        });
                      },
                      onSaved: (value) => _cardSecurityCode = value!,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom formatter for card number (adds space every 4 digits)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }
    StringBuffer newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        newText.write(' ');
      }
      newText.write(text[i]);
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Custom formatter for expiry date (adds slash after MM)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    StringBuffer newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        newText.write('/');
      }
      newText.write(text[i]);
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}