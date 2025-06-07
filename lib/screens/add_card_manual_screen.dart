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
  bool _showBackView = false;

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
        final needsOTP = await ApiService.checkOTPRequirement(userId!);
        if (needsOTP) {
          Get.toNamed('/enter-contact', arguments: {
            'card_number'.tr: _cardNumber.replaceAll(' ', ''),
            'cardholder_name'.tr: _cardHolderName,
            'expiryDate': _expiryDate,
            'cvv': _cvv,
            'card_security_code'.tr: _cardSecurityCode,
            'userId': userId,
          });
        } else {
          Get.toNamed('/card-verification', arguments: {
            'card_number'.tr: _cardNumber.replaceAll(' ', ''),
            'cardholder_name'.tr: _cardHolderName,
           'expiry_date'.tr: _expiryDate,
            'cvv': _cvv,
            'card_security_code'.tr: _cardSecurityCode,
            'userId': userId,
          });
        }
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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF063B87)),
          onPressed: () => Get.back(),
        ),
        title: Text(
         'add_card_manually'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                cardBgColor: Color(0xFF0066FF),
                glassmorphismConfig: Glassmorphism.defaultConfig(),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                animationDuration: const Duration(milliseconds: 300),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Styles.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'card_details'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063B87),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'card_number'.tr,
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.credit_card, color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_card_number'.tr;
                        }
                        if (value.replaceAll(' ', '').length != 16) {
                          return 'valid_16_digit_card'.tr;
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
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'cardholder_name'.tr,
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_cardholder_name'.tr;
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'expiry_date'.tr,
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              ExpiryDateInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please_enter_expiry_date'.tr;
                              }
                              if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                                return 'valid_expiry_date'.tr;
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
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'cvv'.tr,
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please_enter_cvv'.tr;
                              }
                              if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                                return 'valid_3_digit_cvv'.tr;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _cvv = value;
                                _showBackView = true;
                              });
                            },
                            onFieldSubmitted: (value) {
                              setState(() {
                                _showBackView = false;
                              });
                            },
                            onSaved: (value) => _cvv = value!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'card_security_code'.tr,
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.security, color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_security_code'.tr;
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
                      child: SizedBox(
                        width: 363,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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